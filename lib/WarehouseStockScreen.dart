import 'package:flutter/material.dart';
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
                    print('Item: $item');
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
                              'Кількість: ${item['qty']?.toString().isNotEmpty == true ? item['qty'] : '0'}',
//виправити з кількістю
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Опис: ${item['description'] ?? 'Не вказано'}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
