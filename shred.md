# File Shredding Script

## Overview
Securely delete files beyond recovery using multiple overwriting patterns. This script provides a safe interface to the `shred` utility with additional safety checks and confirmation prompts.

## Requirements
- Ubuntu 24.04 (or similar Linux distribution)
- Required packages:
  ```bash
  sudo apt install coreutils
  ```

## Setup
Make the script executable:
```bash
chmod +x shred.sh
```

## Usage
```bash
./shred.sh [options] <file_to_shred>
```

## Options
- `-n, --iterations NUM`: Number of overwrite iterations (default: 3)
- `-v, --verbose`: Show verbose output during shredding
- `-z, --zero`: Add a final overwrite with zeros to hide shredding
- `-u, --remove`: Remove file after overwriting
- `-h, --help`: Show help message

## Examples

### Basic Shredding
Shred a file with default settings (3 iterations):
```bash
./shred.sh sensitive.txt
```

### Advanced Shredding
Shred with 5 iterations, verbose output, and final zero pass:
```bash
./shred.sh -n 5 -v -z secret.pdf
```

### Shred and Remove
Shred with 7 iterations and automatically remove the file:
```bash
./shred.sh --iterations 7 --remove confidential.doc
```

## How It Works

The script uses the `shred` utility which:
1. Overwrites the file with random data multiple times
2. Optionally adds a final pass with zeros
3. Optionally removes the file from the filesystem

### Security Levels

- **Basic (3 iterations)**: Good for most personal files
- **Medium (5 iterations)**: Better security for sensitive documents
- **High (7+ iterations)**: Maximum security for highly confidential data

## Important Warnings

⚠️ **CRITICAL WARNINGS**:

1. **PERMANENT DELETION**: This process is irreversible. Once shredded, files cannot be recovered.
2. **NO UNDO**: There is no undo function. The action is permanent.
3. **BACKUP FIRST**: Ensure you have backups of any important files before shredding.
4. **DOUBLE-CHECK**: Verify you're shredding the correct file before confirming.

## Security Considerations

### Effectiveness
- The effectiveness depends on the storage medium
- SSDs may wear-level data, making complete deletion more complex
- Traditional HDDs are more thoroughly cleaned by this method

### Limitations
- File system journaling may retain copies of data
- Some systems create automatic backups
- Cloud-synced files may exist on remote servers

### Best Practices
1. Use appropriate iteration count for your security needs
2. Consider the `-z` option to hide the fact that shredding occurred
3. Use the `-u` option to completely remove the file
4. Verify the file is gone after shredding

## Troubleshooting

### Common Issues

#### "Permission Denied"
Ensure you have write permissions to the file:
```bash
ls -l filename
chmod 600 filename  # If needed
```

#### "File Does Not Exist"
Check the file path and name:
```bash
ls -la /path/to/file
```

#### "Shred Command Failed"
Ensure coreutils is installed:
```bash
sudo apt install coreutils
```

### Error Messages

The script provides clear error messages for common issues:
- Missing dependencies
- Invalid iteration count
- Non-existent files
- Permission problems

## Related Scripts

This script complements the encryption/decryption scripts:
- Use [`encrypt.sh`](encrypt.sh) to encrypt files before secure deletion
- Use [`decrypt.sh`](decrypt.sh) to recover encrypted files when needed

## Technical Details

### Shred Algorithm
The `shred` utility uses a three-pass method by default:
1. First pass: Random data pattern
2. Second pass: Complement of first pattern
3. Third pass: Random data pattern

### File Removal
When using the `-u` option:
1. File is overwritten as specified
2. File is truncated to remove any remaining data
3. File is renamed to hide its original identity
4. File is finally removed from the filesystem

## Legal and Ethical Considerations

- Only shred files you own or have permission to delete
- Be aware of data retention policies in your organization
- Consider legal requirements for data preservation
- Ensure compliance with relevant regulations

## Disclaimer

This script is provided for educational and personal use. Users are responsible for:
- Verifying they're shredding the correct files
- Maintaining appropriate backups
- Complying with applicable laws and regulations
- Understanding the limitations of secure deletion

**Remember**: With great power comes great responsibility. Always double-check before shredding files.