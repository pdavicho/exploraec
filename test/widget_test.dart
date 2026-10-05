import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:exploraec/controllers/places_controller.dart';
import 'package:exploraec/main.dart';
import 'package:exploraec/screens/detail_screen.dart';

/// Posición fija para los tests (Plaza Grande, Quito): en un test no hay GPS,
/// así que se le entrega al controller como si ya la hubiera obtenido.
Position posicionDePrueba() => Position(
      latitude: -0.2201,
      longitude: -78.5123,
      timestamp: DateTime(2026),
      accuracy: 5,
      altitude: 2850,
      altitudeAccuracy: 1,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1,
    );

void main() {
  // GetX guarda el controller y el idioma de forma global: se limpian entre
  // tests para que cada uno arranque la app desde cero.
  tearDown(Get.reset);

  /// Arranca la app y espera a que termine la carga simulada (1 s).
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());
    expect(find.text('Buscando lugares cercanos...'), findsOneWidget);
    await tester.pumpAndSettle();
  }

  testWidgets('Inicio muestra la lista y la tarjeta abre el Detalle',
      (WidgetTester tester) async {
    await abrirApp(tester);
    expect(find.text('Parque El Ejido'), findsOneWidget);

    await tester.tap(find.text('Parque El Ejido'));
    await tester.pumpAndSettle();
    expect(find.byType(Chip), findsOneWidget); // sin distancia: no viene del Mapa
    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('Mapa: tu posición + un marcador por lugar, y Detalle con distancia',
      (WidgetTester tester) async {
    await abrirApp(tester);
    Get.find<PlacesController>().posicion.value = posicionDePrueba();

    await tester.tap(find.text('Mapa'));
    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsWidgets); // marcador + botón centrar
    expect(find.byTooltip('Centrar en mi ubicación'), findsOneWidget);

    // flutter_map solo dibuja los marcadores que caen dentro de la pantalla,
    // así que se cuentan los que tiene la capa: tu posición + 6 lugares.
    expect(tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers, hasLength(7));
    final marcadores = find.descendant(
      of: find.byType(MarkerLayer),
      matching: find.byIcon(Icons.place),
    );

    // Tocar un marcador abre el Detalle con la distancia calculada.
    await tester.tap(marcadores.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    final detalle = tester.widget<DetailScreen>(find.byType(DetailScreen));
    expect(detalle.distanciaMetros, isNotNull);
    expect(find.textContaining('de ti'), findsOneWidget);
  });

  testWidgets('Con posición, las tarjetas de Inicio muestran la distancia',
      (WidgetTester tester) async {
    await abrirApp(tester);
    expect(find.textContaining('de ti'), findsNothing);

    Get.find<PlacesController>().posicion.value = posicionDePrueba();
    await tester.pump();
    expect(find.textContaining('de ti'), findsWidgets);
  });

  testWidgets('Un lugar creado aparece en Inicio y en el Mapa',
      (WidgetTester tester) async {
    await abrirApp(tester);
    final controller = Get.find<PlacesController>();
    controller.posicion.value = posicionDePrueba();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Mirador del Panecillo');
    await tester.enterText(campos.at(1), 'Miradores');
    await tester.enterText(campos.at(2), 'Vista de todo el Centro Histórico.');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Lugar agregado'), findsOneWidget);

    // Está en la lista que alimenta a Inicio, ubicado en la posición del usuario.
    final nuevo = controller.lugares.last;
    expect(nuevo.nombre, 'Mirador del Panecillo');
    expect(nuevo.lat, posicionDePrueba().latitude);

    // Y el Mapa ya tiene un marcador más: tu posición + 7 lugares.
    await tester.tap(find.text('Mapa'));
    await tester.pump();
    expect(tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers, hasLength(8));

    // Deja que el snackbar se cierre solo, para no dejar timers pendientes.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('Sin GPS, el Mapa muestra el error con Reintentar',
      (WidgetTester tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Mapa'));
    await tester.pump();
    // En un test no hay plugin de ubicación: la llamada a geolocator falla
    // en tiempo real, así que se espera con runAsync en vez del reloj simulado.
    await tester.runAsync(() => Get.find<PlacesController>().cargarPosicion(forzar: true));
    await tester.pump();
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('El corazón marca favoritos y la pestaña Favoritos los cuenta',
      (WidgetTester tester) async {
    await abrirApp(tester);
    await tester.tap(find.byTooltip('Agregar a favoritos').first);
    await tester.pump();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Favoritos marcados: 1'), findsOneWidget);
  });

  // El botón de idioma llama a Get.updateLocale, que fuerza un "reassemble"
  // de toda la app: eso no se puede ejecutar dentro de un widget test, así
  // que aquí se comprueba el diccionario y el idioma inicial por separado.
  testWidgets('Arranca en español y tiene las traducciones al inglés',
      (WidgetTester tester) async {
    await abrirApp(tester);
    expect(find.text('Inicio'), findsOneWidget);
    Get.locale = const Locale('en', 'US');
    expect('inicio'.tr, 'Home');
    expect('favoritos'.tr, 'Favorites');
  });

  testWidgets('Usa el tema oscuro cuando el dispositivo está en modo oscuro',
      (WidgetTester tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await abrirApp(tester);
    final contexto = tester.element(find.text('Parque El Ejido'));
    expect(Theme.of(contexto).brightness, Brightness.dark);
  });
}
