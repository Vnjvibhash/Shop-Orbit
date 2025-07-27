import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/repositories/firebase_repository.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductModel.fromJson(map['product']),
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

class CartProvider extends ChangeNotifier {
  final FirebaseRepository _cartRepository = FirebaseRepository();
  AuthProvider? _authProvider;

  List<CartItem> _items = [];
  List<ProductModel> _wishlist = [];
  StreamSubscription<List<CartItem>>? _cartSubscription;
  StreamSubscription<List<ProductModel>>? _wishlistSubscription;
  bool _isLocallyUpdating = false;

  CartProvider();

  List<CartItem> get items => _items;
  List<ProductModel> get wishlist => _wishlist;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  bool isInWishlist(String productId) {
    return _wishlist.any((product) => product.id == productId);
  }

  void update(AuthProvider auth) {
    if (_authProvider?.currentUser?.id != auth.currentUser?.id) {
      _authProvider = auth;
      _onAuthStateChanged();
    }
  }

  void _onAuthStateChanged() {
    final user = _authProvider?.currentUser;
    _cartSubscription?.cancel();
    _wishlistSubscription?.cancel();

    if (user != null) {
      _cartSubscription =
          _cartRepository.getCartStream(user.id).listen((cartItems) {
        if (!_isLocallyUpdating) {
          _items = cartItems;
          notifyListeners();
        }
      });

      _wishlistSubscription =
          _cartRepository.getWishlistStream(user.id).listen((wishlistItems) {
        if (!_isLocallyUpdating) {
          _wishlist = wishlistItems;
          notifyListeners();
        }
      });
    } else {
      _items = [];
      _wishlist = [];
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLocallyUpdating = true;
    try {
      final existingIndex =
          _items.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _items[existingIndex].quantity += quantity;
      } else {
        _items.add(CartItem(product: product, quantity: quantity));
      }
      notifyListeners();
      await _cartRepository.addToCart(user.id, product, quantity);
    } finally {
      _isLocallyUpdating = false;
    }
  }

  Future<void> removeFromCart(String productId) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLocallyUpdating = true;
    try {
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();
      await _cartRepository.removeFromCart(user.id, productId);
    } finally {
      _isLocallyUpdating = false;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _isLocallyUpdating = true;
      try {
        if (quantity <= 0) {
          _items.removeAt(index);
        } else {
          _items[index].quantity = quantity;
        }
        notifyListeners();
        await _cartRepository.updateQuantity(user.id, productId, quantity);
      } finally {
        _isLocallyUpdating = false;
      }
    }
  }

  Future<void> clearCart() async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLocallyUpdating = true;
    try {
      _items.clear();
      notifyListeners();
      await _cartRepository.clearCart(user.id);
    } finally {
      _isLocallyUpdating = false;
    }
  }

  Future<void> addToWishlist(ProductModel product) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLocallyUpdating = true;
    try {
      if (!isInWishlist(product.id)) {
        _wishlist.add(product);
        notifyListeners();
      }
      await _cartRepository.addToWishlist(user.id, product);
    } finally {
      _isLocallyUpdating = false;
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLocallyUpdating = true;
    try {
      _wishlist.removeWhere((product) => product.id == productId);
      notifyListeners();
      await _cartRepository.removeFromWishlist(user.id, productId);
    } finally {
      _isLocallyUpdating = false;
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}