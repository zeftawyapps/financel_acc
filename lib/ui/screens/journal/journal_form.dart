// filepath: c:\Users\HP\Desktop\New folder\financel_acc-master\lib\ui\screens\journal\journal_form.dart
import 'package:financel_acc/Fa-package/data/models/journal.dart';
import 'package:flutter/material.dart';
import 'package:financel_acc/ui/widgets/journal/journal_form_widget.dart';

class JournalFormScreen extends StatelessWidget {
  final Journal? journal;

  const JournalFormScreen({super.key, this.journal});

  @override
  Widget build(BuildContext context) {
    return JournalForm(journal: journal);
  }
}
