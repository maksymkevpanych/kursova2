import 'package:flutter/material.dart';
import 'package:kursova2/Services/goods_service.dart';
import 'package:kursova2/Screens/warehouses_screen.dart';
import 'package:kursova2/session_manager.dart'; // Імпортуємо SessionManager

class GoodsScreen extends StatefulWidget {
  const GoodsScreen({super.key});

  @override
  State<GoodsScreen> createState() => _GoodsScreenState();
}

class _GoodsScreenState extends State<GoodsScreen> {
  bool isLoading = true;
  bool isAdmin = false; // Додано для перевірки адміністратора
  List<dynamic> goods = [];
  final TextEditingController _searchController = TextEditingController(); // Контролер для пошуку

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadGoods();
  }

  Future<void> _checkAdminStatus() async {
    final adminStatus = await SessionManager.getIsAdmin();
    setState(() {
      isAdmin = adminStatus;
    });
  }

  Future<void> _loadGoods({String search = ''}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedGoods = await loadGoods(search: search);
      setState(() {
        goods = loadedGoods;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCreateItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imgUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Створити товар'),
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

              Navigator.of(context).pop();

              await createItem(context, name, description, imgUrl, _loadGoods);
            },
            child: const Text('Створити'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item) {
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

              Navigator.of(context).pop();

              // Конвертація item['id'] у int
              final itemId = int.tryParse(item['id'].toString()) ?? 0;

              await editItem(context, itemId, name, description, imgUrl, _loadGoods);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товари'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Пошук',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _loadGoods(search: _searchController.text.trim());
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
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
                                  if (isAdmin) // Перевірка на адміністратора
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          final itemId = int.tryParse(item['id'].toString()) ?? 0;
                                          if (value == 'delete') {
                                            deleteItem(context, itemId, _loadGoods);
                                          } else if (value == 'receive') {
                                            _showReceiveItemDialog(itemId);
                                          } else if (value == 'edit') {
                                            _showEditItemDialog(item);
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
                                            value: 'receive',
                                            child: Text('Отримати на склад'),
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
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showCreateItemDialog,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WarehousesScreen()),
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

  void _showReceiveItemDialog(int itemId) {
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

              Navigator.of(context).pop();

              await receiveItemToWarehouse(context, itemId, warehouseId, qty, note, _loadGoods);
            },
            child: const Text('Підтвердити'),
          ),
        ],
      ),
    );
  }
}