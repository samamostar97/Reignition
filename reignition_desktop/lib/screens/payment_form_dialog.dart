import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../providers/payment_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/shared/app_snackbars.dart';

class PaymentFormDialog extends ConsumerStatefulWidget {
  final PaymentResponse? item;

  const PaymentFormDialog({super.key, this.item});

  @override
  ConsumerState<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends ConsumerState<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedUserId;
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  PaymentStatus? _selectedStatus;
  bool _isSubmitting = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _amountController.text = widget.item!.amount.toStringAsFixed(2);
      _noteController.text = widget.item!.note ?? '';
      _selectedUserId = widget.item!.userId;
      _selectedMethod = widget.item!.paymentMethod;
      _selectedStatus = widget.item!.status;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Gotovina';
      case PaymentMethod.card:
        return 'Kartica';
      case PaymentMethod.bankTransfer:
        return 'Bankovni transfer';
    }
  }

  String _statusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Završena';
      case PaymentStatus.refunded:
        return 'Refundirana';
      case PaymentStatus.pending:
        return 'Na čekanju';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && _selectedUserId == null) return;

    setState(() => _isSubmitting = true);

    try {
      if (_isEditing) {
        await ref.read(paymentListProvider.notifier).update(
              widget.item!.id,
              UpdatePaymentRequest(
                amount: double.tryParse(_amountController.text),
                paymentMethod: _selectedMethod,
                note: _noteController.text.isEmpty ? null : _noteController.text,
                status: _selectedStatus,
              ),
            );
        if (mounted) Navigator.pop(context, true);
      } else {
        final response = await ref.read(paymentServiceProvider).createFromRequest(
              CreatePaymentRequest(
                userId: _selectedUserId!,
                amount: double.parse(_amountController.text),
                paymentMethod: _selectedMethod,
                note: _noteController.text.isEmpty ? null : _noteController.text,
              ),
            );
        ref.read(paymentListProvider.notifier).load();
        if (mounted) Navigator.pop(context, response);
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbars.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLookup = ref.watch(userLookupProvider);

    return AlertDialog(
      title: Text(_isEditing ? 'Uredi uplatu' : 'Nova uplata'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isEditing)
                userLookup.when(
                  data: (users) => DropdownButtonFormField<int>(
                    initialValue: _selectedUserId,
                    decoration: const InputDecoration(labelText: 'Korisnik'),
                    items: users
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUserId = v),
                    validator: (v) => v == null ? 'Korisnik je obavezan.' : null,
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Text(
                    'Greška pri učitavanju korisnika',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              if (!_isEditing) const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Iznos (KM)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Iznos je obavezan.';
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) return 'Unesite validan iznos.';
                  if (amount > 99999.99) return 'Iznos ne smije biti veći od 99999.99.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _selectedMethod,
                decoration: const InputDecoration(labelText: 'Način plaćanja'),
                items: PaymentMethod.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(_methodLabel(e))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMethod = v!),
              ),
              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PaymentStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: PaymentStatus.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(_statusLabel(e))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Napomena (opcionalno)'),
                maxLines: 2,
                maxLength: 500,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Sačuvaj izmjene' : 'Kreiraj'),
        ),
      ],
    );
  }
}
