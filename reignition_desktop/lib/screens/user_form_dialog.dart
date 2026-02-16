import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reignition_core/reignition_core.dart';

import '../constants/app_spacing.dart';
import '../providers/user_provider.dart';
import '../widgets/shared/app_snackbars.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final UserResponse item;

  const UserFormDialog({super.key, required this.item});

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late int _selectedRole;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.item.username);
    _firstNameController = TextEditingController(text: widget.item.firstName);
    _lastNameController = TextEditingController(text: widget.item.lastName);
    _emailController = TextEditingController(text: widget.item.email);
    _phoneController = TextEditingController(text: widget.item.phoneNumber ?? '');
    _selectedRole = widget.item.role;
    _isActive = widget.item.isActive;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(userListProvider.notifier).update(
            widget.item.id,
            UpdateUserRequest(
              username: _usernameController.text.trim(),
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              role: _selectedRole,
              isActive: _isActive,
            ),
          );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) AppSnackbars.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uredi korisnika'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Ime'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ime je obavezno.';
                        if (v.trim().length < 2) return 'Ime mora imati najmanje 2 karaktera.';
                        if (v.trim().length > 50) return 'Ime može imati maksimalno 50 karaktera.';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Prezime'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Prezime je obavezno.';
                        if (v.trim().length < 2) return 'Prezime mora imati najmanje 2 karaktera.';
                        if (v.trim().length > 50) return 'Prezime može imati maksimalno 50 karaktera.';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Korisničko ime'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Korisničko ime je obavezno.';
                  if (v.trim().length < 3) return 'Korisničko ime mora imati najmanje 3 karaktera.';
                  if (v.trim().length > 50) return 'Korisničko ime može imati maksimalno 50 karaktera.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email je obavezan.';
                  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                  if (!emailRegex.hasMatch(v.trim())) return 'Email format nije validan.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon (opcionalno)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Uloga'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Admin')),
                        DropdownMenuItem(value: 1, child: Text('Član')),
                      ],
                      onChanged: (v) => setState(() => _selectedRole = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Aktivan'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      contentPadding: EdgeInsets.zero,
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
              : const Text('Sačuvaj izmjene'),
        ),
      ],
    );
  }
}
