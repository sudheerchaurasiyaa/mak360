import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/account_security_page.dart';
import '../data/firestore_repository.dart';
import '../domain/app_models.dart';
import 'chat_page.dart';
import 'personal_details_page.dart';

class OwnerPortal extends StatefulWidget {
  const OwnerPortal({super.key});

  @override
  State<OwnerPortal> createState() => _OwnerPortalState();
}

class _OwnerPortalState extends State<OwnerPortal> {
  final _repository = FirestoreRepository();
  int _index = 0;
  StreamSubscription<RemoteMessage>? _foregroundMessages;

  @override
  void initState() {
    super.initState();
    _repository.registerMessagingToken();
    _foregroundMessages = FirebaseMessaging.onMessage.listen((message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.notification?.body ?? 'A customer request was updated.',
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _foregroundMessages?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        _OwnerDashboard(openRequests: () => setState(() => _index = 1)),
        const _OwnerRequestsPage(),
        const _OwnerCustomersPage(),
        const _OwnerAccountPage(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Requests',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Customers',
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

class _OwnerDashboard extends StatelessWidget {
  const _OwnerDashboard({required this.openRequests});
  final VoidCallback openRequests;

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const _OwnerHeader(
          'MAK360 Owner',
          'Live wash-center operations',
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _OwnerNotificationsPage(),
              ),
            ),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: StreamBuilder<List<WashBooking>>(
        stream: repository.ownerBookings(),
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? const <WashBooking>[];
          final active = bookings
              .where(
                (booking) =>
                    !{'completed', 'cancelled'}.contains(booking.status),
              )
              .length;
          final pickup = bookings
              .where(
                (booking) =>
                    booking.pickupRequested &&
                    !{'completed', 'cancelled'}.contains(booking.status),
              )
              .length;
          final completed = bookings
              .where((booking) => booking.status == 'completed')
              .length;
          final revenue = bookings
              .where((booking) => booking.status == 'completed')
              .fold<int>(0, (sum, booking) => sum + booking.price);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Today at a glance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _Metric(
                    icon: Icons.pending_actions,
                    value: '$active',
                    label: 'Active requests',
                    color: AppColors.blue,
                  ),
                  _Metric(
                    icon: Icons.local_shipping_outlined,
                    value: '$pickup',
                    label: 'Pickups pending',
                    color: Colors.orange,
                  ),
                  _Metric(
                    icon: Icons.task_alt,
                    value: '$completed',
                    label: 'Completed',
                    color: AppColors.success,
                  ),
                  _Metric(
                    icon: Icons.currency_rupee,
                    value: '₹$revenue',
                    label: 'Completed value',
                    color: Colors.deepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Priority queue',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: openRequests,
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (bookings.isEmpty)
                const _OwnerEmpty(
                  text: 'New customer requests will appear here.',
                )
              else
                ...bookings
                    .where(
                      (booking) =>
                          !{'completed', 'cancelled'}.contains(booking.status),
                    )
                    .take(4)
                    .map((booking) => _CompactRequest(booking: booking)),
            ],
          );
        },
      ),
    );
  }
}

class _OwnerRequestsPage extends StatefulWidget {
  const _OwnerRequestsPage();

  @override
  State<_OwnerRequestsPage> createState() => _OwnerRequestsPageState();
}

