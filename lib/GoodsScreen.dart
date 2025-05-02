import 'package:flutter/material.dart';
import 'package:kursova2/warehouses_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpc_service.dart'; // Ваш RPC сервіс

class GoodsScreen extends StatefulWidget {
  const GoodsScreen({super.key});

  @override
  State<GoodsScreen> createState() => _GoodsScreenState();
}

class _GoodsScreenState extends State<GoodsScreen> {
  final rpc = RpcService(url: 'http://localhost/kursach/index.php');
  bool isLoading = true;
  List<dynamic> goods = [];

  @override
  void initState() {
    super.initState();
    loadGoods();
  }

  Future<void> loadGoods() async {
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
      method: 'Goods->get_items_list',
      params: {
        'search': '',
        'wh_id': null,
      },
      sessionKey: sessionKey ?? '',
      id: 1,
    );

    if (response != null && response['result'] != null) {
      setState(() {
        goods = response['result'];
        isLoading = false;
      });
    } else {
      print('Failed to load goods: ${response?['error'] ?? 'Unknown error'}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товари'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : goods.isEmpty
              ? const Center(child: Text('Немає доступних товарів'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: goods.length,
                  itemBuilder: (context, index) {
                    final item = goods[index];
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
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Опис: ${item['description'] ?? 'Не вказано'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showEditItemDialog(item);
                                  },
                                  child: const Text('Редагувати'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    confirmDeleteItem(item['id']);
                                  },
                                  child: const Text('Видалити'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showReceiveItemDialog(item['id']);
                                  },
                                  child: const Text('Отримати на склад'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateItemDialog();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Встановіть індекс активної сторінки
        onTap: (index) {
          if (index == 0) {
            // Перехід на сторінку зі складами
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WarehousesScreen()),
            );
          } else if (index == 1) {
            // Залишаємося на цій сторінці
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

  void showCreateItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imgUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Створити новий товар'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Опис'),
            ),
            TextField(
              controller: imgUrlController,
              decoration: const InputDecoration(labelText: 'URL зображення'),
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
              final description = descriptionController.text.trim();
              final imgUrl = imgUrlController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Назва не може бути порожньою')),
                );
                return;
              }

              Navigator.of(context).pop(); // Закрити діалог

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              final response = await rpc.sendRequest(
                method: 'Goods->create_item',
                params: {
                  'name': name,
                  'description': description,
                  'img_url': imgUrl,
                },
                sessionKey: sessionKey ?? '',
                id: 2,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успішно створено')),
                );
                loadGoods(); // Оновити список товарів
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Створити'),
          ),
        ],
      ),
    );
  }

  void showEditItemDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final descriptionController = TextEditingController(text: item['description']);
    final imgUrlController = TextEditingController(text: item['img_url']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редагувати товар'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Опис'),
            ),
            TextField(
              controller: imgUrlController,
              decoration: const InputDecoration(labelText: 'URL зображення'),
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
              final description = descriptionController.text.trim();
              final imgUrl = imgUrlController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Назва не може бути порожньою')),
                );
                return;
              }

              Navigator.of(context).pop(); // Закрити діалог

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              final response = await rpc.sendRequest(
                method: 'Goods->edit_item',
                params: {
                  'item_id': item['id'],
                  'name': name,
                  'description': description,
                  'img_url': imgUrl,
                },
                sessionKey: sessionKey ?? '',
                id: 3,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успішно оновлено')),
                );
                loadGoods(); // Оновити список товарів
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  void confirmDeleteItem(int itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити товар'),
        content: const Text('Ви впевнені, що хочете видалити цей товар?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop(); // Закрити діалог

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              final response = await rpc.sendRequest(
                method: 'Goods->delete_item',
                params: {
                  'item_id': itemId,
                },
                sessionKey: sessionKey ?? '',
                id: 4,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успішно видалено')),
                );
                loadGoods(); // Оновити список товарів
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
                );
              }
            },
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  void showReceiveItemDialog(int itemId) {
    final qtyController = TextEditingController();
    final noteController = TextEditingController();
    final warehouseIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отримати товар на склад'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: warehouseIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ID складу'),
            ),
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
              final warehouseId = int.tryParse(warehouseIdController.text.trim());
              final qty = int.tryParse(qtyController.text.trim());
              final note = noteController.text.trim();

              if (warehouseId == null || qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введіть коректні дані')),
                );
                return;
              }

              Navigator.of(context).pop(); // Закрити діалог

              final prefs = await SharedPreferences.getInstance();
              final sessionKey = prefs.getString('session_key');

              final response = await rpc.sendRequest(
                method: 'Goods->receive_item_to_wh',
                params: {
                  'wh_id': warehouseId,
                  'item_id': itemId,
                  'qty': qty,
                  'note': note,
                },
                sessionKey: sessionKey ?? '',
                id: 5,
              );

              if (response != null && response['result'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успішно отримано на склад')),
                );
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
}