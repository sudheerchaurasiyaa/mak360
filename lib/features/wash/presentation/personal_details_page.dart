import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/data/auth_service.dart';
import '../data/firestore_repository.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({
    super.key,
    required this.initial,
    this.includeAddress = true,
  });

  final Map<String, dynamic> initial;
  final bool includeAddress;

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial['displayName'] as String? ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.initial['phone'] as String? ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.email ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: widget.initial['address'] as String? ?? '',
  );
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Personal details')),
    body: Form(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email address',
              helperText: 'A verification link is sent when the email changes.',
            ),
          ),
          if (widget.includeAddress) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Default pickup address',
              ),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_busy ? 'Saving…' : 'Save details'),
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    final email = _email.text.trim();
    if (_name.text.trim().isEmpty || !email.contains('@')) {
      _message('Enter a valid name and email address.', error: true);
      return;
    }
    setState(() => _busy = true);
    var completed = false;
    try {
      await FirestoreRepository().updateProfile(
        displayName: _name.text,
        phone: _phone.text,
        address: _address.text,
      );
      final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      final emailChanged = email.toLowerCase() != currentEmail.toLowerCase();
      if (emailChanged) {
        await AuthService().requestEmailChange(email);
      }
      if (!mounted) return;
      completed = true;
      Navigator.pop(
        context,
        emailChanged
            ? 'Details saved. Verify the link sent to $email to change your sign-in email.'
            : 'Personal details updated.',
      );
    } catch (error) {
      if (mounted) _message(friendlyAuthError(error), error: true);
    } finally {
      if (mounted && !completed) setState(() => _busy = false);
    }
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }
}
