import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/wash_service.dart';

Route<void> customerPageRoute(Widget page) =>
    MaterialPageRoute(builder: (_) => page);

class CustomerNotificationsPage extends StatefulWidget {
  const CustomerNotificationsPage({super.key});
  @override
  State<CustomerNotificationsPage> createState() =>
      _CustomerNotificationsPageState();
}

class CustomerEditProfilePage extends StatelessWidget {
  const CustomerEditProfilePage({super.key});
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Edit profile',
    subtitle: 'Personal and contact information',
    actions: [
      TextButton(
        onPressed: () {
          _message(context, 'Profile saved successfully.');
          Navigator.pop(context);
        },
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.blue,
            child: Text(
              'RS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: 'Full name',
            hintText: 'Riya Sharma',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Verified mobile',
            hintText: '+91 98XXXXXX97',
            prefixIcon: Icon(Icons.verified_user_outlined),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email address',
            hintText: 'riya@example.com',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
      ],
    ),
  );
}

class _CustomerNotificationsPageState extends State<CustomerNotificationsPage> {
  final unread = <bool>[true, true, false, false];
  @override
  Widget build(BuildContext context) {
    const titles = [
      'Booking confirmed',
      'Wash starts in 30 minutes',
      'New offer available',
      'Payment received',
    ];
    const details = [
      '4 Wheeler Full Wash at 11:00 AM',
      'MAK360 Wash Center is ready for you',
      'Save 10% on 4 Wheeler Full Wash',
      'Rs 400 paid for 4 Wheeler Body Wash',
    ];
    return _Page(
      title: 'Notifications',
      subtitle: 'Booking and account updates',
      actions: [
        TextButton(
          onPressed: () =>
              setState(() => unread.fillRange(0, unread.length, false)),
          child: const Text('Read all', style: TextStyle(color: Colors.white)),
        ),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) => Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: unread[index]
                  ? AppColors.blue
                  : AppColors.paleBlue,
              child: Icon(
                [
                  Icons.check_circle_outline,
                  Icons.schedule,
                  Icons.local_offer_outlined,
                  Icons.receipt_long_outlined,
                ][index],
                color: unread[index] ? Colors.white : AppColors.blue,
              ),
            ),
            title: Text(
              titles[index],
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              '${details[index]}\n${index + 1} hour${index == 0 ? '' : 's'} ago',
            ),
            isThreeLine: true,
            trailing: unread[index]
                ? const CircleAvatar(radius: 4, backgroundColor: AppColors.blue)
                : null,
            onTap: () => setState(() => unread[index] = false),
          ),
        ),
      ),
    );
  }
}

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});
  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final vehicles = <(String, String, VehicleClass)>[
    ('Honda City', 'DL 8C AB 2481', VehicleClass.fourWheeler),
  ];
  void addVehicle() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _VehicleForm(
      onSave: (name, number, type) {
        setState(() => vehicles.add((name, number, type)));
        Navigator.pop(context);
      },
    ),
  );
  @override
  Widget build(BuildContext context) => _Page(
    title: 'My vehicles',
    subtitle: 'Vehicles available for wash booking',
    actions: [IconButton(onPressed: addVehicle, icon: const Icon(Icons.add))],
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...vehicles.indexed.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: AppColors.paleBlue,
                  child: Icon(
                    entry.$2.$3 == VehicleClass.fourWheeler
                        ? Icons.directions_car
                        : Icons.local_shipping,
                    color: AppColors.blue,
                  ),
                ),
                title: Text(
                  entry.$2.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${entry.$2.$2}${entry.$1 == 0 ? ' | Primary vehicle' : ''}',
                ),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'primary',
                      child: Text('Make primary'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Remove vehicle'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      setState(() => vehicles.removeAt(entry.$1));
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: addVehicle,
          icon: const Icon(Icons.add),
          label: const Text('Add another vehicle'),
        ),
      ],
    ),
  );
}

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});
  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final addresses = <(String, String)>[
    ('Home', '24, Lake View Road, Bengaluru 560001'),
    ('Office', 'MG Road, Bengaluru 560025'),
  ];
  void addAddress() => showDialog(
    context: context,
    builder: (_) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Add address'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Complete address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(
                  () => addresses.add(('Other', controller.text.trim())),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Saved addresses',
    subtitle: 'Pickup and contact locations',
    actions: [
      IconButton(
        onPressed: addAddress,
        icon: const Icon(Icons.add_location_alt_outlined),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...addresses.map(
          (address) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.paleBlue,
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.blue,
                  ),
                ),
                title: Text(
                  address.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(address.$2),
                trailing: const Icon(Icons.edit_outlined),
                onTap: addAddress,
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: addAddress,
          icon: const Icon(Icons.add),
          label: const Text('Add address'),
        ),
      ],
    ),
  );
}

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});
  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  int selected = 0;
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Payment methods',
    subtitle: 'Secure ways to pay for your wash',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: RadioGroup<int>(
            groupValue: selected,
            onChanged: (value) => setState(() => selected = value ?? 0),
            child: Column(
              children: [
                RadioListTile(
                  value: 0,
                  title: const Text(
                    'UPI',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text('riya@upi'),
                  secondary: const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.blue,
                  ),
                ),
                const Divider(height: 1),
                RadioListTile(
                  value: 1,
                  title: const Text(
                    'Pay at wash center',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text('Cash, card, or UPI after service'),
                  secondary: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add payment method'),
              content: const TextField(
                decoration: InputDecoration(labelText: 'UPI ID'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Verify'),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.add_card),
          label: const Text('Add UPI ID'),
        ),
        const SizedBox(height: 22),
        const _Info(
          icon: Icons.shield_outlined,
          title: 'Payments are protected',
          text: 'MAK360 does not store your UPI PIN or banking credentials.',
        ),
      ],
    ),
  );
}

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Help & support',
    subtitle: 'We are here to help',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Info(
          icon: Icons.support_agent,
          title: 'MAK360 customer care',
          text: 'Available daily from 7:00 AM to 9:00 PM.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _message(context, 'Calling customer care...'),
                icon: const Icon(Icons.call_outlined),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _message(context, 'Starting support chat...'),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Frequently asked questions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...[
          'How do I reschedule a booking?',
          'What happens if I arrive late?',
          'Which vehicles are supported?',
          'How can I request a refund?',
        ].map(
          (question) => ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Open your booking details and use the available action. For urgent changes, contact the wash center directly.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Privacy & terms',
    subtitle: 'How MAK360 protects your information',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _LegalSection(
          'Privacy policy',
          'We collect only the account, vehicle, booking, and payment-reference information required to provide wash services. Contact details are shared with the selected wash center for confirmed bookings.',
        ),
        _LegalSection(
          'Terms of service',
          'Bookings are subject to slot availability and vehicle eligibility. Prices shown at confirmation include the selected service only. Additional work requires customer approval.',
        ),
        _LegalSection(
          'Cancellation policy',
          'Bookings may be cancelled or rescheduled before the slot begins. Refund timing depends on the original payment method.',
        ),
        _LegalSection(
          'Data controls',
          'You may request account export or deletion through MAK360 customer support.',
        ),
      ],
    ),
  );
}

