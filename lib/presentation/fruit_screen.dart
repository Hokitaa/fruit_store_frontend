import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/api_service.dart';
import '../data/websocket_service.dart';

class FruitScreen extends StatefulWidget {
  const FruitScreen({super.key});
  @override
  State<FruitScreen> createState() => _FruitScreenState();
}

class _FruitScreenState extends State<FruitScreen> {
  final WebSocketService _wsService = WebSocketService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List _fruitList = [];
  bool _isLoading = true;

  // ── Fruit emoji map ──────────────────────────────────────────────────────
  String _fruitEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('apel') || n.contains('apple')) return '🍎';
    if (n.contains('pisang') || n.contains('banana')) return '🍌';
    if (n.contains('jeruk') || n.contains('orange')) return '🍊';
    if (n.contains('mangga') || n.contains('mango')) return '🥭';
    if (n.contains('anggur') || n.contains('grape')) return '🍇';
    if (n.contains('semangka') || n.contains('watermelon')) return '🍉';
    if (n.contains('stroberi') || n.contains('strawberry')) return '🍓';
    if (n.contains('nanas') || n.contains('pineapple')) return '🍍';
    if (n.contains('melon')) return '🍈';
    if (n.contains('durian')) return '🍈';
    if (n.contains('pepaya') || n.contains('papaya')) return '🍑';
    if (n.contains('kelapa') || n.contains('coconut')) return '🥥';
    if (n.contains('lemon')) return '🍋';
    if (n.contains('ceri') || n.contains('cherry')) return '🍒';
    if (n.contains('persik') || n.contains('peach')) return '🍑';
    if (n.contains('pir') || n.contains('pear')) return '🍐';
    return '🍑';
  }

  @override
  void initState() {
    super.initState();
    _wsService.connect();
    _fetchFruits();
    _wsService.stream.listen((message) {
      if (message == "REFRESH") _fetchFruits();
    });
  }

  @override
  void dispose() {
    _wsService.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchFruits() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/fruit_store_backend/api_get_fruits.php'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _fruitList = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFruit(dynamic id) async {
    await http.post(
      Uri.parse('http://10.0.2.2/fruit_store_backend/api_delete.php'),
      body: {'id': id.toString()},
    );
    _wsService.channel?.sink.add("REFRESH");
  }

  // ── DIALOG TAMBAH ────────────────────────────────────────────────────────
  void _showAddFruitDialog() {
    _nameController.clear();
    _priceController.clear();
    showDialog(
      context: context,
      builder: (context) => _FruitDialog(
        title: "Tambah Buah",
        nameController: _nameController,
        priceController: _priceController,
        submitLabel: "Simpan",
        onSubmit: () async {
          await ApiService.addFruit(
            _nameController.text,
            _priceController.text,
          );
          _wsService.channel?.sink.add("REFRESH");
          await _fetchFruits();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // ── DIALOG EDIT ──────────────────────────────────────────────────────────
  void _showEditFruitDialog(Map fruit) {
    _nameController.text = fruit['nama_buah'].toString();
    _priceController.text = fruit['harga'].toString();

    showDialog(
      context: context,
      builder: (context) => _FruitDialog(
        title: "Edit Buah",
        nameController: _nameController,
        priceController: _priceController,
        submitLabel: "Update",
        onSubmit: () async {
          await http.post(
            Uri.parse('http://10.0.2.2/fruit_store_backend/api_update.php'),
            body: {
              'id': fruit['id'].toString(),
              'nama_buah': _nameController.text,
              'harga': _priceController.text,
            },
          );
          _wsService.channel?.sink.add("REFRESH");
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF4),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoader() : _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: const [
          Text('🛒', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text(
            'FruitStore Pro',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            '${_fruitList.length} buah',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text('Memuat data…', style: TextStyle(color: Color(0xFF4CAF50))),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_fruitList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍃', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              'Belum ada buah',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + untuk menambahkan',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _fruitList.length,
      itemBuilder: (context, index) {
        final fruit = _fruitList[index];
        final name = fruit['nama_buah'].toString();
        final price = fruit['harga'].toString();
        final emoji = _fruitEmoji(name);

        // Alternating card accent colors
        final cardColors = [
          const Color(0xFFE8F5E9),
          const Color(0xFFFFF8E1),
          const Color(0xFFE3F2FD),
          const Color(0xFFFCE4EC),
          const Color(0xFFEDE7F6),
        ];
        final cardColor = cardColors[index % cardColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1B5E20),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rp $price',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF1976D2),
                  bgColor: const Color(0xFFE3F2FD),
                  onPressed: () => _showEditFruitDialog(fruit),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFC62828),
                  bgColor: const Color(0xFFFFEBEE),
                  onPressed: () => _deleteFruit(fruit['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddFruitDialog,
      backgroundColor: const Color(0xFF2E7D32),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Tambah Buah',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Reusable action button ─────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ── Shared dialog widget ───────────────────────────────────────────────────
class _FruitDialog extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final String submitLabel;
  final VoidCallback onSubmit;

  const _FruitDialog({
    required this.title,
    required this.nameController,
    required this.priceController,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🍑', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _StyledTextField(
              controller: nameController,
              label: 'Nama Buah',
              icon: Icons.eco_rounded,
            ),
            const SizedBox(height: 12),
            _StyledTextField(
              controller: priceController,
              label: 'Harga (Rp)',
              icon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Color(0xFF2E7D32)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      submitLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        filled: true,
        fillColor: const Color(0xFFF6FBF4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCCE5CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF4CAF50), fontSize: 14),
      ),
    );
  }
}
