import 'package:flutter/material.dart';
import 'package:kursova2/Screens/goods_screen.dart';
import 'package:kursova2/Screens/warehouse_stock_screen.dart';
import 'package:kursova2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/rpc_service.dart'; 

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  final rpc = RpcService(url: apiUrl); 
  List<dynamic> warehouses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWarehouses();
  }

  Future<void> loadWarehouses() async {
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
      method: 'Warehouse->get_warehouses_list',
      params: {},
      sessionKey: sessionKey,
      id: 2,
    );

    if (response != null && response['result'] != null) {
      setState(() {
        warehouses = response['result'] ?? [];
        isLoading = false;
      });
    } else {
      print('Failed to load warehouses: ${response?['error'] ?? 'Unknown error'}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteWarehouse(int warehouseId, {int? move_stock}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionKey = prefs.getString('session_key');

    if (sessionKey == null) {
      print('No session key found.');
      return;
    }

    print('Deleting warehouse with ID: $warehouseId, move_stock: $move_stock');

    final response = await rpc.sendRequest(
      method: 'Warehouse->delete_warehouse',
      params: {
        'wh_id': warehouseId, 
        if (move_stock != null) 'move_stock': move_stock,
      },
      sessionKey: sessionKey,
      id: 3,
    );

    if (response != null && response['result'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Склад успішно видалено')),
      );
      loadWarehouses(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка видалення: ${response?['error'] ?? 'невідома помилка'}')),
      );
    }
  }

  void confirmDelete(int warehouseId, int? move_stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердження'),
        content: const Text('Ви точно хочете видалити цей склад?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              deleteWarehouse(warehouseId, move_stock: move_stock);
            },
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void editWarehouseDialog(Map<String, dynamic> warehouse) {
    final nameController = TextEditingController(text: warehouse['wh_name']);
    final addressController = TextEditingController(text: warehouse['address']);
    final descriptionController = TextEditingController(text: warehouse['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редагувати склад'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Адреса'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Опис'),
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
              final updatedName = nameController.text.trim();
              final updatedAddress = addressController.text.trim();
              final updatedDescription = descriptionController.text.trim();

              if (updatedName.isEmpty || updatedAddress.isEmpty || updatedDescription.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Усі поля повинні бути заповнені')),
                );
                return;
              }

              Navigator.of(context).pop(); 

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              if (sessionKey == null) {
                print('No session key found.');
                return;
              }

              print('Request payload: ${{
                'wh_id': warehouse['id'],
                'wh_name': updatedName,
                'address': updatedAddress,
                'desc': updatedDescription,
              }}');

              final response = await rpc.sendRequest(
                method: 'Warehouse->edit_warehouse',
                params: {
                  'wh_id': warehouse['id'],
                  'wh_name': updatedName,
                  'address': updatedAddress,
                  'desc': updatedDescription,
                },
                sessionKey: sessionKey,
                id: 4,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Склад успішно оновлено')),
                );
                loadWarehouses(); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка оновлення: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Зберегти'),
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
        title: const Text('Склади', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = warehouses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse['wh_name'] ?? 'Без назви',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Адреса: ${warehouse['address'] ?? 'Не вказано'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Опис: ${warehouse['description'] ?? 'Не вказано'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                editWarehouseDialog(warehouse);
                              } else if (value == 'delete') {
                                final warehouseId = parseInt(warehouse['id']);
                                final moveStock = parseInt(warehouse['move_stock']);
                                if (warehouseId != null) {
                                  confirmDelete(warehouseId, moveStock);
                                }
                              } else if (value == 'view') {
                                final warehouseId = parseInt(warehouse['id']);
                                if (warehouseId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WarehouseStockScreen(
                                        warehouseId: warehouseId,
                                        warehouseName: warehouse['wh_name'] ?? '',
                                      ),
                                    ),
                                  );
                                }
                              } else if (value == 'manage') {
                                final warehouseId = parseInt(warehouse['id']);
                                if (warehouseId != null) {
                                  manageWarehouseStock(warehouseId);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Редагувати'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Видалити'),
                              ),
                              const PopupMenuItem(
                                value: 'view',
                                child: Text('Переглянути товари'),
                              ),
                              const PopupMenuItem(
                                value: 'manage',
                                child: Text('Керувати товарами'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createWarehouseDialog();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, 
        onTap: (index) {
          if (index == 0) {
            
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

  void createWarehouseDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Створити новий склад'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Адреса'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Опис'),
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
              final name = nameController.text.trim();
              final address = addressController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Назва складу обов\'язкова')),
                );
                return;
              }

              Navigator.of(context).pop(); 

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              if (sessionKey == null) {
                print('No session key found.');
                return;
              }

              final response = await rpc.sendRequest(
                method: 'Warehouse->create_warehouse',
                params: {
                  'wh_name': name,
                  'address': address,
                  'desc': description,
                },
                sessionKey: sessionKey,
                id: 6,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Склад успішно створено')),
                );
                loadWarehouses(); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка створення: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Створити'),
          ),
        ],
      ),
    );
  }

  void manageWarehouseStock(int oldWarehouseId) async {
    final targetWarehouseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Перемістити товари'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetWarehouseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ID нового складу'),
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
              final newWarehouseId = int.tryParse(targetWarehouseController.text.trim());

              if (newWarehouseId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введіть коректний ID нового складу')),
                );
                return;
              }

              Navigator.of(context).pop(); 

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              if (sessionKey == null) {
                print('No session key found.');
                return;
              }
              

              final response = await rpc.sendRequest(
                method: 'Stock->move_stock_from_wh_to_wh',
                params: {
                  'old_wh': oldWarehouseId,
                  'new_wh': newWarehouseId,
                },
                sessionKey: sessionKey,
                id: 8,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товари успішно переміщено')),
                );
                loadWarehouses(); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка переміщення: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Перемістити'),
          ),
        ],
      ),
    );
  }
}
