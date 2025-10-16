# File Encryption/Decryption/Shredding Scripts

A collection of secure Bash scripts for encrypting, decrypting, and securely shredding files using AES-256 encryption via GnuPG (GPG) and secure deletion utilities on Ubuntu 24.04. These scripts provide a user-friendly interface with strong security practices, including secure deletion of original files after encryption.

## Features

- **Strong Encryption**: Uses AES-256 encryption through GnuPG
- **Secure Deletion**: Original files are securely deleted using shred after successful encryption
- **File Shredding**: Dedicated script for secure file deletion beyond recovery
- **Password Validation**: Enforces strong password requirements (minimum 16 characters)
- **Verification**: Automatically verifies encryption integrity before deleting original files
- **User-Friendly Interface**: Color-coded output and clear error messages
- **Security Focused**: Passwords are never stored to disk and input is hidden

## Files Included

- [`encrypt.sh`](encrypt.sh) - Script for encrypting files with secure deletion
- [`decrypt.sh`](decrypt.sh) - Script for decrypting GPG-encrypted files
- [`shred.sh`](shred.sh) - Script for securely shredding files beyond recovery

## Requirements

- Ubuntu 24.04 (or similar Linux distribution)
- Required packages:
  ```bash
  sudo apt install gnupg coreutils
  ```

