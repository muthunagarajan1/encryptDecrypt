#!/bin/bash

# File Encryption Script with Secure Deletion
# For Ubuntu 24.04

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Display warnings before proceeding
echo "========================================"
log_warning "IMPORTANT: Please read the following carefully:"
echo "1. If you forget the password, your file will be PERMANENTLY inaccessible."
echo "2. After successful encryption, the original file will be securely deleted."
echo "3. This deletion is irreversible and the file cannot be recovered."
echo "========================================"

# Ask for confirmation
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
echo "$password" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 "$file_path"

# Check if encryption was successful
if [ $? -eq 0 ] && [ -f "$encrypted_file" ]; then
    log_success "File encrypted successfully: $encrypted_file"
else
    log_error "Encryption failed."
    exit 1
fi

# Verify encryption by attempting to decrypt
log_info "Verifying encryption integrity..."
temp_file=$(mktemp)
echo "$password" | gpg --batch --yes --passphrase-fd 0 -o "$temp_file" "$encrypted_file" 2>/dev/null

if [ $? -eq 0 ]; then
    # Compare original and decrypted files
    if cmp -s "$file_path" "$temp_file"; then
        log_success "Encryption verification successful."
        
        # Securely delete the original file
        log_info "Securely deleting original file: $file_path"
        shred -vfz -n 3 "$file_path"
        
        if [ $? -eq 0 ]; then
            log_success "Original file securely deleted."
        else
            log_error "Failed to securely delete original file. Please delete it manually."
        fi
    else
        log_error "Encryption verification failed. Decrypted content does not match original."
        log_info "Keeping original file for your safety."
        # Securely delete the encrypted file
        log_info "Securely deleting failed encrypted file: $encrypted_file"
        shred -vfz -n 3 "$encrypted_file" 2>/dev/null
    fi
else
    log_error "Failed to decrypt for verification. Something went wrong."
    log_info "Keeping original file for your safety."
    # Securely delete the encrypted file
    log_info "Securely deleting failed encrypted file: $encrypted_file"
    shred -vfz -n 3 "$encrypted_file" 2>/dev/null
fi

# Clean up temporary files securely
log_info "Securely deleting temporary file: $temp_file"
shred -vfz -n 3 "$temp_file" 2>/dev/null

log_info "Encryption process completed."