import 'package:flutter/material.dart';

class IBANModel extends ChangeNotifier {
  String _iban = "";

  String get iban => _iban;

  void setIBAN(String iban) {
    _iban = iban;
    notifyListeners();
  }
}
