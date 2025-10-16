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
- [`encrypt.md`](encrypt.md) - Detailed documentation for the encryption script
- [`decrypt.md`](decrypt.md) - Detailed documentation for the decryption script
- [`shred.md`](shred.md) - Detailed documentation for the shredding script

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

## Detailed Documentation

For more detailed information about each script, please refer to:

- [Encryption Script Documentation](encrypt.md)
- [Decryption Script Documentation](decrypt.md)
- [Shredding Script Documentation](shred.md)

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
