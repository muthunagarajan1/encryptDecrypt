#!/bin/bash

# File Shredding Script
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

# Function to check if shred is installed
check_dependencies() {
    local missing_tools=()
    
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

# Function to display help
show_help() {
    echo "File Shredding Script"
    echo "===================="
    echo "Securely delete files beyond recovery"
    echo
    echo "Usage: $0 [options] <file_to_shred>"
    echo
    echo "Options:"
    echo "  -n, --iterations NUM    Number of overwrite iterations (default: 3)"
    echo "  -v, --verbose           Show verbose output"
    echo "  -z, --zero             Final overwrite with zeros"
    echo "  -u, --remove           Remove file after overwriting"
    echo "  -h, --help             Show this help message"
    echo
    echo "Examples:"
    echo "  $0 sensitive.txt"
    echo "  $0 -n 5 -v -z secret.pdf"
    echo "  $0 --iterations 7 --verbose --zero --remove confidential.doc"
}

# Default values
iterations=3
verbose=false
zero=false
remove=false

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

# Display warnings before proceeding
echo "========================================"
log_warning "IMPORTANT: Please read the following carefully:"
echo "1. This will PERMANENTLY delete the file: $file_path"
echo "2. The file will be overwritten $iterations times"
echo "3. This deletion is irreversible and the file cannot be recovered"
echo "4. Even with forensic tools, recovery will be extremely difficult"
echo "========================================"

# Ask for confirmation
read -p "Do you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Shredding cancelled by user."
    exit 0
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
log_info "Iterations: $iterations"
log_info "Verbose: $verbose"
log_info "Zero final pass: $zero"
log_info "Remove after shredding: $remove"

if [ "$verbose" = true ]; then
    echo
    log_info "Executing: $shred_cmd"
    echo
fi

# Execute the shred command
eval $shred_cmd

# Check if shredding was successful
if [ $? -eq 0 ]; then
    if [ "$remove" = false ]; then
        log_success "File shredded successfully: $file_path"
        log_info "The file still exists but its content has been overwritten."
        log_info "You can now safely remove it with: rm \"$file_path\""
    else
        log_success "File shredded and removed successfully: $file_path"
    fi
else
    log_error "Shredding failed."
    exit 1
fi

log_info "Shredding process completed."