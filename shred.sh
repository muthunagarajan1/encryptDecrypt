#!/bin/bash

# Improved File Shredding Script
# For Ubuntu 24.04
# Version 2.0 with enhanced safety features

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

# Function to check if shred is installed
check_dependencies() {
    local missing_tools=()
    
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
    # (this is a heuristic check)
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

# Function to show file details
show_file_details() {
    local file_path="$1"
    
    echo "File Details:"
    echo "============="
    echo "Path: $(realpath "$file_path")"
    echo "Size: $(du -h "$file_path" | cut -f1)"
    echo "Type: $(file "$file_path")"
    echo "Modified: $(stat -c "%y" "$file_path")"
    echo "Permissions: $(ls -l "$file_path" | cut -d' ' -f1)"
    echo
}

# Function to display help
show_help() {
    echo "Improved File Shredding Script"
    echo "==============================="
    echo "Securely delete files beyond recovery with enhanced safety features"
    echo
    echo "Usage: $0 [options] <file_to_shred>"
    echo
    echo "Options:"
    echo "  -n, --iterations NUM    Number of overwrite iterations (default: 5)"
    echo "  -v, --verbose           Show verbose output"
    echo "  -z, --zero             Final overwrite with zeros"
    echo "  -u, --remove           Remove file after overwriting (default: enabled)"
    echo "  --no-remove            Do not remove file after overwriting"
    echo "  --verify               Verify shredding effectiveness"
    echo "  --force                Skip some confirmation prompts (use with caution)"
    echo "  -h, --help             Show this help message"
    echo
    echo "Security Levels:"
    echo "  Basic:      $0 -n 3 file.txt"
    echo "  Standard:   $0 file.txt (5 iterations)"
    echo "  High:       $0 -n 7 -z -v file.txt"
    echo "  Maximum:    $0 -n 35 -z -v --verify file.txt"
    echo
    echo "Examples:"
    echo "  $0 sensitive.txt"
    echo "  $0 -n 7 -v -z secret.pdf"
    echo "  $0 --iterations 7 --verify confidential.doc"
}

# Default values
iterations=5
verbose=false
zero=true
remove=true
verify=false
force=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--iterations)
            iterations="$2"
            shift 2
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        -z|--zero)
            zero=true
            shift
            ;;
        -u|--remove)
            remove=true
            shift
            ;;
        --no-remove)
            remove=false
            shift
            ;;
        --verify)
            verify=true
            shift
            ;;
        --force)
            force=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
        *)
            if [ -z "$file_path" ]; then
                file_path="$1"
            else
                log_error "Multiple files specified. Only one file can be processed at a time."
                exit 1
            fi
            shift
            ;;
    esac
done

# Check dependencies
check_dependencies

# Check if file argument is provided
if [ -z "$file_path" ]; then
    log_error "No file specified. Usage: $0 <file_to_shred>"
    echo "Use -h or --help for usage information."
    exit 1
fi

# Check if file exists
if [ ! -f "$file_path" ]; then
    log_error "File '$file_path' does not exist."
    exit 1
fi

# Check if iterations is a valid number
if ! [[ "$iterations" =~ ^[0-9]+$ ]] || [ "$iterations" -lt 1 ]; then
    log_error "Iterations must be a positive integer."
    exit 1
fi

# Get absolute file path
abs_file_path=$(realpath "$file_path")

# Detect storage medium
storage_type=$(detect_storage_type "$file_path")

# Display file details
show_file_details "$file_path"

# Display storage medium warning if SSD
if [ "$storage_type" = "SSD" ]; then
    log_warning "DETECTED SSD STORAGE"
    echo "⚠️  IMPORTANT: Shredding on SSDs has limitations:"
    echo "   - SSDs use wear-leveling which may leave data remnants"
    echo "   - TRIM command may be more effective for SSDs"
    echo "   - Consider using encryption for better security"
    echo
fi

# Enhanced warnings
echo "========================================"
log_highlight "CRITICAL WARNING: This action is PERMANENT"
echo "1. This will PERMANENTLY delete the file: $abs_file_path"
echo "2. The file content will be overwritten $iterations times"
echo "3. This deletion is IRREVERSIBLE - NO RECOVERY POSSIBLE"
echo "4. Even forensic tools will be UNABLE to recover the data"
echo "5. The file will be ${remove:-REMOVED} after shredding"
echo "========================================"

# Additional confirmation step
if [ "$force" = false ]; then
    # Ask user to type the filename to confirm
    echo
    log_warning "For safety, please type the exact filename to confirm:"
    read -p "Filename to shred: " confirm_file
    
    if [ "$confirm_file" != "$(basename "$file_path")" ]; then
        log_error "Filename mismatch. Operation cancelled for your safety."
        exit 0
    fi
    
    echo
    read -p "Final confirmation - Do you want to continue? (type 'DELETE'): " final_confirm
    if [ "$final_confirm" != "DELETE" ]; then
        log_info "Shredding cancelled by user."
        exit 0
    fi
else
    echo
    read -p "Do you want to continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Shredding cancelled by user."
        exit 0
    fi
fi

# Build shred command
shred_cmd="shred"

if [ "$verbose" = true ]; then
    shred_cmd="$shred_cmd -v"
fi

if [ "$zero" = true ]; then
    shred_cmd="$shred_cmd -z"
fi

if [ "$remove" = true ]; then
    shred_cmd="$shred_cmd -u"
fi

shred_cmd="$shred_cmd -n $iterations \"$file_path\""

# Display what we're doing
log_info "Shredding file: $file_path"
log_info "Storage type: $storage_type"
log_info "Iterations: $iterations"
log_info "Verbose: $verbose"
log_info "Zero final pass: $zero"
log_info "Remove after shredding: $remove"
log_info "Verification: $verify"

if [ "$verbose" = true ]; then
    echo
    log_info "Executing: $shred_cmd"
    echo
fi

# Execute the shred command
eval $shred_cmd
shred_exit_code=$?

# Check if shredding was successful
if [ $shred_exit_code -eq 0 ]; then
    if [ "$remove" = false ]; then
        log_success "File shredded successfully: $file_path"
        log_info "The file still exists but its content has been overwritten."
    else
        log_success "File shredded and removed successfully: $file_path"
    fi
    
    # Verify shredding if requested
    if [ "$verify" = true ] && [ "$remove" = false ]; then
        log_info "Verifying shredding effectiveness..."
        if verify_shredding "$file_path"; then
            log_success "Verification passed: File appears to be properly shredded"
        else
            log_warning "Verification warning: File may not be completely shredded"
            log_info "Consider running with more iterations or different options"
        fi
    fi
    
    # Additional security recommendations
    echo
    log_info "Security Recommendations:"
    if [ "$storage_type" = "SSD" ]; then
        echo "- For SSDs, consider using 'blkdiscard' for more secure deletion"
        echo "- Full disk encryption provides better security for SSDs"
    fi
    if [ "$iterations" -lt 7 ]; then
        echo "- For highly sensitive data, consider using more iterations (7+)"
    fi
    echo "- Ensure no backups of this file exist elsewhere"
    echo "- Check cloud sync folders that might contain copies"
    echo "- Consider secure deletion of any temporary files"
    
else
    log_error "Shredding failed with exit code: $shred_exit_code"
    log_error "The file may still contain recoverable data"
    exit 1
fi

echo
log_info "Shredding process completed."