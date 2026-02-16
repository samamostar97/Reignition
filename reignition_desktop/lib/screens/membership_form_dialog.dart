import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../providers/membership_provider.dart';
import '../providers/membership_type_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/shared/app_snackbars.dart';

class MembershipFormDialog extends ConsumerStatefulWidget {
  final MembershipResponse? item;

  const MembershipFormDialog({super.key, this.item});

  @override
  ConsumerState<MembershipFormDialog> createState() => _MembershipFormDialogState();
}

class _MembershipFormDialogState extends ConsumerState<MembershipFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedUserId;
  int? _selectedTypeId;
  bool _isSubmitting = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedUserId = widget.item!.userId;
      _selectedTypeId = widget.item!.membershipTypeId;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && (_selectedUserId == null || _selectedTypeId == null)) return;

    setState(() => _isSubmitting = true);

    try {
      if (_isEditing) {
        await ref.read(membershipListProvider.notifier).update(
              widget.item!.id,
              UpdateMembershipRequest(membershipTypeId: _selectedTypeId),
            );
        if (mounted) Navigator.pop(context, true);
      } else {
        final response = await ref.read(membershipServiceProvider).createFromRequest(
              CreateMembershipRequest(
                userId: _selectedUserId!,
                membershipTypeId: _selectedTypeId!,
              ),
            );
        ref.read(membershipListProvider.notifier).load();
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
    final typeLookup = ref.watch(membershipTypeLookupProvider);
    final userLookup = ref.watch(userLookupProvider);

    return AlertDialog(
      title: Text(_isEditing ? 'Uredi članarinu' : 'Nova članarina'),
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
                  error: (e, _) => Text('Greška pri učitavanju korisnika', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              if (!_isEditing) const SizedBox(height: AppSpacing.md),
              typeLookup.when(
                data: (types) => DropdownButtonFormField<int>(
                  initialValue: _selectedTypeId,
                  decoration: const InputDecoration(labelText: 'Tip članarine'),
                  items: types
                      .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTypeId = v),
                  validator: (v) => v == null ? 'Tip članarine je obavezan.' : null,
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text('Greška pri učitavanju tipova', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
