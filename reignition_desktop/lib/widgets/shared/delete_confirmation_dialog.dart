import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmation(BuildContext context, String itemName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Potvrda brisanja'),
      content: Text('Da li ste sigurni da želite obrisati "$itemName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Odustani'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Obriši'),
        ),
      ],
    ),
  );
  return result ?? false;
}
