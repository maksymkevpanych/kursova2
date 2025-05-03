import 'package:flutter/material.dart';
import 'package:kursova2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kursova2/Services/rpc_service.dart';

final rpc = RpcService(url: apiUrl); 

Future<List<dynamic>> fetchWarehouseStock(int warehouseId) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
  }

  final response = await rpc.sendRequest(
    method: 'Stock->get_warehouse_stock',
    params: {'wh_id': warehouseId},
    sessionKey: sessionKey,
    id: 7,
  );

  if (response != null && response['result'] != null) {
    return response['result'];
  } else {
    throw Exception('Failed to load warehouse stock: ${response?['error'] ?? 'Unknown error'}');
  }
}

Future<void> receiveItem(
  BuildContext context,
  int warehouseId,
  int itemId,
  int qty,
  String note,
  Function onSuccess,
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  final response = await rpc.sendRequest(
    method: 'Stock->receive_item_to_wh',
    params: {
      'wh_id': warehouseId,
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
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> withdrawItem(
  BuildContext context,
  int warehouseId,
  int itemId,
  int qty,
  String note,
  Function onSuccess,
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  final response = await rpc.sendRequest(
    method: 'Stock->withdraw_item_from_wh',
    params: {
      'wh_id': warehouseId,
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
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}