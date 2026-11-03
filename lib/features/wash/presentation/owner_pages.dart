import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

Route<void> ownerPageRoute(Widget page) =>
    MaterialPageRoute(builder: (_) => page);

class OwnerNotificationsPage extends StatefulWidget {
  const OwnerNotificationsPage({super.key});
  @override
  State<OwnerNotificationsPage> createState() => _OwnerNotificationsPageState();
}

class _OwnerNotificationsPageState extends State<OwnerNotificationsPage> {
  final unread = <bool>[true, true, true, false];
  @override
  Widget build(BuildContext context) {
    const titles = [
      'New booking received',
      'Customer arriving soon',
      'Payment completed',
      'New 5-star review',
    ];
    const details = [
      'Heavy Vehicle at 2:00 PM',
      'Riya Sharma is 10 minutes away',
      'Rs 600 for 4 Wheeler Full Wash',
      'Excellent wash and quick service',
    ];
    return _OwnerPage(
      title: 'Notifications',
      subtitle: 'Center activity and customer updates',
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
                  Icons.event_available,
                  Icons.directions_car,
                  Icons.payments_outlined,
                  Icons.star,
                ][index],
                color: unread[index] ? Colors.white : AppColors.blue,
              ),
            ),
            title: Text(
              titles[index],
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(details[index]),
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

class WaterUsagePage extends StatelessWidget {
  const WaterUsagePage({super.key});
  @override
  Widget build(BuildContext context) {
    const usage = [2400, 3200, 2800, 3500, 2600, 3100, 2840];
    return _OwnerPage(
      title: 'Water usage',
      subtitle: 'Track efficiency and daily consumption',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.paleBlue,
                        child: Icon(Icons.water_drop, color: AppColors.blue),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Chip(label: Text('12% below average')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2,840 L',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    'Used today across 12 bookings',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: .66,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Last 7 days',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: usage.indexed
                      .map(
                        (entry) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: entry.$2 / 4000,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: entry.$1 == 6
                                              ? AppColors.blue
                                              : AppColors.cyan.withValues(
                                                  alpha: .45,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][entry.$1],
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _OwnerInfo(
            Icons.eco_outlined,
            'Water-saving performance',
            'Pressure-wash controls saved an estimated 390 L today.',
          ),
        ],
      ),
    );
  }
}

class BusinessHoursPage extends StatefulWidget {
  const BusinessHoursPage({super.key});
  @override
  State<BusinessHoursPage> createState() => _BusinessHoursPageState();
}

class _BusinessHoursPageState extends State<BusinessHoursPage> {
  final enabled = <bool>[true, true, true, true, true, true, false];
  @override
  Widget build(BuildContext context) => _OwnerPage(
    title: 'Business hours',
    subtitle: 'Set when customers can book',
    actions: [
      TextButton(
        onPressed: () => _saved(context),
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    ],
    child: ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 7,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (_, index) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: enabled[index],
        onChanged: (value) => setState(() => enabled[index] = value),
        title: Text(
          [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ][index],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(enabled[index] ? '7:00 AM - 8:00 PM' : 'Closed'),
        secondary: enabled[index]
            ? IconButton(
                onPressed: () => _timeDialog(context),
                icon: const Icon(Icons.edit_outlined),
              )
            : null,
      ),
    ),
  );
}

class SlotManagementPage extends StatefulWidget {
  const SlotManagementPage({super.key});
  @override
  State<SlotManagementPage> createState() => _SlotManagementPageState();
}

class _SlotManagementPageState extends State<SlotManagementPage> {
  final slots = <String, bool>{
    '7:00 AM': true,
    '9:00 AM': true,
    '11:00 AM': false,
    '2:00 PM': true,
    '4:30 PM': true,
    '6:00 PM': false,
  };
  @override
  Widget build(BuildContext context) => _OwnerPage(
    title: 'Slot availability',
    subtitle: 'Open or block customer booking times',
    actions: [
      IconButton(
        onPressed: () => setState(() => slots['8:00 PM'] = true),
        icon: const Icon(Icons.add),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _OwnerInfo(
          Icons.calendar_today_outlined,
          'Monday, 20 July',
          '4 of 6 regular slots are open.',
        ),
        const SizedBox(height: 16),
        ...slots.entries.map(
          (entry) => Card(
            child: SwitchListTile(
              value: entry.value,
              onChanged: (value) => setState(() => slots[entry.key] = value),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                entry.value
                    ? 'Available to customers'
                    : 'Blocked or fully booked',
              ),
              secondary: Icon(
                entry.value ? Icons.event_available : Icons.event_busy,
                color: entry.value ? AppColors.success : Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});
  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final staff = <(String, String)>[
    ('Vikram Rao', 'Wash specialist'),
    ('Sameer Khan', 'Heavy vehicle operator'),
    ('Nikhil Das', 'Interior specialist'),
  ];
  void add() => showDialog(
    context: context,
    builder: (_) {
      final name = TextEditingController();
      return AlertDialog(
        title: const Text('Add staff member'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty) {
                setState(
                  () => staff.add((name.text.trim(), 'Wash specialist')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
  @override
  Widget build(BuildContext context) => _OwnerPage(
    title: 'Staff members',
    subtitle: 'Manage wash-center team access',
    actions: [
      IconButton(onPressed: add, icon: const Icon(Icons.person_add_alt)),
    ],
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...staff.map(
          (person) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: AppColors.blue,
                child: Text(
                  person.$1[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: Text(
                person.$1,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${person.$2} | On duty'),
              trailing: const Icon(Icons.more_vert),
            ),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: add,
          icon: const Icon(Icons.add),
          label: const Text('Add staff member'),
        ),
      ],
    ),
  );
}

class WashGalleryPage extends StatelessWidget {
  const WashGalleryPage({super.key});
  @override
  Widget build(BuildContext context) => _OwnerPage(
    title: 'Wash gallery',
    subtitle: 'Photos customers see before booking',
    actions: [
      IconButton(
        onPressed: () => _saved(context),
        icon: const Icon(Icons.add_a_photo_outlined),
      ),
    ],
    child: GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: 8,
      itemBuilder: (_, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              index.isEven
                  ? 'assets/images/car_wash.png'
                  : 'assets/images/truck_wash.png',
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton.filledTonal(
                onPressed: () => _saved(context),
                icon: const Icon(Icons.more_horiz, size: 18),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int range = 0;
  @override
  Widget build(BuildContext context) {
    const revenue = [6200, 7800, 6900, 9400, 8100, 10800, 9220];
    return _OwnerPage(
      title: 'Reports & earnings',
      subtitle: 'Revenue and booking performance',
      actions: [
        IconButton(
          onPressed: () => _saved(context),
          icon: const Icon(Icons.download_outlined),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Week')),
              ButtonSegment(value: 1, label: Text('Month')),
              ButtonSegment(value: 2, label: Text('Year')),
            ],
            selected: {range},
            onSelectionChanged: (value) => setState(() => range = value.first),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: _ReportMetric('Rs 58,420', 'Gross revenue')),
              SizedBox(width: 10),
              Expanded(child: _ReportMetric('84', 'Completed washes')),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue trend',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: revenue
                          .map(
                            (value) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: FractionallySizedBox(
                                  heightFactor: value / 12000,
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.blue,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _OwnerInfo(
            Icons.trending_up,
            'Top service',
            '4 Wheeler Full Wash generated Rs 14,400 from 24 bookings.',
          ),
        ],
      ),
    );
  }
}

class OwnerSupportPage extends StatelessWidget {
  const OwnerSupportPage({super.key});
  @override
  Widget build(BuildContext context) => _OwnerPage(
    title: 'Owner support',
    subtitle: 'Business and technical assistance',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _OwnerInfo(
          Icons.support_agent,
          'Dedicated partner support',
          'Available daily from 6:00 AM to 10:00 PM.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _saved(context),
          icon: const Icon(Icons.call_outlined),
          label: const Text('Call partner support'),
        ),
        const SizedBox(height: 24),
        ...[
          'Booking and cancellation rules',
          'Payout and settlement help',
          'Service pricing guidance',
          'Account and staff access',
        ].map(
          (topic) => ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              topic,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Open a support request or call partner support for help with this topic.',
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

class CenterProfilePage extends StatefulWidget {
  const CenterProfilePage({super.key});
  @override
  State<CenterProfilePage> createState() => _CenterProfilePageState();
}

class _CenterProfilePageState extends State<CenterProfilePage> {
  @override
  Widget build(BuildContext context) => _OwnerPage(
    title: 'Edit wash center',
    subtitle: 'Public business information',
    actions: [
      TextButton(
        onPressed: () {
          _saved(context);
          Navigator.pop(context);
        },
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.blue,
            child: Icon(Icons.storefront, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 24),
        const TextField(
          controller: null,
          decoration: InputDecoration(
            labelText: 'Center name',
            hintText: 'MAK360 Wash Center',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Contact number',
            hintText: '+91 98765 44821',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText:
                'Opp. to Hotel Ramee Guestline, NH 7, Hosur Road, Attibele Indl Area, Bangalore 562107',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'About',
            hintText:
                'Professional water wash for four-wheelers and heavy vehicles.',
          ),
        ),
      ],
    ),
  );
}

class _OwnerPage extends StatelessWidget {
  const _OwnerPage({
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

class _OwnerInfo extends StatelessWidget {
  const _OwnerInfo(this.icon, this.title, this.text);
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

class _ReportMetric extends StatelessWidget {
  const _ReportMetric(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.blue,
            ),
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

void _timeDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Business hours'),
    content: const Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Opens',
              hintText: '7:00 AM',
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Closes',
              hintText: '8:00 PM',
            ),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Apply'),
      ),
    ],
  ),
);
void _saved(BuildContext context) => ScaffoldMessenger.of(
  context,
).showSnackBar(const SnackBar(content: Text('Changes saved successfully.')));
