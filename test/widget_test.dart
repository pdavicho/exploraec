import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exploraec/main.dart';

void main() {
  testWidgets('Inicio muestra la lista y las pestañas funcionan',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());

    // Mientras carga, se ve el LoadingView.
    expect(find.text('Buscando lugares cercanos...'), findsOneWidget);

    // Al terminar la carga simulada, la lista muestra los lugares de ejemplo.
    await tester.pumpAndSettle();
    expect(find.text('Parque El Ejido'), findsOneWidget);

    // Tocar una tarjeta abre el Detalle.
    await tester.tap(find.text('Parque El Ejido'));
    await tester.pumpAndSettle();
    expect(find.byType(Chip), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // La barra inferior cambia a la pestaña Mapa.
    await tester.tap(find.text('Mapa'));
    await tester.pumpAndSettle();
    expect(find.text('Próximamente: mapa real (Sesión 5)'), findsOneWidget);
  });

  testWidgets('Usa el tema oscuro cuando el dispositivo está en modo oscuro',
      (WidgetTester tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const ExploraEcApp());
    await tester.pumpAndSettle();

    final contexto = tester.element(find.text('Parque El Ejido'));
    expect(Theme.of(contexto).brightness, Brightness.dark);
  });
}
