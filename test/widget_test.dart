import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_store_frontend/main.dart'; // Sesuaikan path-nya

void main() {
  testWidgets('FruitStore UI memuat dengan benar', (WidgetTester tester) async {
    // Build aplikasi
    await tester.pumpWidget(const MyApp());

    // Cek apakah judul AppBar tampil
    expect(find.text('FruitStore Pro'), findsOneWidget);

    // Cek apakah tombol tambah (add_shopping_cart) ada di layar
    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);

    // Cek apakah indikator loading muncul saat pertama kali (menunggu data)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
