import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/account_security_page.dart';
import '../data/firestore_repository.dart';
import '../domain/app_models.dart';
import '../domain/wash_service.dart';
import 'chat_page.dart';
import 'personal_details_page.dart';

class CustomerPortal extends StatefulWidget {
  const CustomerPortal({super.key});

  @override
  State<CustomerPortal> createState() => _CustomerPortalState();
}

class _CustomerPortalState extends State<CustomerPortal> {
  final _repository = FirestoreRepository();
  int _index = 0;
  WashService _selectedService = washServices.first;
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
            message.notification?.body ?? 'You have a new MAK360 update.',
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
        _CustomerHome(
          onBook: (service) => setState(() {
            _selectedService = service;
            _index = 1;
          }),
        ),
        _BookWashPage(
          initialService: _selectedService,
          onBooked: () => setState(() => _index = 2),
        ),
        const _CustomerBookingsPage(),
        const _CustomerProfilePage(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_car_wash_outlined),
          selectedIcon: Icon(Icons.local_car_wash),
          label: 'Book',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Requests',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class _CustomerHome extends StatelessWidget {
  const _CustomerHome({required this.onBook});
  final ValueChanged<WashService> onBook;

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
                  'MAK360 Car Garage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Wash • pickup • live updates',
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
            MaterialPageRoute(builder: (_) => const _NotificationsPage()),
          ),
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.asset(
                'assets/images/car_wash.png',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE6082F49)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A clean vehicle, without the wait.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Book a slot or ask MAK360 to pick up your vehicle.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: () => onBook(washServices.first),
                      child: const Text('Request a wash'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.paleBlue,
                      child: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConfig.centerName,
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            AppConfig.centerAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openExternal(context, AppConfig.centerMapsUrl),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 19),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'View place',
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _openExternal(context, AppConfig.directionsUrl),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        icon: const Icon(Icons.directions, size: 19),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Directions',
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text('Wash services', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...washServices.map(
          (service) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(10, 6, 16, 6),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  service.image,
                  width: 66,
                  height: 58,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              title: Text(
                service.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${service.durationMinutes} min'),
              trailing: Text(
                '₹${service.price}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.blue,
                ),
              ),
              onTap: () async {
                final selected = await Navigator.push<WashService>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailsPage(service: service),
                  ),
                );
                if (selected != null) onBook(selected);
              },
            ),
          ),
        ),
      ],
    ),
  );
}

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key, required this.service});

  final WashService service;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(service.name)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            service.image,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                service.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text(
              '₹${service.price}',
              style: const TextStyle(
                color: AppColors.blue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          service.description,
          style: const TextStyle(color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.schedule, color: AppColors.blue, size: 20),
            const SizedBox(width: 7),
            Text('Around ${service.durationMinutes} minutes'),
          ],
        ),
        const SizedBox(height: 22),
        Text('What is included', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: service.includes
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, service),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continue to booking'),
        ),
      ],
    ),
  );
}

class _BookWashPage extends StatefulWidget {
  const _BookWashPage({required this.initialService, required this.onBooked});
  final WashService initialService;
  final VoidCallback onBooked;

  @override
  State<_BookWashPage> createState() => _BookWashPageState();
}

class _BookWashPageState extends State<_BookWashPage> {
  final _repository = FirestoreRepository();
  final _pickupAddress = TextEditingController();
  final _notes = TextEditingController();
  late WashService _service = widget.initialService;
  String? _vehicleId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _pickup = false;
  bool _busy = false;
  Position? _position;

