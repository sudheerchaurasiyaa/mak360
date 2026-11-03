import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/presentation/auth_flow.dart';
import '../domain/wash_service.dart';
import 'owner_pages.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});
  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: index,
      children: const [
        OwnerDashboard(),
        OwnerBookingsPage(),
        OwnerServicesPage(),
        OwnerAccountPage(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Center',
        ),
      ],
    ),
  );
}

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          AppLogo(size: 38),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAK360 Wash Center',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Owner dashboard | Open today',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.push(
            context,
            ownerPageRoute(const OwnerNotificationsPage()),
          ),
          icon: Badge(child: Icon(Icons.notifications_none)),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Good afternoon, Arjun',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        const Text(
          'Here is how your wash center is doing today.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 22),
        const Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.calendar_today_outlined,
                value: '12',
                label: 'Bookings',
                color: AppColors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.currency_rupee,
                value: '8,490',
                label: 'Revenue',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.pending_actions_outlined,
                value: '4',
                label: 'Waiting',
                color: Color(0xFFD77B00),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.star_outline,
                value: '4.8',
                label: 'Rating',
                color: Color(0xFF7B61A8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _OwnerTitle('Today\'s schedule', 'Next wash slots'),
        const SizedBox(height: 12),
        ..._ownerBookings
            .take(3)
            .map((booking) => _BookingCard(booking: booking)),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.paleBlue,
                  child: Icon(Icons.water_drop, color: AppColors.blue),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water used today',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '2,840 L | 12% below average',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    ownerPageRoute(const WaterUsagePage()),
                  ),
                  child: const Text('Details'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});
  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  int filter = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _OwnerHeader('Bookings', 'Manage customers and wash slots'),
    ),
    body: Column(
      children: [
        SizedBox(
          height: 58,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: filter == index,
                  onSelected: (_) => setState(() => filter = index),
                  label: Text(['Today', 'Upcoming', 'Completed'][index]),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: _ownerBookings
                .map(
                  (booking) => _BookingCard(booking: booking, detailed: true),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class OwnerServicesPage extends StatelessWidget {
  const OwnerServicesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _OwnerHeader(
        'Services & prices',
        'Control what customers can book',
      ),
      actions: [
        IconButton(
          onPressed: () => _serviceEditor(context),
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: washServices
          .map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.paleBlue,
                    child: Icon(service.icon, color: AppColors.blue),
                  ),
                  title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${service.durationMinutes} min | Rs ${service.price}',
                  ),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit service')),
                      PopupMenuItem(
                        value: 'pause',
                        child: Text('Pause bookings'),
                      ),
                    ],
                    onSelected: (_) => _serviceEditor(context),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class OwnerAccountPage extends StatefulWidget {
  const OwnerAccountPage({super.key});
  @override
  State<OwnerAccountPage> createState() => _OwnerAccountPageState();
}

class _OwnerAccountPageState extends State<OwnerAccountPage> {
  bool open = true;
  bool autoConfirm = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _OwnerHeader(
        'Wash center',
        'Business profile and availability',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.blue,
              child: Icon(Icons.storefront, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAK360 Wash Center',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Verified | Attibele, Bangalore',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit wash center',
              onPressed: () => Navigator.push(
                context,
                ownerPageRoute(const CenterProfilePage()),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: open,
                onChanged: (value) => setState(() => open = value),
                title: const Text(
                  'Center open for bookings',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  open
                      ? 'Customers can see available slots'
                      : 'New bookings are paused',
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: autoConfirm,
                onChanged: (value) => setState(() => autoConfirm = value),
                title: const Text(
                  'Auto-confirm bookings',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Confirm bookings when a slot is available',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...[
          (Icons.schedule_outlined, 'Business hours'),
          (Icons.event_available_outlined, 'Slot availability'),
          (Icons.people_outline, 'Staff members'),
          (Icons.photo_library_outlined, 'Wash gallery'),
          (Icons.bar_chart_outlined, 'Reports and earnings'),
          (Icons.support_agent, 'Owner support'),
        ].map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(item.$1, color: AppColors.blue),
            title: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              ownerPageRoute(switch (item.$2) {
                'Business hours' => const BusinessHoursPage(),
                'Slot availability' => const SlotManagementPage(),
                'Staff members' => const StaffPage(),
                'Wash gallery' => const WashGalleryPage(),
                'Reports and earnings' => const ReportsPage(),
                _ => const OwnerSupportPage(),
              }),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            'Owner logout',
            style: TextStyle(color: Colors.redAccent),
          ),
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (_) => false,
          ),
        ),
      ],
    ),
  );
}

class OwnerBooking {
  const OwnerBooking(
    this.customer,
    this.vehicle,
    this.service,
    this.time,
    this.price,
    this.status,
  );
  final String customer, vehicle, service, time, status;
  final int price;
}

const _ownerBookings = [
  OwnerBooking(
    'Riya Sharma',
    'Honda City | DL 8C AB 2481',
    '4 Wheeler Full Wash',
    '11:00 AM',
    600,
    'Confirmed',
  ),
  OwnerBooking(
    'Mohit Verma',
    'Toyota Fortuner | KA 01 MR 9211',
    '4 Wheeler Body Wash',
    '12:30 PM',
    400,
    'Waiting',
  ),
  OwnerBooking(
    'S.K. Logistics',
    'Cargo Truck | MH 12 TX 4098',
    'Heavy Vehicle',
    '2:00 PM',
    1200,
    'Confirmed',
  ),
  OwnerBooking(
    'Neha Singh',
    'Hyundai i20 | KA 05 NS 1182',
    '4 Wheeler Body Wash',
    '4:30 PM',
    400,
    'Confirmed',
  ),
];

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, this.detailed = false});
  final OwnerBooking booking;
  final bool detailed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.paleBlue,
                  child: Text(
                    booking.customer[0],
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customer,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        booking.vehicle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        booking.service,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.time,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.blue,
                      ),
                    ),
                    Text(
                      'Rs ${booking.price}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            if (detailed) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Chip(label: Text(booking.status)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling customer...')),
                    ),
                    icon: const Icon(Icons.call_outlined),
                  ),
                  FilledButton.tonal(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: const Text('Mark in progress'),
                              onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                              leading: const Icon(Icons.task_alt),
                              title: const Text('Mark completed'),
                              onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                              leading: const Icon(Icons.schedule),
                              title: const Text('Reschedule'),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value, label;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class _OwnerTitle extends StatelessWidget {
  const _OwnerTitle(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    ],
  );
}

class _OwnerHeader extends StatelessWidget {
  const _OwnerHeader(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

void _serviceEditor(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => Padding(
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
        Row(
          children: [
            const Expanded(
              child: Text(
                'Service editor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const TextField(decoration: InputDecoration(labelText: 'Service name')),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Minutes'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Save service'),
        ),
      ],
    ),
  ),
);
