import 'package:flutter/foundation.dart';

import 'event.dart';

/// Manages carousel navigation through multiple entries (multi_daily trackers).
class EntryCarouselController extends ChangeNotifier {
  EntryCarouselController({
    required List<Event> entries,
    required int initialIndex,
  })  : _entries = entries,
        _currentIndex = initialIndex;

  final List<Event> _entries;
  int _currentIndex;

  List<Event> get entries => _entries;
  int get currentIndex => _currentIndex;
  Event get currentEntry => _entries[_currentIndex];
  bool get hasNextEntry => _currentIndex < _entries.length - 1;
  bool get hasPreviousEntry => _currentIndex > 0;

  void nextEntry() {
    if (hasNextEntry) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousEntry() {
    if (hasPreviousEntry) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToIndex(int index) {
    if (index >= 0 && index < _entries.length && index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
