#!/bin/bash

# Improved File Encryption Script with Enhanced Secure Deletion
# For Ubuntu 24.04

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display formatted logs
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_highlight() {
    echo -e "${CYAN}[IMPORTANT]${NC} $1"
}

# Function to check if password meets minimum length requirement
check_password_length() {
    local password=$1
    local min_length=16
    
    if [ ${#password} -lt $min_length ]; then
        return 1  # Password is too short
    else
        return 0  # Password meets minimum length
    fi
}

# Check if required tools are installed
check_dependencies() {
    local missing_tools=()
    
    if ! command -v gpg &> /dev/null; then
        missing_tools+=("gnupg")
    fi
    
    if ! command -v shred &> /dev/null; then
        missing_tools+=("coreutils")
    fi
    
    if ! command -v lsblk &> /dev/null; then
        missing_tools+=("util-linux")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools. Please install them with:"
        echo
        for tool in "${missing_tools[@]}"; do
            echo "  sudo apt install $tool"
        done
        echo
        exit 1
    fi
}

# Function to detect storage medium type
detect_storage_type() {
    local file_path="$1"
    local dir_path=$(dirname "$(realpath "$file_path")")
    local device=$(df "$dir_path" | tail -1 | awk '{print $1}')
    
    # Get the underlying block device
    if [[ $device =~ /dev/mapper/ ]]; then
        device=$(lsblk -no PKNAME "$device" 2>/dev/null)
    elif [[ $device =~ /dev/sd[a-z] ]]; then
        device=${device}
    else
        device=$(lsblk -no PKNAME "$device" 2>/dev/null)
    fi
    
    if [ -n "$device" ]; then
        local rotational=$(cat /sys/block/$device/queue/rotational 2>/dev/null)
        if [ "$rotational" = "0" ]; then
            echo "SSD"
        elif [ "$rotational" = "1" ]; then
            echo "HDD"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

# Function to verify file content is overwritten
verify_shredding() {
    local file_path="$1"
    
    # Check if file exists
    if [ ! -f "$file_path" ]; then
        return 0  # File was removed, which is fine
    fi
    
    # If file exists, check if it's empty or contains only zeros
    local file_size=$(stat -c%s "$file_path")
    if [ "$file_size" -eq 0 ]; then
        log_warning "File exists but is empty (0 bytes)"
        return 0
    fi
    
    # Check if file contains only null bytes (zeroed out)
    if ! grep -P '[^\x00]' "$file_path" &>/dev/null; then
        log_info "Verification: File contains only null bytes (zeroed out)"
        return 0
    fi
    
    # Check if file appears to contain random/encrypted data
    local entropy=$(python3 -c "
import sys
data = open('$file_path', 'rb').read(1024)  # Check first 1KB
if len(data) == 0:
    print(0)
else:
    byte_counts = [0] * 256
    for byte in data:
        byte_counts[byte] += 1
    entropy = -sum((count/len(data)) * __import__('math').log2(count/len(data)) 
                   for count in byte_counts if count > 0)
    print(entropy)
" 2>/dev/null)
    
    if [ -n "$entropy" ] && (( $(echo "$entropy > 7.0" | bc -l) )); then
        log_info "Verification: File appears to contain high-entropy data (likely shredded)"
        return 0
    fi
    
    log_warning "Verification: File may not be completely shredded"
    return 1
}

# Enhanced secure delete function using shred utility
secure_delete() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    
    log_info "Securely deleting: $file_name"
    
    # Detect storage medium for appropriate warnings
    local storage_type=$(detect_storage_type "$file_path")
    
    if [ "$storage_type" = "SSD" ]; then
        log_warning "DETECTED SSD STORAGE - Secure deletion has limitations"
        log_info "Consider full disk encryption for better security"
    fi
    
    # Use shred utility with enhanced options
    if command -v shred &> /dev/null; then
        log_info "Using shred utility for secure deletion"
        
        # Build shred command with optimal settings
        local shred_cmd="shred -vfzu -n 5 \"$file_path\""
        
        # Execute shredding
        if eval "$shred_cmd"; then
            log_success "File securely shredded and removed: $file_name"
            return 0
        else
            log_error "Shred command failed"
            return 1
        fi
    else
        # Fallback method if shred is not available
        log_warning "Shred utility not available, using fallback method"
        
        # Method 1: Overwrite with random data multiple times
        if command -v dd &> /dev/null && command -v urandom &> /dev/null; then
            local file_size=$(stat -c%s "$file_path")
            local block_size=4096
            local blocks=$((file_size / block_size + 1))
            
            # Overwrite with random data 5 times (increased from 3)
            for i in {1..5}; do
                if dd if=/dev/urandom of="$file_path" bs=$block_size count=$blocks conv=notrunc 2>/dev/null; then
                    sync
                else
                    log_warning "Failed to overwrite with random data on pass $i"
                    break
                fi
            done
            
            # Final overwrite with zeros
            if dd if=/dev/zero of="$file_path" bs=$block_size count=$blocks conv=notrunc 2>/dev/null; then
                sync
            fi
        fi
        
        # Method 2: Remove the file
        rm -f "$file_path"
        if [ $? -eq 0 ]; then
            log_success "File securely deleted."
            
            # Verify the file is actually gone
            if [ ! -f "$file_path" ]; then
                return 0
            else
                log_error "File still exists after deletion attempt."
                return 1
            fi
        else
            log_error "Failed to delete file. Please delete it manually."
            return 1
        fi
    fi
}

# Check dependencies
check_dependencies

# Check if file argument is provided
if [ $# -eq 0 ]; then
    log_error "No file specified. Usage: $0 <file_to_encrypt>"
    exit 1
fi

file_path="$1"

# Check if file exists
if [ ! -f "$file_path" ]; then
    log_error "File '$file_path' does not exist."
    exit 1
fi

# Get absolute file path
abs_file_path=$(realpath "$file_path")

# Display file information
echo "File Details:"
echo "============="
echo "Path: $abs_file_path"
echo "Size: $(du -h "$file_path" | cut -f1)"
echo "Type: $(file "$file_path")"
echo "Modified: $(stat -c "%y" "$file_path")"
echo "Permissions: $(ls -l "$file_path" | cut -d' ' -f1)"
echo

# Detect storage medium
storage_type=$(detect_storage_type "$file_path")
log_info "Storage medium: $storage_type"

# Display warnings before proceeding
echo "========================================"
log_highlight "IMPORTANT: Please read the following carefully:"
echo "1. If you forget the password, your file will be PERMANENTLY inaccessible."
echo "2. After successful encryption, the original file will be securely deleted."
echo "3. This deletion is IRREVERSIBLE and the file cannot be recovered."
echo "4. On journaling filesystems, secure deletion may not be 100% effective."
if [ "$storage_type" = "SSD" ]; then
    echo "5. On SSDs, some data may remain due to wear-leveling."
fi
echo "========================================"

# Additional confirmation for sensitive operation
echo
read -p "Do you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Encryption cancelled by user."
    exit 0
fi

# Display password requirements
echo "========================================"
log_info "Password Requirements:"
echo "  - Minimum 16 characters long"
echo "  - Mix of uppercase and lowercase letters"
echo "  - Include numerals (0-9)"
echo "  - Include special characters like @#$%&*_-"
echo "========================================"

# Get password securely
echo -n "Enter encryption password: "
read -s password
echo
echo -n "Confirm password: "
read -s password_confirm
echo

# Check if passwords match
if [ "$password" != "$password_confirm" ]; then
    log_error "Passwords do not match. Please try again."
    exit 1
fi

# Check password length
if check_password_length "$password"; then
    log_success "Password meets minimum length requirement."
else
    log_error "Password must be at least 16 characters long."
    log_info "Please try again with a stronger password."
    exit 1
fi

# Create encrypted file
encrypted_file="${file_path}.gpg"
log_info "Encrypting file: $file_path"

# Encrypt the file
echo "$password" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 --s2k-mode 3 --s2k-digest-algo SHA512 --compress-algo 1 "$file_path"
encrypt_success=$?

# Check if encryption was successful
if [ $encrypt_success -eq 0 ] && [ -f "$encrypted_file" ]; then
    log_success "File encrypted successfully: $encrypted_file"
else
    log_error "Encryption failed."
    exit 1
fi

# Verify encryption by attempting to decrypt
log_info "Verifying encryption integrity..."
temp_file=$(mktemp)
echo "$password" | gpg --batch --yes --passphrase-fd 0 -o "$temp_file" "$encrypted_file" 2>/dev/null
decrypt_success=$?

if [ $decrypt_success -eq 0 ]; then
    # Compare original and decrypted files
    if cmp -s "$file_path" "$temp_file"; then
        log_success "Encryption verification successful."
        
        # Additional confirmation before deletion
        echo
        log_warning "About to securely delete the original file: $file_path"
        read -p "Confirm permanent deletion of original file? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Securely delete the original file using our enhanced function
            secure_delete "$file_path"
            if [ $? -eq 0 ]; then
                log_success "Original file securely deleted."
            else
                log_error "Failed to securely delete original file. Please delete it manually."
            fi
        else
            log_info "Keeping original file at your request."
            log_info "Encrypted file: $encrypted_file"
        fi
        
    else
        log_error "Encryption verification failed. Decrypted content does not match original."
        log_info "Keeping original file for your safety."
        # Securely delete the encrypted file
        secure_delete "$encrypted_file"
        exit 1
    fi
else
    log_error "Failed to decrypt for verification. Something went wrong."
    log_info "Keeping original file for your safety."
    # Securely delete the encrypted file
    secure_delete "$encrypted_file"
    exit 1
fi

# Clean up temporary files securely
if [ -f "$temp_file" ]; then
    secure_delete "$temp_file"
fi

# Security recommendations
echo
log_info "Security Recommendations:"
echo "- Store the encrypted file in a secure location"
echo "- Back up your password in a secure password manager"
echo "- Consider using a different password for each encrypted file"
if [ "$storage_type" = "SSD" ]; then
    echo "- For long-term storage on SSDs, consider using full disk encryption"
fi
echo "- Regularly verify the integrity of important encrypted files"

log_info "Encryption process completed."