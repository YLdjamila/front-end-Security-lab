import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cosme_item.dart';

final treasureBoxProvider = StateNotifierProvider<TreasureBox, List<CosmeItem>>((ref) {
  return TreasureBox();
});

class TreasureBox extends StateNotifier<List<CosmeItem>> {
  TreasureBox() : super([]);

  void addItem(CosmeItem item) {
    state = [...state, item];
  }
}
