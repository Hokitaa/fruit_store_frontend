import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  // Variabel private agar aman
  WebSocketChannel? _channel;

  void connect() {
    // Gunakan 'localhost' jika di browser, '10.0.2.2' jika di Emulator
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080'));
  }

  // Getter aman untuk stream
  Stream get stream => _channel!.stream.asBroadcastStream();

  // Getter aman untuk sink (mengirim pesan)
  // Ini yang dicari oleh fruit_screen.dart
  WebSocketChannel? get channel => _channel;

  void dispose() => _channel?.sink.close();
}
