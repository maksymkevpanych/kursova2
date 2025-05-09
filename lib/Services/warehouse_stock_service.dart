import 'package:flutter/material.dart';
import 'package:kursova2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kursova2/Services/rpc_service.dart';

final rpc = RpcService(url: apiUrl); 

Future<List<dynamic>> fetchWarehouseStock(int warehouseId, {String search = ''}) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
  }

  // Логування запиту
  print('Fetching warehouse stock with params: wh_id=$warehouseId, search=$search');

  final response = await rpc.sendRequest(
    method: 'Stock->get_stock_list',
    params: {
      'wh_id': warehouseId,
      'search': search,
    },
    sessionKey: sessionKey,
    id: 7,
  );

  // Логування відповіді сервера
  print('Server response: $response');

  if (response == null) {
    throw Exception('Server returned null response. Please check the server logs.');
  }

  if (response['result'] != null) {
    return response['result']['items'] ?? [];
  } else if (response['error'] != null) {
    throw Exception('RPC error: ${response['error']}');
  } else {
    throw Exception('Unexpected server response: $response');
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