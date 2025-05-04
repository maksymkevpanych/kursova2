import 'package:flutter/material.dart';
import 'package:kursova2/constants.dart';
import 'package:kursova2/Services/rpc_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rpc = RpcService(url: apiUrl);

Future<List<dynamic>> loadGoods() async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  if (sessionKey == null) {
    throw Exception('No session key found.');
  }

  final response = await rpc.sendRequest(
    method: 'Goods->get_items_list',
    params: {
      'search': '',
      'wh_id': null,
    },
    sessionKey: sessionKey,
    id: 1,
  );

  if (response != null && response['result'] != null) {
    return response['result'];
  } else {
    throw Exception('Failed to load goods: ${response?['error'] ?? 'Unknown error'}');
  }
}

Future<void> deleteItem(BuildContext context, int itemId, Function onSuccess) async {
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
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> receiveItemToWarehouse(
  BuildContext context,
  int itemId,
  int warehouseId,
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
    id: 5,
  );

  if (response != null && response['result'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар успішно отримано на склад')),
    );
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> createItem(
  BuildContext context,
  String name,
  String description,
  String imgUrl,
  Function onSuccess,
) async {
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
    id: 6,
  );

  if (response != null && response['result'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар успішно створено')),
    );
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка створення: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}

Future<void> editItem(
  BuildContext context,
  int itemId,
  String name,
  String description,
  String imgUrl,
  Function onSuccess,
) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = prefs.getString('session_key');

  final response = await rpc.sendRequest(
    method: 'Goods->edit_item',
    params: {
      'item_id': itemId,
      'name': name,
      'description': description,
      'img_url': imgUrl,
    },
    sessionKey: sessionKey ?? '',
    id: 7,
  );

  if (response != null && response['result'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар успішно оновлено')),
    );
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Помилка оновлення: ${response?['error'] ?? 'невідома помилка'}')),
    );
  }
}