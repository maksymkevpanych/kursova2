import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kursova2/Services/rpc_service.dart';
import 'package:kursova2/constants.dart';

final rpc = RpcService(url: apiUrl); 

Future<List<dynamic>> fetchWarehouses({String search = ''}) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
  }

  final response = await rpc.sendRequest(
    method: 'Warehouse->get_warehouses_list',
    params: {
      'search': search,
    },
    sessionKey: sessionKey,
    id: 2,
  );

  if (response != null && response['result'] != null) {
    return response['result']['items'] ?? [];
  } else {
    throw Exception('Failed to load warehouses: ${response?['error'] ?? 'Unknown error'}');
  }
}

Future<void> deleteWarehouse(
  BuildContext context,
  int warehouseId,
  {int? moveStock, required Function onSuccess}
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
  }

  final response = await rpc.sendRequest(
    method: 'Warehouse->delete_warehouse',
    params: {
      'wh_id': warehouseId,
      if (moveStock != null) 'move_stock': moveStock,
    },
    sessionKey: sessionKey,
    id: 3,
  );

  if (response != null && response['result'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Склад успішно видалено')),
    );
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка видалення: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> createWarehouse(
  BuildContext context,
  String name,
  String address,
  String description,
  Function onSuccess,
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
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
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка створення: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> editWarehouse(
  BuildContext context,
  int warehouseId,
  String name,
  String address,
  String description,
  Function onSuccess,
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
  }

  final response = await rpc.sendRequest(
    method: 'Warehouse->edit_warehouse',
    params: {
      'wh_id': warehouseId,
      'wh_name': name,
      'address': address,
      'desc': description,
    },
    sessionKey: sessionKey,
    id: 4,
  );

  if (response != null && response['result'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Склад успішно оновлено')),
    );
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка оновлення: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> moveStock(
  BuildContext context,
  int oldWarehouseId,
  int newWarehouseId,
  Function onSuccess,
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
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
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка переміщення: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}