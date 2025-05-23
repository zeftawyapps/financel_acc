# Accessing the MSIX Package

If you're having trouble finding or accessing the MSIX package in the setup_app folder, follow these troubleshooting steps:

## Option 1: Using provided batch files

1. Run `open_msix_package.bat` in the root folder to easily locate the MSIX file
2. Or run `install_msix.bat` to directly launch the installer

## Option 2: Navigate manually

The MSIX file is located at:

```
setup_app\WindowsStore\FinancialAccounting.msix
```

## Option 3: Generate the MSIX file

If the MSIX file is missing, you can generate it using:

1. Make sure you have the msix Flutter package installed:

   ```
   flutter pub add msix
   ```

2. Run the MSIX creation command:

   ```
   flutter pub run msix:create --output-path=setup_app\WindowsStore
   ```

3. The MSIX file will be created at `setup_app\WindowsStore\FinancialAccounting.msix`

## Option 4: Alternative installation methods

If you continue to have issues with the MSIX package:

1. Try using the portable version in the `build\windows\x64\runner\Release` folder
2. Or contact support for assistance at support@zeftawyapps.com
