import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../wash/domain/wash_service.dart';
import '../../wash/presentation/customer_app.dart';
import '../../wash/presentation/owner_app.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 58,
              maxWidth: 520,
            ),
            child: Column(
              children: [
                const SizedBox(height: 28),
                Container(
                  width: 128,
                  height: 128,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: .14),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const AppLogo(size: 100),
                ),
                const SizedBox(height: 28),
                Text(
                  'Welcome to MAK360',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional water wash for every vehicle',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 36),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'CONTINUE AS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _RoleButton(
                          icon: Icons.directions_car_outlined,
                          title: 'Customer',
                          subtitle: 'Book a wash for your vehicle',
                          filled: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerAccessScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _RoleButton(
                          icon: Icons.storefront_outlined,
                          title: 'Wash center owner',
                          subtitle: 'Manage bookings and services',
                          filled: false,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OwnerLoginScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.only(top: 28),
                  child: Text(
                    'By continuing, you agree to the Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.muted,
                    ),
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

class CustomerAccessScreen extends StatefulWidget {
  const CustomerAccessScreen({super.key});
  @override
  State<CustomerAccessScreen> createState() => _CustomerAccessScreenState();
}

class _CustomerAccessScreenState extends State<CustomerAccessScreen> {
  final formKey = GlobalKey<FormState>();
  final phone = TextEditingController();
  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Create your account',
    subtitle: 'Book water wash slots in a few taps',
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Mobile number',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) =>
                value?.length == 10 ? null : 'Enter a valid 10-digit number',
            decoration: const InputDecoration(
              prefixText: '+91  ',
              hintText: '10-digit number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'An OTP will be sent to this number for verification.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpScreen(phone: phone.text),
                  ),
                );
              }
            },
            child: const Text('Create account & send OTP'),
          ),
          const SizedBox(height: 14),
          const Text(
            'Customer accounts are created only after mobile verification.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});
  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool hidden = true;
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Owner login',
    subtitle: 'Access your wash center dashboard',
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter your registered email',
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            obscureText: hidden,
            validator: (value) =>
                (value?.length ?? 0) >= 6 ? null : 'Enter your password',
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(
                      hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Contact MAK360 support to reset the owner password.',
                  ),
                ),
              ),
              child: const Text('Forgot password?'),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OwnerShell()),
                  (_) => false,
                );
              }
            },
            child: const Text('Login to dashboard'),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Owner accounts are issued by MAK360. New owner registration is not available in the app.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final codes = List.generate(4, (_) => TextEditingController());
  @override
  void dispose() {
    for (final code in codes) {
      code.dispose();
    }
    super.dispose();
  }

  void verify() {
    if (codes.any((code) => code.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the complete OTP.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify OTP')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: AppColors.paleBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phonelink_lock_outlined,
                size: 46,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Enter verification code',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a 4-digit OTP to\n+91 ${widget.phone}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      'ONE-TIME PASSWORD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        4,
                        (index) => SizedBox(
                          width: 58,
                          child: TextField(
                            controller: codes[index],
                            autofocus: index == 0,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('A new OTP has been sent.'),
                            ),
                          ),
                      child: const Text("Didn't receive the OTP? Resend"),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: verify,
                      child: const Text('Verify & continue'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keep this OTP confidential. MAK360 will never ask for your OTP.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class CustomerSetupScreen extends StatefulWidget {
  const CustomerSetupScreen({super.key});
  @override
  State<CustomerSetupScreen> createState() => _CustomerSetupScreenState();
}

class _CustomerSetupScreenState extends State<CustomerSetupScreen> {
  VehicleClass vehicleClass = VehicleClass.fourWheeler;
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    canPop: false,
    title: 'Complete your profile',
    subtitle: 'Tell us about the vehicle you usually wash',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Vehicle registration number',
            prefixIcon: Icon(Icons.pin_outlined),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Vehicle type',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SegmentedButton<VehicleClass>(
          segments: const [
            ButtonSegment(
              value: VehicleClass.fourWheeler,
              icon: Icon(Icons.directions_car_outlined),
              label: Text('4 Wheeler'),
            ),
            ButtonSegment(
              value: VehicleClass.heavyVehicle,
              icon: Icon(Icons.local_shipping_outlined),
              label: Text('Heavy'),
            ),
          ],
          selected: {vehicleClass},
          onSelectionChanged: (value) =>
              setState(() => vehicleClass = value.first),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CustomerShell()),
            (_) => false,
          ),
          child: const Text('Open MAK360'),
        ),
      ],
    ),
  );
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.canPop = true,
  });
  final String title, subtitle;
  final Widget child;
  final bool canPop;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: canPop,
      title: const Text('MAK360'),
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 76)),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 26),
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

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final bool filled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: filled ? AppColors.blue : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: filled ? AppColors.blue : AppColors.border),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: filled
                  ? Colors.white.withValues(alpha: .18)
                  : AppColors.paleBlue,
              child: Icon(icon, color: filled ? Colors.white : AppColors.blue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: filled ? Colors.white : AppColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: filled ? Colors.white70 : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: filled ? Colors.white : AppColors.blue,
            ),
          ],
        ),
      ),
    ),
  );
}