## Quick Start

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd encryptDecrypt
   ```

2. Make the scripts executable:

   ```bash
   chmod +x encrypt.sh decrypt.sh shred.sh
   ```

3. Encrypt a file:

   ```bash
   ./encrypt.sh your-file.txt
   ```

4. Decrypt the file:
   ```bash
   ./decrypt.sh your-file.txt.gpg
   ```

5. Securely shred a file:
   ```bash
   ./shred.sh sensitive-file.txt
   ```

## Password Requirements

- Minimum 16 characters
- Mix of uppercase and lowercase letters
- Include numerals (0-9)
- Include special characters like @#$%&\*\_-

Example strong password: `MyP@ssw0rd!SecureKey`

## Security Notes

⚠️ **Important**:

- If you forget the password, your file will be PERMANENTLY inaccessible
- The original file is securely deleted after successful encryption
- This deletion is irreversible and files cannot be recovered
- Always keep backups of important files before encryption

---

## Encryption Script (encrypt.sh)

### Overview
Securely encrypt files using AES-256 encryption with automatic secure deletion of the original file.

### Setup
Make the script executable:
```bash
chmod +x encrypt.sh
```

### Usage
```bash
./encrypt.sh <file_to_encrypt>
```

### Example
```bash
./encrypt.sh document.pdf
```

### Important Notes
- The original file will be permanently deleted after successful encryption
- If you forget the password, the file cannot be recovered
- The script verifies encryption before deleting the original file

---

## Decryption Script (decrypt.sh)

### Overview
A Bash script for decrypting GPG-encrypted files on Ubuntu 24.04 with user-friendly interface and error handling.

### Setup
Make the script executable:
```bash
chmod +x decrypt.sh
```

### Usage

#### Basic Syntax
```bash
./decrypt.sh <encrypted_file.gpg> [output_file]
```

#### Parameters
- `encrypted_file.gpg`: The encrypted file you want to decrypt (required)
- `output_file`: Optional custom name for the decrypted file

#### Examples

**Example 1: Basic Decryption**
Decrypt a file and let the script automatically name the output (removes .gpg extension):
```bash
./decrypt.sh document.pdf.gpg
```
This will create a decrypted file named `document.pdf`

**Example 2: Custom Output Filename**
Specify a custom name for the decrypted file:
```bash
./decrypt.sh document.pdf.gpg my_decrypted_file.pdf
```

**Example 3: Working Directory**
If your encrypted file is in a different directory:
```bash
./decrypt.sh /path/to/encrypted/secret.txt.gpg
```

### How It Works
1. **Validation**: Checks if GPG is installed and if the input file exists
2. **Output Naming**: Determines the output filename (either specified or derived from input)
3. **Security Check**: Ensures output file doesn't already exist to prevent overwrites
4. **Password Input**: Securely prompts for decryption password (input is hidden)
5. **Decryption**: Uses GPG to decrypt the file
6. **Verification**: Confirms successful decryption and reports results

### Features
- **Color-coded output**: Informative messages with color coding
- **Error handling**: Comprehensive checks with helpful error messages
- **Secure password input**: Password is not displayed while typing
- **Automatic cleanup**: Removes partial files if decryption fails
- **File safety**: Prevents accidental overwriting of existing files

---

## Shredding Script (shred.sh)

### Overview
Securely delete files beyond recovery using multiple overwriting patterns. This script provides a safe interface to the `shred` utility with additional safety checks and confirmation prompts.

### Setup
Make the script executable:
```bash
chmod +x shred.sh
```

### Usage
```bash
./shred.sh [options] <file_to_shred>
```

### Options
- `-n, --iterations NUM`: Number of overwrite iterations (default: 3)
- `-v, --verbose`: Show verbose output during shredding
- `-z, --zero`: Add a final overwrite with zeros to hide shredding
- `-u, --remove`: Remove file after overwriting
- `-h, --help`: Show help message

### Examples

#### Basic Shredding
Shred a file with default settings (3 iterations):
```bash
./shred.sh sensitive.txt
```

#### Advanced Shredding
Shred with 5 iterations, verbose output, and final zero pass:
```bash
./shred.sh -n 5 -v -z secret.pdf
```

#### Shred and Remove
Shred with 7 iterations and automatically remove the file:
```bash
./shred.sh --iterations 7 --remove confidential.doc
```

### How It Works
The script uses the `shred` utility which:
1. Overwrites the file with random data multiple times
2. Optionally adds a final pass with zeros
3. Optionally removes the file from the filesystem

### Security Levels
- **Basic (3 iterations)**: Good for most personal files
- **Medium (5 iterations)**: Better security for sensitive documents
- **High (7+ iterations)**: Maximum security for highly confidential data

### Important Warnings
⚠️ **CRITICAL WARNINGS**:
1. **PERMANENT DELETION**: This process is irreversible. Once shredded, files cannot be recovered.
2. **NO UNDO**: There is no undo function. The action is permanent.
3. **BACKUP FIRST**: Ensure you have backups of any important files before shredding.
4. **DOUBLE-CHECK**: Verify you're shredding the correct file before confirming.

---

## Usage Examples

### Encrypting a file
```bash
./encrypt.sh document.pdf
```
This will create `document.pdf.gpg` and securely delete the original `document.pdf`

### Decrypting a file
```bash
./decrypt.sh document.pdf.gpg
```
This will create `document.pdf` from the encrypted file

### Decrypting with custom output name
```bash
./decrypt.sh document.pdf.gpg recovered-document.pdf
```

### Shredding a file
```bash
./shred.sh sensitive.txt
```
This will overwrite the file 3 times with random data

### Advanced shredding
```bash
./shred.sh -n 5 -v -z -u secret.pdf
```
This will:
- Overwrite the file 5 times
- Show verbose output
- Add a final zero pass
- Remove the file after shredding

## Troubleshooting

### Common Issues

1. **Permission Denied**: Make sure scripts are executable with `chmod +x encrypt.sh decrypt.sh shred.sh`
2. **GPG Not Installed**: Install with `sudo apt install gnupg coreutils`
3. **Incorrect Password**: Ensure you're using the exact password used for encryption
4. **File Already Exists**: The decryption script prevents overwriting existing files
5. **Shred Fails**: Ensure you have write permissions to the file and directory

### Error Messages

The scripts provide clear, color-coded error messages to help diagnose issues:

- `[ERROR]` - Critical issues that prevent operation
- `[WARNING]` - Important security warnings
- `[INFO]` - Informational messages
- `[SUCCESS]` - Successful operations

## Contributing

When contributing to this project:

1. Ensure all security practices are maintained
2. Test thoroughly on Ubuntu 24.04
3. Update documentation for any changes
4. Follow the existing code style

## License

This project is provided as-is for educational and personal use. Users are responsible for understanding the security implications and ensuring proper backup strategies.

## Disclaimer

These scripts are provided for educational purposes. Users should:

- Understand that lost passwords mean permanent data loss
- Keep secure backups of important data
- Test the scripts with non-critical files first
- Ensure compliance with local regulations regarding encryption

---

**Remember**: With great encryption comes great responsibility. Keep your passwords safe and backed up through secure means. Always double-check before shredding files, as this action is irreversible.
