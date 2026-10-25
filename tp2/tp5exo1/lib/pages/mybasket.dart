import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class MyBasket extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jewels = ref.watch(treasureBoxProvider);

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100,
        title: const Text('Glow Basket'),
        centerTitle: true,
      ),
      body: jewels.isEmpty
          ? const Center(
        child: Text(
          ' Your treasure box is empty ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        itemCount: jewels.length,
        itemBuilder: (context, index) {
          final gem = jewels[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.grey.shade300,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(gem.imagePath, width: 60, height: 60, fit: BoxFit.cover),
                ),
                title: Text(gem.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${gem.cost.toStringAsFixed(2)}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
