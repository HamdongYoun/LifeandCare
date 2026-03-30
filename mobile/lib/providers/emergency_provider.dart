import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final emergencyProvider = ChangeNotifierProvider((ref) => EmergencyNotifier());

class EmergencyNotifier extends ChangeNotifier {
  bool _isEmergencyActive = false;
  int _countdown = 3;
  Timer? _timer;

  bool get isEmergencyActive => _isEmergencyActive;
  int get countdown => _countdown;

  void startEmergencyCountdown() {
    if (_isEmergencyActive) return;
    
    _isEmergencyActive = true;
    _countdown = 3;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
      } else {
        _cancelTimer();
        _makeEmergencyCall();
      }
    });
  }

  void cancelEmergency() {
    _cancelTimer();
    _isEmergencyActive = false;
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _makeEmergencyCall() async {
    final Uri url = Uri.parse('tel:119');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
    _isEmergencyActive = false;
    notifyListeners();
  }
}
