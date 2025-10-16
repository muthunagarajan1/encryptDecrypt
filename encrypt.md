# File Encryption Script

## Overview
Securely encrypt files using AES-256 encryption with automatic secure deletion of the original file.

## Requirements
- Ubuntu 24.04
- Required packages:
  ```bash
  sudo apt install gnupg coreutils
  ```

## Setup
Make the script executable:
```bash
chmod +x encrypt.sh
```

## Password Requirements
- Minimum 16 characters
- Mix of uppercase and lowercase letters
- Include numerals (0-9)
- Include special characters like @#$%&*_-

## Usage
```bash
./encrypt.sh <file_to_encrypt>
```

## Example
```bash
./encrypt.sh document.pdf
```

Sample strong password: `MyP@ssw0rd!SecureKey`

## Important Notes
- The original file will be permanently deleted after successful encryption
- If you forget the password, the file cannot be recovered
- The script verifies encryption before deleting the original file