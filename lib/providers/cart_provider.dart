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
    return {'product': product.toJson(), 'quantity': quantity};
  }
}

class CartProvider extends ChangeNotifier {
  final FirebaseRepository _cartRepository = FirebaseRepository();
  AuthProvider? _authProvider;

  List<CartItem> _items = [];
  List<ProductModel> _wishlist = [];
  StreamSubscription<List<CartItem>>? _cartSubscription;
  StreamSubscription<List<ProductModel>>? _wishlistSubscription;

  // --- ADDED: Loading state for async operations ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
      // --- MODIFIED: Simplified listener logic ---
      _cartSubscription = _cartRepository.getCartStream(user.id).listen((
        cartItems,
      ) {
        _items = cartItems;
        notifyListeners();
      });

      _wishlistSubscription = _cartRepository.getWishlistStream(user.id).listen(
        (wishlistItems) {
          _wishlist = wishlistItems;
          notifyListeners();
        },
      );
    } else {
      _items = [];
      _wishlist = [];
      notifyListeners();
    }
  }

  // --- MODIFIED: Methods now only call Firebase and manage loading state ---

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _cartRepository.addToCart(user.id, product, quantity);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _cartRepository.removeFromCart(user.id, productId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _cartRepository.updateQuantity(user.id, productId, quantity);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _cartRepository.clearCart(user.id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist(ProductModel product) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _cartRepository.addToWishlist(user.id, product);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = _authProvider?.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _cartRepository.removeFromWishlist(user.id, productId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