class _OwnerRequestsPageState extends State<_OwnerRequestsPage> {
  final _repository = FirestoreRepository();
  String _filter = 'active';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _OwnerHeader(
        'Customer requests',
        'Chat and process every status',
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Center(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.blue.withAlpha(45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    size: 19,
                    color: AppColors.blue,
                  ),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      isDense: true,
                      borderRadius: BorderRadius.circular(14),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active requests'),
                        ),
                        DropdownMenuItem(
                          value: 'pickup',
                          child: Text('Pickup requests'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(value: 'all', child: Text('All')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _filter = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<WashBooking>>(
            stream: _repository.ownerBookings(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Could not load requests: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final filtered = snapshot.data!.where((booking) {
                return switch (_filter) {
                  'active' => !{
                    'completed',
                    'cancelled',
                  }.contains(booking.status),
                  'pickup' =>
                    booking.pickupRequested &&
                        !{'completed', 'cancelled'}.contains(booking.status),
                  'completed' => booking.status == 'completed',
                  _ => true,
                };
              }).toList();
              if (filtered.isEmpty) {
                return const _OwnerEmpty(text: 'No requests in this view.');
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (context, index) =>
                    _OwnerRequestCard(booking: filtered[index]),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _OwnerRequestCard extends StatelessWidget {
  const _OwnerRequestCard({required this.booking});
  final WashBooking booking;

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.paleBlue,
                  child: Text(
                    booking.customerName.isEmpty
                        ? '?'
                        : booking.customerName[0],
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
                        booking.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        booking.customerPhone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      Text('${booking.vehicleNumber} • ${booking.vehicleType}'),
                    ],
                  ),
                ),
                Text(
                  '₹${booking.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              booking.serviceName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '${booking.scheduledAt.day}/${booking.scheduledAt.month}/${booking.scheduledAt.year} at ${_clock(booking.scheduledAt)}',
            ),
            if (booking.pickupRequested) ...[
              const SizedBox(height: 7),
              Text(
                'Pickup: ${booking.pickupAddress.isEmpty ? 'GPS location attached' : booking.pickupAddress}',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (booking.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text('Note: ${booking.notes}'),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: bookingStatuses.contains(booking.status)
                  ? booking.status
                  : 'requested',
              decoration: const InputDecoration(
                labelText: 'Request status',
                prefixIcon: Icon(Icons.sync),
              ),
              items: bookingStatuses
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(statusLabel(status)),
                    ),
                  )
                  .toList(),
              onChanged: (status) {
                if (status != null && status != booking.status) {
                  repository.updateBookingStatus(booking.id, status);
                }
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(booking: booking),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat'),
                  ),
                ),
                if (booking.pickupLatitude != null &&
                    booking.pickupLongitude != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _pickupDirections(
                        booking.pickupLatitude!,
                        booking.pickupLongitude!,
                      ),
                      icon: const Icon(Icons.directions),
                      label: const Text('Pickup route'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerCustomersPage extends StatelessWidget {
  const _OwnerCustomersPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _OwnerHeader(
        'Customers',
        'Derived securely from wash requests',
      ),
    ),
    body: StreamBuilder<List<WashBooking>>(
      stream: FirestoreRepository().ownerBookings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final latestByCustomer = <String, WashBooking>{};
        for (final booking in snapshot.data!) {
          latestByCustomer.putIfAbsent(booking.customerId, () => booking);
        }
        final customers = latestByCustomer.values.toList();
        if (customers.isEmpty) {
          return const _OwnerEmpty(
            text: 'Customers appear after their first request.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final item = customers[index];
            final count = snapshot.data!
                .where((booking) => booking.customerId == item.customerId)
                .length;
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: AppColors.blue,
                  child: Text(
                    item.customerName.isEmpty ? '?' : item.customerName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  item.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${item.customerPhone}\n${item.vehicleNumber} • $count request${count == 1 ? '' : 's'}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    ),
  );
}

class _OwnerAccountPage extends StatelessWidget {
  const _OwnerAccountPage();

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const _OwnerHeader(
          'Center account',
          'Protected MAK360 owner access',
        ),
      ),
      body: StreamBuilder(
        stream: repository.profile(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? const <String, dynamic>{};
          final name = data['displayName'] as String? ?? AppConfig.centerName;
          final email = FirebaseAuth.instance.currentUser?.email ?? '';
          final initial = name.trim().isEmpty
              ? 'M'
              : name.trim()[0].toUpperCase();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.blue,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                AppConfig.centerName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.blue,
                      ),
                      title: const Text('Personal details'),
                      subtitle: Text(
                        [
                          email,
                          data['phone'] as String? ?? '',
                        ].where((item) => item.isNotEmpty).join(' • '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final message = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PersonalDetailsPage(
                              initial: data,
                              includeAddress: false,
                            ),
                          ),
                        );
                        if (context.mounted && message != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.blue,
                      ),
                      title: const Text('Profile photo'),
                      subtitle: const Text('Upload your own profile picture'),
                      trailing: const Chip(label: Text('Coming soon')),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile photo upload is coming soon.'),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.lock_reset,
                        color: AppColors.blue,
                      ),
                      title: const Text('Change password'),
                      subtitle: const Text(
                        'Reset your password securely in-app',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.map_outlined,
                        color: AppColors.blue,
                      ),
                      title: const Text('Open public Google Maps place'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => launchUrl(
                        Uri.parse(AppConfig.centerMapsUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.security, color: AppColors.success),
                      title: Text('Owner role protected'),
                      subtitle: Text(
                        'Customers cannot grant themselves owner access.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Signed in as $email',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => AuthService().signOut(),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OwnerNotificationsPage extends StatelessWidget {
  const _OwnerNotificationsPage();

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Owner notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: repository.notifications(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const _OwnerEmpty(text: 'No new notifications.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: item['read'] == true ? Colors.white : AppColors.paleBlue,
                child: ListTile(
                  title: Text(
                    item['title'] as String? ?? 'MAK360 update',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(item['body'] as String? ?? ''),
                  onTap: () =>
                      repository.markNotificationRead(item['id'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CompactRequest extends StatelessWidget {
  const _CompactRequest({required this.booking});
  final WashBooking booking;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(
        backgroundColor: AppColors.paleBlue,
        child: Icon(
          booking.pickupRequested
              ? Icons.local_shipping_outlined
              : Icons.local_car_wash_outlined,
          color: AppColors.blue,
        ),
      ),
      title: Text(
        booking.customerName,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text('${booking.vehicleNumber} • ${booking.serviceName}'),
      trailing: Chip(label: Text(statusLabel(booking.status))),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class _OwnerHeader extends StatelessWidget {
  const _OwnerHeader(this.title, this.subtitle);
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title),
      Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ),
    ],
  );
}

class _OwnerEmpty extends StatelessWidget {
  const _OwnerEmpty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 56, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

Future<void> _pickupDirections(double latitude, double longitude) => launchUrl(
  Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$latitude%2C$longitude&travelmode=driving',
  ),
  mode: LaunchMode.externalApplication,
);

String _clock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '$hour:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
}
