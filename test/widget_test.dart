import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exploraec/main.dart';

void main() {
  testWidgets('Inicio muestra la lista y las pestañas funcionan',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());

    // La lista de Inicio muestra los lugares de ejemplo.
    expect(find.text('Parque El Ejido'), findsOneWidget);
    expect(find.text('Cargando lugares...'), findsNothing);

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
}
