import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mak360/app.dart';
import 'package:mak360/core/config/app_config.dart';
import 'package:mak360/core/config/firebase_bootstrap.dart';
import 'package:mak360/features/wash/domain/app_models.dart';
import 'package:mak360/features/wash/domain/wash_service.dart';
import 'package:mak360/features/wash/presentation/customer_portal.dart';

void main() {
  testWidgets('shows a useful screen when Firebase configuration is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Mak360App(
        bootstrap: FirebaseBootstrapResult.failed('Configuration missing'),
      ),
    );

    expect(find.text('Firebase setup required'), findsOneWidget);
    expect(find.textContaining('Configuration missing'), findsOneWidget);
  });

  testWidgets('configuration screen fits a phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const Mak360App(
        bootstrap: FirebaseBootstrapResult.failed('Configuration missing'),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  test('MAK360 place and service catalogue are configured', () {
    expect(AppConfig.centerName, 'MAK360 Car Garage');
    expect(AppConfig.centerLatitude, closeTo(12.7866625, 0.0000001));
    expect(AppConfig.centerLongitude, closeTo(77.7448906, 0.0000001));
    expect(washServices, hasLength(7));
    expect(washServices.every((service) => service.price > 0), isTrue);
  });

  test('vehicle identity remains stable across Firestore refreshes', () {
    const firstSnapshot = Vehicle(
      id: 'vehicle-1',
      number: 'KA 01 AB 1234',
      type: 'Car',
      label: 'Family car',
      isDefault: true,
    );
    const refreshedSnapshot = Vehicle(
      id: 'vehicle-1',
      number: 'KA 01 AB 1234',
      type: 'Car',
      label: 'Family car',
      isDefault: true,
    );

    expect(firstSnapshot, refreshedSnapshot);
    final uniqueVehicles = <Vehicle>{};
    uniqueVehicles.add(firstSnapshot);
    uniqueVehicles.add(refreshedSnapshot);
    expect(uniqueVehicles, hasLength(1));
  });

  testWidgets('service details show image, description and booking action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final service = washServices[4];

    await tester.pumpWidget(
      MaterialApp(home: ServiceDetailsPage(service: service)),
    );

    expect(find.text(service.name), findsWidgets);
    expect(find.text(service.description), findsOneWidget);
    expect(find.text('Continue to booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