  @override
  void didUpdateWidget(covariant _BookWashPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialService != widget.initialService) {
      _service = widget.initialService;
    }
  }

  @override
  void dispose() {
    _pickupAddress.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime get _scheduledAt =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _PortalHeader(
        'Book a wash',
        'Choose service, vehicle and pickup',
      ),
    ),
    body: StreamBuilder<List<Vehicle>>(
      stream: _repository.vehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        Vehicle? selectedVehicle;
        if (vehicles.isNotEmpty) {
          selectedVehicle = vehicles.firstWhere(
            (item) => item.id == _vehicleId,
            orElse: () => vehicles.firstWhere(
              (item) => item.isDefault,
              orElse: () => vehicles.first,
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Service', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<WashService>(
              key: ValueKey('service-${_service.name}'),
              initialValue: _service,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: washServices
                  .map(
                    (service) => DropdownMenuItem(
                      value: service,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(
                              service.image,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${service.name} — ₹${service.price}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _service = value!),
            ),
            const SizedBox(height: 18),
            Text('Vehicle', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (vehicles.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text('Add your vehicle before requesting a wash.'),
                      const SizedBox(height: 10),
                      FilledButton.tonal(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VehicleManagerPage(),
                          ),
                        ),
                        child: const Text('Add vehicle'),
                      ),
                    ],
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                key: ValueKey('vehicle-${selectedVehicle?.id}'),
                initialValue: selectedVehicle?.id,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                items: vehicles
                    .map(
                      (vehicle) => DropdownMenuItem(
                        value: vehicle.id,
                        child: Text('${vehicle.number} • ${vehicle.type}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _vehicleId = value),
              ),
            const SizedBox(height: 18),
            Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('${_date.day}/${_date.month}/${_date.year}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                value: _pickup,
                onChanged: (value) => setState(() => _pickup = value),
                secondary: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.blue,
                ),
                title: const Text(
                  'Request vehicle pickup',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'MAK360 will confirm availability and pickup timing.',
                ),
              ),
            ),
            if (_pickup) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _pickupAddress,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Pickup address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _captureLocation,
                icon: Icon(
                  _position == null ? Icons.my_location : Icons.check_circle,
                  color: _position == null ? null : AppColors.success,
                ),
                label: Text(
                  _position == null
                      ? 'Attach my current location'
                      : 'Current location attached',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText:
                    'Pickup landmark, vehicle condition or special request',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy || selectedVehicle == null
                  ? null
                  : () => _submit(selectedVehicle!),
              child: Text(
                _busy
                    ? 'Sending request…'
                    : 'Request wash • ₹${_service.price}',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No payment is collected yet. MAK360 will confirm the request first.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (value != null) setState(() => _time = value);
  }

  Future<void> _captureLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission was not granted.');
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _position = position);
    } catch (error) {
      if (mounted) _snack(context, error.toString(), error: true);
    }
  }

  Future<void> _submit(Vehicle vehicle) async {
    if (_pickup && _pickupAddress.text.trim().isEmpty && _position == null) {
      _snack(
        context,
        'Enter a pickup address or attach your current location.',
        error: true,
      );
      return;
    }
    if (_scheduledAt.isBefore(DateTime.now())) {
      _snack(context, 'Choose a future date and time.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await _repository.createBooking(
        vehicle: vehicle,
        service: _service,
        scheduledAt: _scheduledAt,
        pickupRequested: _pickup,
        pickupAddress: _pickupAddress.text,
        pickupLatitude: _position?.latitude,
        pickupLongitude: _position?.longitude,
        notes: _notes.text,
      );
      if (mounted) {
        _snack(context, 'Your request was sent to MAK360.');
        widget.onBooked();
      }
    } catch (error) {
      if (mounted) {
        _snack(context, 'Could not create request: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _CustomerBookingsPage extends StatelessWidget {
  const _CustomerBookingsPage();

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const _PortalHeader('My requests', 'Track, chat or cancel'),
      ),
      body: StreamBuilder<List<WashBooking>>(
        stream: repository.customerBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load requests: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const _EmptyState(
              icon: Icons.receipt_long_outlined,
              text: 'Your wash requests will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final canCancel =
                  booking.status == 'requested' ||
                  booking.status == 'confirmed';
              return _BookingCard(
                booking: booking,
                actions: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(booking: booking),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat'),
                  ),
                  if (canCancel)
                    TextButton(
                      onPressed: () => repository.cancelBooking(booking.id),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CustomerProfilePage extends StatelessWidget {
  const _CustomerProfilePage();

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const _PortalHeader(
          'My profile',
          'Account, vehicles and security',
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: repository.profile(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? const <String, dynamic>{};
          final displayName = data['displayName'] as String? ?? '';
          final signedInEmail = FirebaseAuth.instance.currentUser?.email ?? '';
          final initial = displayName.trim().isEmpty
              ? 'C'
              : displayName.trim().characters.first.toUpperCase();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.blue,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                signedInEmail,
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
                          signedInEmail,
                          data['phone'] as String? ?? '',
                        ].where((item) => item.isNotEmpty).join(' • '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final message = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PersonalDetailsPage(initial: data),
                          ),
                        );
                        if (context.mounted && message != null) {
                          _snack(context, message);
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
                      onTap: () => _snack(
                        context,
                        'Profile photo upload is coming soon.',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.directions_car_outlined,
                        color: AppColors.blue,
                      ),
                      title: const Text('My vehicles'),
                      subtitle: const Text(
                        'Numbers, types and default vehicle',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleManagerPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_reset, color: AppColors.blue),
                  title: const Text('Change password'),
                  subtitle: const Text('Reset your password securely in-app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Signed in as $signedInEmail',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
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

class VehicleManagerPage extends StatelessWidget {
  const VehicleManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My vehicles'),
        actions: [
          IconButton(
            onPressed: () => _vehicleDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: repository.vehicles(),
        builder: (context, snapshot) {
          final vehicles = snapshot.data ?? const <Vehicle>[];
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vehicles.isEmpty) {
            return _EmptyState(
              icon: Icons.directions_car_outlined,
              text: 'No vehicles yet.',
              action: () => _vehicleDialog(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.paleBlue,
                    child: Icon(Icons.directions_car, color: AppColors.blue),
                  ),
                  title: Text(
                    vehicle.number,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${vehicle.type}${vehicle.label.isEmpty ? '' : ' • ${vehicle.label}'}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _vehicleDialog(context, vehicle: vehicle);
                      }
                      if (value == 'delete') {
                        repository.deleteVehicle(vehicle.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _vehicleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add vehicle'),
      ),
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: repository.notifications(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const _EmptyState(
              icon: Icons.notifications_none,
              text: 'No notifications yet.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final read = item['read'] as bool? ?? false;
              return Card(
                color: read ? Colors.white : AppColors.paleBlue,
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.actions});
  final WashBooking booking;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Chip(label: Text(statusLabel(booking.status))),
            ],
          ),
          Text(
            '${booking.vehicleNumber} • ${booking.vehicleType}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.scheduledAt.day}/${booking.scheduledAt.month}/${booking.scheduledAt.year} at ${_clock(booking.scheduledAt)}',
          ),
          if (booking.pickupRequested)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Pickup requested',
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const Divider(height: 22),
          Row(
            children: [
              Text(
                '₹${booking.price}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              ...actions,
            ],
          ),
        ],
      ),
    ),
  );
}

class _PortalHeader extends StatelessWidget {
  const _PortalHeader(this.title, this.subtitle);
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 58, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: action,
              child: const Text('Add vehicle'),
            ),
          ],
        ],
      ),
    ),
  );
}

Future<void> _vehicleDialog(BuildContext context, {Vehicle? vehicle}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _VehicleEditorDialog(vehicle: vehicle),
    );

class _VehicleEditorDialog extends StatefulWidget {
  const _VehicleEditorDialog({this.vehicle});

  final Vehicle? vehicle;

  @override
  State<_VehicleEditorDialog> createState() => _VehicleEditorDialogState();
}

class _VehicleEditorDialogState extends State<_VehicleEditorDialog> {
  late final TextEditingController _number;
  late final TextEditingController _label;
  late String _type;
  late bool _isDefault;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _number = TextEditingController(text: widget.vehicle?.number ?? '');
    _label = TextEditingController(text: widget.vehicle?.label ?? '');
    _type = widget.vehicle?.type ?? 'Car';
    _isDefault = widget.vehicle?.isDefault ?? true;
  }

  @override
  void dispose() {
    _number.dispose();
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.vehicle == null ? 'Add vehicle' : 'Edit vehicle'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _number,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Registration number',
              hintText: 'KA 01 AB 1234',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Vehicle type'),
            items:
                const [
                      'Scooty',
                      'Bike',
                      'Auto',
                      'Car',
                      'SUV / 4 Wheeler',
                      'Bus',
                      'Truck / Heavy Vehicle',
                    ]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: _busy ? null : (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _label,
            decoration: const InputDecoration(
              labelText: 'Nickname (optional)',
              hintText: 'Family car',
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _isDefault,
            onChanged: _busy
                ? null
                : (value) => setState(() => _isDefault = value ?? false),
            title: const Text('Use as default'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _busy ? null : _save,
        child: Text(_busy ? 'Saving…' : 'Save'),
      ),
    ],
  );

  Future<void> _save() async {
    if (_number.text.trim().length < 5) {
      _snack(context, 'Enter a valid registration number.', error: true);
      return;
    }
    setState(() => _busy = true);
    var completed = false;
    try {
      await FirestoreRepository().saveVehicle(
        id: widget.vehicle?.id,
        number: _number.text,
        type: _type,
        label: _label.text,
        isDefault: _isDefault,
      );
      if (mounted) {
        completed = true;
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        _snack(context, 'Could not save vehicle: $error', error: true);
      }
    } finally {
      if (mounted && !completed) setState(() => _busy = false);
    }
  }
}

Future<void> _openExternal(BuildContext context, String value) async {
  final opened = await launchUrl(
    Uri.parse(value),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    _snack(context, 'Could not open Google Maps.', error: true);
  }
}

String _clock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
}

void _snack(BuildContext context, String text, {bool error = false}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
