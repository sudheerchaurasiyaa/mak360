import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../wash/presentation/customer_portal.dart';
import '../../wash/presentation/owner_portal.dart';
import '../data/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.userChanges(),
    builder: (context, authSnapshot) {
      if (authSnapshot.connectionState == ConnectionState.waiting) {
        return const _LoadingScreen();
      }
      final user = authSnapshot.data;
      if (user == null) return const SignInScreen();
      return _RoleGate(user: user);
    },
  );
}

class _RoleGate extends StatelessWidget {
  const _RoleGate({required this.user});

  final User user;

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _ErrorScreen(
          message: 'Could not load your profile: ${snapshot.error}',
        );
      }
      if (!snapshot.hasData) return const _LoadingScreen();
      final data = snapshot.data!.data();
      if (data == null) {
        return _ErrorScreen(
          message:
              'Your account profile is missing. Please sign out and sign in again.',
          action: () => AuthService().signOut(),
        );
      }
      if (data['role'] == 'owner') return const OwnerPortal();
      final usesPassword = user.providerData.any(
        (provider) => provider.providerId == 'password',
      );
      if (!user.emailVerified && usesPassword) {
        return VerifyEmailScreen(user: user);
      }
      return const CustomerPortal();
    },
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _busy = false;
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _showError(context, friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthPage(
    title: 'Welcome to MAK360',
    subtitle: 'Sign in once to manage washes, pickup and messages',
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter a valid email address',
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: _hidden,
            autofillHints: const [AutofillHints.password],
            validator: (value) =>
                (value?.isNotEmpty ?? false) ? null : 'Enter your password',
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
              child: const Text('Forgot password?'),
            ),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _run(() => _auth.signIn(_email.text, _password.text));
                    }
                  },
            child: _busy
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Sign in'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR'),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _run(_auth.signInWithGoogle),
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Continue with Google'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _busy
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
            child: const Text('New customer? Create an account'),
          ),
          const Text(
            'Wash-center owners use the same sign-in. Owner accounts are provisioned by MAK360 and cannot self-register.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _password]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    var completed = false;
    try {
      await AuthService().register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        phone: _phone.text,
      );
      completed = true;
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) _showError(context, friendlyAuthError(error));
    } finally {
      if (mounted && !completed) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthPage(
    canPop: true,
    title: 'Create customer account',
    subtitle: 'Your bookings, vehicles and messages stay in one secure account',
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            validator: _required,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter a valid email address',
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                (value ?? '').replaceAll(RegExp(r'\D'), '').length >= 10
                ? null
                : 'Enter a valid mobile number',
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            validator: (value) =>
                (value?.length ?? 0) >= 8 ? null : 'Use at least 8 characters',
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? 'Creating account…' : 'Create account'),
          ),
          const SizedBox(height: 10),
          const Text(
            'We will send a verification link to your email before your first booking.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthPage(
    canPop: true,
    title: 'Reset password',
    subtitle: 'Firebase will send a secure password-reset link',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _sent
              ? null
              : () async {
                  try {
                    await AuthService().sendPasswordReset(_email.text);
                    if (mounted) setState(() => _sent = true);
                  } catch (error) {
                    if (mounted) {
                      _showError(this.context, friendlyAuthError(error));
                    }
                  }
                },
          child: Text(_sent ? 'Reset link sent' : 'Send reset link'),
        ),
      ],
    ),
  );
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.user});

  final User user;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => _AuthPage(
    onBack: () => AuthService().signOut(),
    title: 'Verify your email',
    subtitle:
        'A verification link was sent to ${widget.user.email ?? 'your inbox'}',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_unread_outlined,
          size: 64,
          color: AppColors.blue,
        ),
        const SizedBox(height: 16),
        const Text(
          'Open the link, then return here and tap “I have verified”. Check spam if it is not in your inbox.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  await AuthService().refreshUser();
                  if (mounted) setState(() => _busy = false);
                },
          child: const Text('I have verified'),
        ),
        TextButton(
          onPressed: () => AuthService().resendVerification(),
          child: const Text('Resend verification email'),
        ),
        TextButton(
          onPressed: () => AuthService().signOut(),
          child: const Text('Use another account'),
        ),
      ],
    ),
  );
}

class _AuthPage extends StatelessWidget {
  const _AuthPage({
    required this.title,
    required this.subtitle,
    required this.child,
    this.canPop = false,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool canPop;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: canPop || onBack != null
        ? AppBar(
            title: const Text('MAK360'),
            leading: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    tooltip: 'Back to sign in',
                    icon: const Icon(Icons.arrow_back),
                  ),
          )
        : null,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const AppLogo(size: 88),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, this.action});
  final String message;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: action ?? () => AuthService().signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    ),
  );
}

String? _required(String? value) =>
    (value?.trim().isNotEmpty ?? false) ? null : 'Required';

void _showError(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
