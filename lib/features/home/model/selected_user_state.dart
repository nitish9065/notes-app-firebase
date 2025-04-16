import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedUserIdNotifier extends StateNotifier<List<String>> {
  SelectedUserIdNotifier() : super([]);

  void add(String id) {
    state = [...state, id];
  }

  void addAll(List<String> ids) {
    state.clear();
    state = [...ids];
  }

  void remove(String id) {
    state = state.where((element) => element != id).toList();
  }

  bool exists(String id) {
    return state.contains(id);
  }

  List<String> ids() => state;
}