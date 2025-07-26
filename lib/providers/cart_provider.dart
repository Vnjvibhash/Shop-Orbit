import 'package:flutter/foundation.dart';
import 'package:shoporbit/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final List<ProductModel> _wishlist = [];

  List<CartItem> get items => _items;
  List<ProductModel> get wishlist => _wishlist;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  bool isInWishlist(String productId) {
    return _wishlist.any((product) => product.id == productId);
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addToWishlist(ProductModel product) {
    if (!isInWishlist(product.id)) {
      _wishlist.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlist.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  void moveToCartFromWishlist(String productId) {
    final productIndex = _wishlist.indexWhere((product) => product.id == productId);
    if (productIndex >= 0) {
      final product = _wishlist[productIndex];
      addToCart(product);
      _wishlist.removeAt(productIndex);
      notifyListeners();
    }
  }
}