#!/bin/bash

# File Decryption Script
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    log_error "GPG is not installed. Please install it with: sudo apt install gnupg"
    exit 1
fi

# Check if file argument is provided
if [ $# -eq 0 ]; then
    log_error "No file specified. Usage: $0 <encrypted_file.gpg> [output_file]"
    exit 1
fi

encrypted_file="$1"

# Check if file exists
if [ ! -f "$encrypted_file" ]; then
    log_error "File '$encrypted_file' does not exist."
    exit 1
fi

# Determine output filename
if [ $# -gt 1 ]; then
    output_file="$2"
else
    # Remove .gpg extension if present
    output_file="${encrypted_file%.gpg}"
fi

# Check if output file already exists
if [ -f "$output_file" ]; then
    log_error "Output file '$output_file' already exists."
    exit 1
fi

# Get password securely
echo -n "Enter decryption password: "
read -s password
echo

# Decrypt the file
echo "$password" | gpg --batch --yes --passphrase-fd 0 -o "$output_file" "$encrypted_file" 2>/dev/null

# Check if decryption was successful
if [ $? -eq 0 ] && [ -f "$output_file" ]; then
    log_success "File decrypted successfully: $output_file"
else
    log_error "Decryption failed. Incorrect password or corrupted file."
    # Remove any partially created file
    rm -f "$output_file"
    exit 1
fi