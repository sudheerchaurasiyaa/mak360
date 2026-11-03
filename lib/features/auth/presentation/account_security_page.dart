import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _hideCurrent = true;
  bool _hideNext = true;

  bool get _hasPasswordProvider =>
      FirebaseAuth.instance.currentUser?.providerData.any(
        (provider) => provider.providerId == 'password',
      ) ??
      false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    var completed = false;
    try {
      await AuthService().changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      completed = true;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyAuthError(error)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted && !completed) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Change password')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (!_hasPasswordProvider)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: AppColors.blue, size: 34),
                  SizedBox(height: 10),
                  Text(
                    'This account signs in with Google. Password changes are managed by Google.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _current,
                  obscureText: _hideCurrent,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) => (value?.isNotEmpty ?? false)
                      ? null
                      : 'Enter your current password',
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hideCurrent = !_hideCurrent),
                      icon: Icon(
                        _hideCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _next,
                  obscureText: _hideNext,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => (value?.length ?? 0) >= 8
                      ? null
                      : 'Use at least 8 characters',
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.password_outlined),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _hideNext = !_hideNext),
                      icon: Icon(
                        _hideNext
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm,
                  obscureText: _hideNext,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) =>
                      value == _next.text ? null : 'Passwords do not match',
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: Icon(Icons.password_outlined),
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.lock_reset),
                  label: Text(_busy ? 'Changing password…' : 'Change password'),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
