import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> addFruit(String name, String price) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/fruit_store_backend/api_add_fruit.php'),
        body: {'nama_buah': name, 'harga': price},
      );
      print("Response API: ${response.body}"); // Cek ini di terminal VS Code
    } catch (e) {
      print("Error API: $e");
    }
  }
}
