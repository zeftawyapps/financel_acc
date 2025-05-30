# Fa-package

This package contains a modular, reusable implementation of the Financial Accountant application's core functionality.

## Architecture

The package follows a layered architecture:

1. **Data Layer** - Contains models and repositories

   - Models define the data structures
   - Repositories handle data storage and retrieval

2. **Business Logic Layer** - Contains BLoCs (Business Logic Components)

   - Manages state and business logic
   - Processes events and emits states

3. **Controller Layer** - Contains controller classes

   - Provides a simple API for UI components to interact with the BLoC
   - Acts as an intermediary between UI and BLoC

4. **UI Layer** - Outside this package, uses controllers to interact with the system

## Usage

### 1. Using Controllers

Controllers provide a simple, high-level API for UI components:

```dart
// Get the controller
final accountController = AccountController(context);

// Call methods on the controller
accountController.loadAccounts();
accountController.addAccount(newAccount);
```

### 2. Using Controller Widgets

Controllers provide widget methods for common BLoC patterns:

```dart
// Using the builder pattern
accountController.builder(
  builder: (context, state) {
    if (state is AccountsLoaded) {
      return ListView.builder(
        itemCount: state.accounts.length,
        itemBuilder: (context, index) => Text(state.accounts[index].name),
      );
    }
    return const SizedBox.shrink();
  },
);

// Using the listener pattern
accountController.listener(
  onAccountsLoaded: (context, state) {
    // Do something when accounts are loaded
  },
  child: yourWidget,
);

// Using the consumer pattern (combines builder and listener)
accountController.consumer(
  onAccountsLoaded: (context, state) {
    // Do something when accounts are loaded
  },
  builder: (context, state) {
    // Build UI based on state
    return yourWidget;
  },
);
```

### 3. Setting up the BLoC

To use a controller, you need to ensure the corresponding BLoC is provided:

```dart
// Wrap your widget with the controller's withBloc method
AccountController.withBloc(
  context: context,
  child: YourWidget(),
);
```

## Benefits

1. **Separation of Concerns** - UI is separated from business logic
2. **Testability** - Each layer can be tested independently
3. **Reusability** - Components can be reused across the application
4. **Maintainability** - Changes in one layer don't affect others
5. **Simplicity** - UI code is simpler and more focused
