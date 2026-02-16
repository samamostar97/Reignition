import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../providers/membership_type_provider.dart';
import '../widgets/shared/app_snackbars.dart';

class MembershipTypeFormDialog extends ConsumerStatefulWidget {
  final MembershipTypeResponse? item;

  const MembershipTypeFormDialog({super.key, this.item});

  @override
  ConsumerState<MembershipTypeFormDialog> createState() => _MembershipTypeFormDialogState();
}

class _MembershipTypeFormDialogState extends ConsumerState<MembershipTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _durationController = TextEditingController(text: widget.item?.durationInDays.toString() ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      if (_isEditing) {
        await ref.read(membershipTypeListProvider.notifier).update(
              widget.item!.id,
              UpdateMembershipTypeRequest(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                durationInDays: int.parse(_durationController.text.trim()),
                price: double.parse(_priceController.text.trim()),
              ),
            );
        if (mounted) Navigator.pop(context, true);
      } else {
        final response = await ref.read(membershipTypeServiceProvider).createFromRequest(
              CreateMembershipTypeRequest(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                durationInDays: int.parse(_durationController.text.trim()),
                price: double.parse(_priceController.text.trim()),
              ),
            );
        ref.read(membershipTypeListProvider.notifier).load();
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
    return AlertDialog(
      title: Text(_isEditing ? 'Uredi tip članarine' : 'Novi tip članarine'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Naziv'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Naziv je obavezan.';
                  if (v.trim().length < 2) return 'Naziv mora imati najmanje 2 karaktera.';
                  if (v.trim().length > 100) return 'Naziv može imati maksimalno 100 karaktera.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis (opcionalno)'),
                maxLines: 2,
                validator: (v) {
                  if (v != null && v.length > 500) return 'Opis može imati maksimalno 500 karaktera.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(labelText: 'Trajanje (dana)'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Trajanje je obavezno.';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1 || n > 730) return 'Između 1 i 730 dana.';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Cijena (KM)'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Cijena je obavezna.';
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 0.01 || n > 99999.99) return 'Između 0.01 i 99999.99.';
                        return null;
                      },
                    ),
                  ),
                ],
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
