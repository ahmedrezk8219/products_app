import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

enum ProductState { initial, loading, loaded, error }

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductModel> _products = [];
  String _errorMessage = '';
  ProductState _state = ProductState.initial;

  List<ProductModel> get products => _products;
  String get errorMessage => _errorMessage;
  ProductState get state => _state;

  Future<void> loadProducts() async {
    _state = ProductState.loading;
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts();
      _state = ProductState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '');
      _state = ProductState.error;
    }
    notifyListeners();
  }
}