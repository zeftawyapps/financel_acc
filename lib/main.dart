import 'package:financel_acc/lib/Fa-package/bloc/account/account_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/ledger/ledger_bloc.dart';
import 'package:financel_acc/lib/Fa-package/data/database/database_service.dart';
import 'package:financel_acc/lib/Fa-package/data/repositories/account_repository.dart';
import 'package:financel_acc/lib/Fa-package/data/repositories/journal_repository.dart';
import 'package:financel_acc/lib/Fa-package/data/repositories/ledger_repository.dart';
import 'package:financel_acc/lib/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Import screens
import 'lib/ui/screens/home_screen.dart';

void main() {
  // Initialize FFI for Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Database Service
        RepositoryProvider<DatabaseService>(
          create: (context) => DatabaseService(),
        ),

        // Repositories
        RepositoryProvider<AccountRepository>(
          create:
              (context) => AccountRepository(
                databaseService: context.read<DatabaseService>(),
              ),
        ),
        RepositoryProvider<JournalRepository>(
          create:
              (context) => JournalRepository(
                databaseService: context.read<DatabaseService>(),
              ),
        ),
        RepositoryProvider<LedgerRepository>(
          create:
              (context) => LedgerRepository(
                databaseService: context.read<DatabaseService>(),
              ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoCs
          BlocProvider<AccountBloc>(
            create:
                (context) => AccountBloc(
                  accountRepository: context.read<AccountRepository>(),
                ),
          ),
          BlocProvider<JournalBloc>(
            create:
                (context) => JournalBloc(
                  journalRepository: context.read<JournalRepository>(),
                ),
          ),
          BlocProvider<LedgerBloc>(
            create:
                (context) => LedgerBloc(
                  ledgerRepository: context.read<LedgerRepository>(),
                ),
          ),
        ],
        child: MaterialApp(
          title: 'Financial Accounting',
          theme: AppTheme.getTheme(),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
