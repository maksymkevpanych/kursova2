import 'package:flutter/material.dart';
import 'package:kursova2/Services/warehouse_stock_service.dart';
import 'package:kursova2/Screens/goods_screen.dart';
import 'package:kursova2/Screens/warehouses_screen.dart';
import 'package:kursova2/session_manager.dart'; // Імпортуємо SessionManager

class WarehouseStockScreen extends StatefulWidget {
  final int warehouseId;
  final String warehouseName;

  const WarehouseStockScreen({super.key, required this.warehouseId, required this.warehouseName});

  @override
  State<WarehouseStockScreen> createState() => _WarehouseStockScreenState();
}

class _WarehouseStockScreenState extends State<WarehouseStockScreen> {
  bool isLoading = true;
  bool isAdmin = false; // Додано для перевірки адміністратора
  List<dynamic> stockItems = [];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadWarehouseStock();
  }

  Future<void> _checkAdminStatus() async {
    final adminStatus = await SessionManager.getIsAdmin();
    print('Admin status: $adminStatus'); // Додано для перевірки
    setState(() {
      isAdmin = adminStatus;
    });
  }

  Future<void> _loadWarehouseStock() async {
    setState(() {
      isLoading = true;
    });

    try {
      final items = await fetchWarehouseStock(widget.warehouseId);
      setState(() {
        stockItems = items;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showReceiveDialog(int itemId) {
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
            onPressed: () {
              final qty = int.tryParse(qtyController.text.trim());
              final note = noteController.text.trim();

              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введіть коректну кількість')),
                );
                return;
              }

              Navigator.of(context).pop();

              receiveItem(context, widget.warehouseId, itemId, qty, note, _loadWarehouseStock);
            },
            child: const Text('Підтвердити'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(int itemId) {
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
            onPressed: () {
              final qty = int.tryParse(qtyController.text.trim());
              final note = noteController.text.trim();

              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введіть коректну кількість')),
                );
                return;
              }

              Navigator.of(context).pop();

              withdrawItem(context, widget.warehouseId, itemId, qty, note, _loadWarehouseStock);
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
                            if (isAdmin) // Перевірка на адміністратора
                              Align(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    final itemId = int.tryParse(item['item_id'] ?? '0') ?? 0;
                                    if (value == 'receive') {
                                      _showReceiveDialog(itemId);
                                    } else if (value == 'withdraw') {
                                      _showWithdrawDialog(itemId);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'receive',
                                      child: Text('Отримати'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'withdraw',
                                      child: Text('Списати'),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WarehousesScreen()),
            );
          } else if (index == 1) {
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