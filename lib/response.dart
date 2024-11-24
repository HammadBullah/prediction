import 'package:flutter/material.dart';

class ResponseDataModel extends ChangeNotifier {
  String _responseData = "";

  String get responseData => _responseData;

  // Set the response data and notify listeners
  void setResponseData(String data) {
    _responseData = data;
    notifyListeners(); // Notifies all widgets that are listening to this model
  }
}