class DirectionsPage extends StatelessWidget {
  const DirectionsPage({super.key});
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Directions',
    subtitle: 'Attibele, Bangalore 562107',
    child: Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFDCEEF2),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                const Positioned(
                  left: 36,
                  top: 52,
                  child: _MapLabel('Your location', Icons.my_location),
                ),
                const Positioned(
                  right: 34,
                  bottom: 90,
                  child: _MapLabel('MAK360', Icons.water_drop),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.paleBlue,
                      child: Icon(Icons.storefront, color: AppColors.blue),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAK360 Wash Center',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Opp. to Hotel Ramee Guestline, NH 7, Hosur Road, Attibele Indl Area, Bangalore 562107',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'NH 7',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      _message(context, 'Opening turn-by-turn navigation...'),
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Start navigation'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
  });
  final String title, subtitle;
  final Widget child;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: actions,
    ),
    body: SafeArea(child: child),
  );
}

class _VehicleForm extends StatefulWidget {
  const _VehicleForm({required this.onSave});
  final void Function(String, String, VehicleClass) onSave;
  @override
  State<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<_VehicleForm> {
  VehicleClass type = VehicleClass.fourWheeler;
  final name = TextEditingController();
  final number = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add vehicle',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Vehicle name or model'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: number,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Registration number'),
        ),
        const SizedBox(height: 12),
        SegmentedButton<VehicleClass>(
          segments: const [
            ButtonSegment(
              value: VehicleClass.fourWheeler,
              label: Text('4 Wheeler'),
            ),
            ButtonSegment(
              value: VehicleClass.heavyVehicle,
              label: Text('Heavy'),
            ),
          ],
          selected: {type},
          onSelectionChanged: (value) => setState(() => type = value.first),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () {
            if (name.text.trim().isNotEmpty && number.text.trim().isNotEmpty) {
              widget.onSave(name.text.trim(), number.text.trim(), type);
            }
          },
          child: const Text('Save vehicle'),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title, text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.paleBlue,
            child: Icon(icon, color: AppColors.blue),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  text,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LegalSection extends StatelessWidget {
  const _LegalSection(this.title, this.text);
  final String title, text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(height: 1.55, color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.text, this.icon);
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.blue),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(70, 90)
      ..cubicTo(
        size.width * .2,
        size.height * .45,
        size.width * .75,
        size.height * .35,
        size.width - 70,
        size.height - 120,
      );
    canvas.drawPath(path, road);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _message(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
