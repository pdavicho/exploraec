import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/screens/gastos_screen.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Backend falso con tres gastos en dos categorías: lo justo para probar el
/// filtro de la pantalla Gastos (Sesión 10, Paso 7).
class _Backend implements HttpClientAdapter {
  final gastos = [
    {
      'id': 1,
      'descripcion': 'Almuerzo en el Mercado Central',
      'monto': 6.5,
      'categoria': 'comida',
      'fecha': '2026-10-15'
    },
    {'id': 2, 'descripcion': 'Taxi al terminal', 'monto': 3.25, 'categoria': 'transporte', 'fecha': '2026-10-15'},
    {'id': 3, 'descripcion': 'Helado de paila', 'monto': 2, 'categoria': 'comida', 'fecha': '2026-10-15'},
  ];

  ResponseBody _json(Object cuerpo, [Map<String, List<String>> h = const {}]) =>
      ResponseBody.fromString(jsonEncode(cuerpo), 200, headers: {
        Headers.contentTypeHeader: ['application/json'],
        ...h
      });

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async {
    switch (o.path) {
      case '/usuarios/token':
        return _json({'access_token': 'tok-prueba', 'token_type': 'bearer'});
      case '/usuarios/me':
        return _json({'id': 1, 'email': 'a@b.com'});
      case '/gastos/categorias':
        return _json({
          'categorias': ['comida', 'transporte', 'entretenimiento', 'otros'],
          'limite_por_categoria': 500.0
        });
      case '/gastos/':
        return _json(gastos, {
          'x-total-count': ['${gastos.length}']
        });
    }
    return ResponseBody.fromString(jsonEncode({'detail': 'ruta no prevista: ${o.path}'}), 404, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() => Hive.init(Directory.systemTemp.createTempSync('hive_filtro').path));

  Future<void> montar() async {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
    Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://backend'))..httpClientAdapter = _Backend()));
    await Get.put(AuthController()).iniciarSesion('a@b.com', 'clave-1234');
    final gastos = Get.put(GastosController());
    for (var i = 0; i < 200 && gastos.gastos.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  testWidgets('Al elegir «comida» solo se ven los gastos de comida; «Todas» los muestra todos', (tester) async {
    await tester.runAsync(montar);
    await tester.pumpWidget(const GetMaterialApp(home: GastosScreen()));
    await tester.pump();

    // Sin filtro: los tres gastos y un chip por cada categoría presente.
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.widgetWithText(ChoiceChip, 'Todas'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'comida'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'transporte'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'comida'));
    await tester.pump();
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Almuerzo en el Mercado Central'), findsOneWidget);
    expect(find.text('Helado de paila'), findsOneWidget);
    expect(find.text('Taxi al terminal'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
    await tester.pump();
    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
