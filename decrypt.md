# File Decryption Script

A Bash script for decrypting GPG-encrypted files on Ubuntu 24.04 with user-friendly interface and error handling.

## Prerequisites

- Ubuntu 24.04 (or similar Linux distribution)
- GnuPG (GPG) installed

### Installing GPG

If GPG is not installed on your system, install it with:

```bash
sudo apt update
sudo apt install gnupg
```

## Setup

### Making the Script Executable

1. Navigate to the directory containing the script
2. Make it executable with:

```bash
chmod +x decrypt.sh
```

## Usage

### Basic Syntax

```bash
./decrypt.sh <encrypted_file.gpg> [output_file]
```

### Parameters

- `encrypted_file.gpg`: The encrypted file you want to decrypt (required)
- `output_file`: Optional custom name for the decrypted file

### Examples

#### Example 1: Basic Decryption
Decrypt a file and let the script automatically name the output (removes .gpg extension):

```bash
./decrypt.sh document.pdf.gpg
```
This will create a decrypted file named `document.pdf`

#### Example 2: Custom Output Filename
Specify a custom name for the decrypted file:

```bash
./decrypt.sh document.pdf.gpg my_decrypted_file.pdf
```

#### Example 3: Working Directory
If your encrypted file is in a different directory:

```bash
./decrypt.sh /path/to/encrypted/secret.txt.gpg
```

## How It Works

1. **Validation**: Checks if GPG is installed and if the input file exists
2. **Output Naming**: Determines the output filename (either specified or derived from input)
3. **Security Check**: Ensures output file doesn't already exist to prevent overwrites
4. **Password Input**: Securely prompts for decryption password (input is hidden)
5. **Decryption**: Uses GPG to decrypt the file
6. **Verification**: Confirms successful decryption and reports results

## Features

- **Color-coded output**: Informative messages with color coding
- **Error handling**: Comprehensive checks with helpful error messages
- **Secure password input**: Password is not displayed while typing
- **Automatic cleanup**: Removes partial files if decryption fails
- **File safety**: Prevents accidental overwriting of existing files

## Troubleshooting

### Common Issues

#### "GPG is not installed"
Install GPG with: `sudo apt install gnupg`

#### "File does not exist"
Check that the encrypted file path and name are correct

#### "Output file already exists"
Either remove the existing file or specify a different output filename

#### "Decryption failed"
- Verify you're entering the correct password
- Ensure the encrypted file isn't corrupted
- Check that the file was encrypted with a compatible GPG version

### Error Messages

The script provides clear error messages for common issues:
- Missing GPG installation
- Missing file arguments
- Non-existent input files
- Existing output files
- Failed decryption

## Security Notes

- Passwords are never stored to disk
- Password input is hidden for security
- The script cleans up partial files on failed decryption
- GPG handles all cryptographic operations

## Related Scripts

This script is designed to work with files encrypted by the companion `encrypt.sh` script.