import 'package:flutter/services.dart';
import 'storage_service.dart';

class HapticsService {
  final StorageService _storageService;

  HapticsService(this._storageService);

  void selectionClick() {
    if (_storageService.getHapticEnabled()) {
      HapticFeedback.selectionClick();
    }
  }

  void wordMatched() {
    if (_storageService.getHapticEnabled()) {
      HapticFeedback.mediumImpact();
    }
  }

  void wrongSwipe() {
    if (_storageService.getHapticEnabled()) {
      HapticFeedback.heavyImpact();
    }
  }

  void levelComplete() {
    if (_storageService.getHapticEnabled()) {
      HapticFeedback.vibrate();
    }
  }
}
