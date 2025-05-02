import 'package:flutter/material.dart';
import 'package:kursova2/warehouses_screen.dart';

class GoodsScreen extends StatelessWidget {
  const GoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товари'),
      ),
      body: const Center(
        child: Text('Список усіх товарів'),
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
}