import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cosme_item.dart';
import '../providers/cart_provider.dart';

class HomePage extends ConsumerWidget {
  final List<CosmeItem> sparkles = [
    CosmeItem(label: 'Lustre Dew', cost: 16, imagePath: 'assets/photo1.jpg'),
    CosmeItem(label: 'Radiant Elixir', cost: 15, imagePath: 'assets/photo2.jpg'),
    CosmeItem(label: 'Mystic Mask', cost: 20, imagePath: 'assets/photo3.jpg'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef gemRef) {


    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(' Atelier du Glow '),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent.shade100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_rounded),
              onPressed: () => Navigator.pushNamed(context, '/mybasket'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: sparkles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final glowItem = sparkles[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.grey.shade300,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      glowItem.imagePath,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          glowItem.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text('\$${glowItem.cost.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            gemRef.read(treasureBoxProvider.notifier).addItem(glowItem);
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
