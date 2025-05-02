import 'package:flutter/material.dart';
import 'package:kursova2/GoodsScreen.dart';
import 'package:kursova2/warehouses_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpc_service.dart'; // твій RPC сервіс

class WarehouseStockScreen extends StatefulWidget {
  final int warehouseId;
  final String warehouseName;

  const WarehouseStockScreen({super.key, required this.warehouseId, required this.warehouseName});

  @override
  State<WarehouseStockScreen> createState() => _WarehouseStockScreenState();
}

class _WarehouseStockScreenState extends State<WarehouseStockScreen> {
  final rpc = RpcService(url: 'http://localhost/kursach/index.php');
  bool isLoading = true;
  List<dynamic> stockItems = [];

  @override
  void initState() {
    super.initState();
    loadWarehouseStock();
  }

  Future<void> loadWarehouseStock() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final sessionKey = prefs.getString('session_key');

    if (sessionKey == null) {
      print('No session key found.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await rpc.sendRequest(
      method: 'Stock->get_warehouse_stock',
      params: {'wh_id': widget.warehouseId},
      sessionKey: sessionKey,
      id: 7, // унікальний ID запиту
    );

    if (response != null && response['result'] != null) {
      setState(() {
        stockItems = response['result'] ?? [];
        
        isLoading = false;
      });
    } else {
      print('Failed to load warehouse stock: ${response?['error'] ?? 'Unknown error'}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showWithdrawDialog(int itemId) {
    final qtyController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Списати товар'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Кількість'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Примітка'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text.trim());
              final note = noteController.text.trim();

              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введіть коректну кількість')),
                );
                return;
              }

              Navigator.of(context).pop(); // Закрити діалог

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              final response = await rpc.sendRequest(
                method: 'Stock->withdraw_item_from_wh',
                params: {
                  'wh_id': widget.warehouseId,
                  'item_id': itemId,
                  'qty': qty,
                  'note': note,
                },
                sessionKey: sessionKey ?? '',
                id: 10,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успішно списано')),
                );
                loadWarehouseStock(); // Оновити список товарів
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Підтвердити'),
          ),
        ],
      ),
    );
  }

  void showReceiveDialog(int itemId) {
    final qtyController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отримати товар'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Кількість'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Примітка'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text.trim());
              final note = noteController.text.trim();

              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введіть коректну кількість')),
                );
                return;
              }

              Navigator.of(context).pop(); // Закрити діалог

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');
              final response = await rpc.sendRequest(
                method: 'Stock->receive_item_to_wh',
                params: {
                  'wh_id': widget.warehouseId,
                  'item_id': itemId,
                  'qty': qty,
                  'note': note,
                },
                sessionKey: sessionKey ?? '',
                id: 9,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успішно отримано')),
                );
                loadWarehouseStock(); // Оновити список товарів
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Підтвердити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Товари складу: ${widget.warehouseName}', style: const TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stockItems.isEmpty
              ? const Center(child: Text('Немає товарів на складі'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: stockItems.length,
                  itemBuilder: (context, index) {
                    final item = stockItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Без назви',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Кількість: ${int.tryParse(item['qty'] ?? '0') ?? 0}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Опис: ${item['description'] ?? 'Не вказано'}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    final itemId = int.tryParse(item['item_id'] ?? '0') ?? 0;
                                    showReceiveDialog(itemId);
                                  },
                                  child: const Text('Отримати'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    final itemId = int.tryParse(item['item_id'] ?? '0') ?? 0;
                                    showWithdrawDialog(itemId);
                                  },
                                  child: const Text('Списати'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Встановіть індекс активної сторінки
        onTap: (index) {
          if (index == 0) {
            // Перехід на сторінку зі складами
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WarehousesScreen()),
            );
          } else if (index == 1) {
            // Перехід на сторінку з товарами
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GoodsScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse),
            label: 'Склади',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Товари',
          ),
        ],
      ),
    );
  }
}
