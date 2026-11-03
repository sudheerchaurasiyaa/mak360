import 'package:flutter/material.dart';

enum AppRole { customer, owner }

enum VehicleClass { fourWheeler, heavyVehicle }

class WashService {
  const WashService({
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.vehicleClass,
    required this.image,
    required this.icon,
    required this.includes,
  });
  final String name;
  final String description;
  final int price;
  final int durationMinutes;
  final VehicleClass vehicleClass;
  final String image;
  final IconData icon;
  final List<String> includes;
}

const washServices = <WashService>[
  WashService(
    name: 'Scooty',
    description: 'Complete exterior wash for your scooty.',
    price: 150,
    durationMinutes: 20,
    vehicleClass: VehicleClass.fourWheeler,
    image: 'assets/images/scooty.jpeg',
    icon: Icons.electric_scooter_outlined,
    includes: ['Body water wash', 'Wheel cleaning', 'Final rinse'],
  ),
  WashService(
    name: 'Bike',
    description: 'Complete exterior wash for your bike.',
    price: 200,
    durationMinutes: 25,
    vehicleClass: VehicleClass.fourWheeler,
    image: 'assets/images/bike.jpeg',
    icon: Icons.two_wheeler_outlined,
    includes: ['Body water wash', 'Wheel cleaning', 'Final rinse'],
  ),
  WashService(
    name: 'Auto',
    description: 'Exterior body and wheel wash for autos.',
    price: 300,
    durationMinutes: 30,
    vehicleClass: VehicleClass.fourWheeler,
    image: 'assets/images/auto.jpeg',
    icon: Icons.local_taxi_outlined,
    includes: ['Exterior water wash', 'Wheel cleaning', 'Final rinse'],
  ),
  WashService(
    name: '4 Wheeler Body Wash',
    description: 'Exterior body wash for cars and other four-wheelers.',
    price: 400,
    durationMinutes: 35,
    vehicleClass: VehicleClass.fourWheeler,
    image: 'assets/images/4W body wash.jpeg',
    icon: Icons.directions_car_outlined,
    includes: [
      'Exterior body wash',
      'Wheel and tyre cleaning',
      'Final rinse and dry',
    ],
  ),
  WashService(
    name: '4 Wheeler Full Wash',
    description: 'Complete exterior and interior wash for four-wheelers.',
    price: 600,
    durationMinutes: 60,
    vehicleClass: VehicleClass.fourWheeler,
    image: 'assets/images/4W full wash.jpeg',
    icon: Icons.local_car_wash_outlined,
    includes: [
      'Exterior body wash',
      'Interior cleaning',
      'Wheel and tyre cleaning',
      'Final rinse and dry',
    ],
  ),
  WashService(
    name: 'Heavy Vehicle',
    description: 'Complete wash for heavy commercial vehicles.',
    price: 1200,
    durationMinutes: 120,
    vehicleClass: VehicleClass.heavyVehicle,
    image: 'assets/images/heavy vehicle.jpeg',
    icon: Icons.local_shipping_outlined,
    includes: [
      'Full body pressure wash',
      'Wheel and chassis cleaning',
      'Underbody rinse',
      'Final inspection',
    ],
  ),
  WashService(
    name: 'Bus or Empty Truck',
    description: 'Complete wash for buses and empty trucks.',
    price: 1000,
    durationMinutes: 100,
    vehicleClass: VehicleClass.heavyVehicle,
    image: 'assets/images/empty truck.jpeg',
    icon: Icons.directions_bus_outlined,
    includes: [
      'Full exterior pressure wash',
      'Roof and glass wash',
      'Wheel and chassis cleaning',
      'Final rinse',
    ],
  ),
];
