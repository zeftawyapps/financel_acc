# Contributing to Financial Accounting System

Thank you for your interest in contributing to the Financial Accounting System! This document provides guidelines and instructions for contributing to this project.

## Development Environment Setup

1. Install Flutter SDK (version 3.7.0 or later)
2. Enable Windows desktop support:
   ```powershell
   flutter config --enable-windows-desktop
   ```
3. Clone the repository:
   ```powershell
   git clone https://github.com/zeftawyapps/financel_acc.git
   cd financel_acc
   ```
4. Install dependencies:
   ```powershell
   flutter pub get
   ```

## Code Style Guidelines

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use named parameters for better code readability
- Document public APIs with dartdoc comments
- Organize imports alphabetically
- Keep line length to 80-100 characters

## Pull Request Process

1. Fork the repository and create a branch for your feature or bugfix
2. Implement your changes with appropriate tests
3. Ensure your code passes all linting and tests:
   ```powershell
   flutter analyze
   flutter test
   ```
4. Update the README.md file if necessary
5. Submit a pull request with a clear description of the changes

## Feature Requests and Bug Reports

Please use the GitHub Issues tracker to:

- Report bugs with detailed steps to reproduce
- Submit feature requests with clear use cases
- Discuss major changes before submitting a PR

## Project Structure

- `lib/` - Main application code
  - `Fa-package/` - Core financial accounting modules
    - `bloc/` - Business logic components
    - `data/` - Data models and repositories
  - `ui/` - User interface components
    - `screens/` - Application screens
    - `theme/` - Styling and theme configuration
    - `widgets/` - Reusable UI components
  - `utils/` - Helper functions and utilities

## Testing Guidelines

- Write unit tests for all data models and business logic
- Include widget tests for UI components
- Aim for high test coverage, especially for financial calculations
- Mock dependencies for isolated testing

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.
