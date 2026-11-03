import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/presentation/auth_flow.dart';
import '../domain/wash_service.dart';
import 'customer_pages.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});
  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: index,
      children: [
        CustomerHome(openServices: () => setState(() => index = 1)),
        const ServicesPage(),
        const MyBookingsPage(),
        const CustomerProfilePage(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Bookings',
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

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key, required this.openServices});
  final VoidCallback openServices;
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
                  'Good afternoon, Riya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Your vehicle deserves a fresh start',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
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
            customerPageRoute(const CustomerNotificationsPage()),
          ),
          icon: Badge(child: Icon(Icons.notifications_none)),
        ),
      ],
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(
                  'assets/images/car_wash.png',
                  height: 205,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 205,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC082F49)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clean vehicle. Clear mind.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Book today and save 10% on complete wash.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.tonal(
                        onPressed: openServices,
                        child: const Text('Book a wash'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Choose your vehicle',
            subtitle: 'Services for every size',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _VehicleTile(
                  icon: Icons.directions_car_outlined,
                  label: 'Light & 4 Wheelers',
                  count: '5 wash plans',
                  onTap: openServices,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VehicleTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Heavy vehicles',
                  count: '2 wash plans',
                  onTap: openServices,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SectionTitle(
            title: 'Popular washes',
            subtitle: 'Most booked near you',
            action: 'See all',
            onAction: openServices,
          ),
          const SizedBox(height: 12),
          ...washServices
              .take(2)
              .map((service) => _ServiceRow(service: service)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.paleBlue,
                    child: Icon(Icons.support_agent, color: AppColors.blue),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help choosing?',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Talk to our wash specialist',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      customerPageRoute(const CustomerSupportPage()),
                    ),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  VehicleClass selected = VehicleClass.fourWheeler;
  @override
  Widget build(BuildContext context) {
    final services = washServices.where(
      (service) => service.vehicleClass == selected,
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const _Header(
          title: 'Wash services',
          subtitle: 'Clear pricing, no surprises',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SegmentedButton<VehicleClass>(
                segments: const [
                  ButtonSegment(
                    value: VehicleClass.fourWheeler,
                    icon: Icon(Icons.directions_car_outlined),
                    label: Text('Light / 4W'),
                  ),
                  ButtonSegment(
                    value: VehicleClass.heavyVehicle,
                    icon: Icon(Icons.local_shipping_outlined),
                    label: Text('Heavy'),
                  ),
                ],
                selected: {selected},
                onSelectionChanged: (value) =>
                    setState(() => selected = value.first),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: services
                    .map((service) => _ServiceCard(service: service))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({super.key, required this.service});
  final WashService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const _Header(
        title: 'Service details',
        subtitle: 'Review before booking',
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingPage(service: service)),
          ),
          child: Text('Choose slot - Rs ${service.price}'),
        ),
      ),
    ),
    body: ListView(
      children: [
        Image.asset(
          service.image,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Text(
                    'Rs ${service.price}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFB000), size: 18),
                  const Text(' 4.8 (126 reviews)'),
                  const Spacer(),
                  const Icon(Icons.schedule, size: 18, color: AppColors.muted),
                  Text(' ${service.durationMinutes} min'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                service.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const Text(
                'What is included',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...service.includes.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(item),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recent wash photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 115,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      service.image,
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.service});
  final WashService service;
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int day = 0;
  int slot = 1;
  final slots = ['9:00 AM', '11:00 AM', '2:00 PM', '4:30 PM'];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const _Header(
        title: 'Book your slot',
        subtitle: 'Select a convenient time',
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.service.image,
                      width: 86,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${widget.service.durationMinutes} min',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        Text(
                          'Rs ${widget.service.price}',
                          style: const TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Select date',
            subtitle: 'Available for the next 7 days',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (_, index) => ChoiceChip(
                selected: day == index,
                onSelected: (_) => setState(() => day = index),
                label: SizedBox(
                  width: 42,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'Today',
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                        ][index],
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        '${18 + index}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Available time',
            subtitle: 'Slots shown in local time',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: slots.length,
            itemBuilder: (_, index) => ChoiceChip(
              selected: slot == index,
              onSelected: (_) => setState(() => slot = index),
              avatar: const Icon(Icons.schedule, size: 17),
              label: Text(slots[index]),
            ),
          ),
          const SizedBox(height: 24),
          const TextField(
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Special instructions (optional)',
              hintText: 'Vehicle condition or access notes',
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                icon: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 54,
                ),
                title: const Text('Booking confirmed'),
                content: Text(
                  '${widget.service.name}\n${slots[slot]} on ${18 + day} July\n\nThe wash center can now contact you.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const CustomerShell()),
                      (_) => false,
                    ),
                    child: const Text('View my bookings'),
                  ),
                ],
              ),
            ),
            child: Text('Confirm booking - Rs ${widget.service.price}'),
          ),
        ],
      ),
    ),
  );
}

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _Header(
        title: 'My bookings',
        subtitle: 'Upcoming and completed washes',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle(title: 'Upcoming', subtitle: 'Your next wash'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Chip(label: Text('CONFIRMED')),
                    Spacer(),
                    Text(
                      'Booking #MW2408',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '4 Wheeler Full Wash',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Today, 11:00 AM | Honda City',
                  style: TextStyle(color: AppColors.muted),
                ),
                const Divider(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calling wash center...'),
                              ),
                            ),
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Call center'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          customerPageRoute(const DirectionsPage()),
                        ),
                        child: const Text('Get directions'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        const _SectionTitle(
          title: 'Past washes',
          subtitle: 'Your service history',
        ),
        const SizedBox(height: 12),
        ...['4 Wheeler Body Wash - 12 Jun', 'Bike - 3 May'].map(
          (text) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const CircleAvatar(
                backgroundColor: AppColors.paleBlue,
                child: Icon(Icons.water_drop_outlined, color: AppColors.blue),
              ),
              title: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Completed | Rated 5 stars'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(text),
                  content: const Text(
                    'Wash completed successfully.\nPayment received.\nCustomer rating: 5 stars.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Book again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const _Header(
        title: 'Your profile',
        subtitle: 'Vehicles and account settings',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.blue,
              child: Text(
                'RS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riya Sharma',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '+91 98XXXXXX97',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => Navigator.push(
                context,
                customerPageRoute(const CustomerEditProfilePage()),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: AppColors.paleBlue,
              child: Icon(Icons.directions_car, color: AppColors.blue),
            ),
            title: const Text(
              'Honda City',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('DL 8C AB 2481 | Primary vehicle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              customerPageRoute(const VehiclesPage()),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...[
          (Icons.garage_outlined, 'Manage vehicles'),
          (Icons.location_on_outlined, 'Saved addresses'),
          (Icons.payment_outlined, 'Payment methods'),
          (Icons.support_agent, 'Help and support'),
          (Icons.policy_outlined, 'Privacy and terms'),
        ].map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(item.$1, color: AppColors.blue),
            title: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              customerPageRoute(switch (item.$2) {
                'Manage vehicles' => const VehiclesPage(),
                'Saved addresses' => const AddressesPage(),
                'Payment methods' => const PaymentsPage(),
                'Help and support' => const CustomerSupportPage(),
                _ => const LegalPage(),
              }),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            'Log out',
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final WashService service;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailPage(service: service),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              service.image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        'Rs ${service.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.description,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 17,
                        color: Colors.grey.shade600,
                      ),
                      Text(' ${service.durationMinutes} min'),
                      const Spacer(),
                      const Text(
                        'View details',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});
  final WashService service;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.asset(
            service.image,
            width: 70,
            height: 62,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${service.durationMinutes} min | Rs ${service.price}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailPage(service: service),
          ),
        ),
      ),
    ),
  );
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });
  final IconData icon;
  final String label, count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.paleBlue,
              child: Icon(icon, color: AppColors.blue),
            ),
            const SizedBox(height: 20),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(
              count,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });
  final String title, subtitle;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
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
