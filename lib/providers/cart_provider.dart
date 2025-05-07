import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculate subtotal
  double get subtotal =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Define a fixed delivery fee (or calculate based on rules)
  double get deliveryFee =>
      subtotal > 500 ? 0 : 50; // Free delivery for orders above 500

  // Total price = subtotal + delivery fee
  double get total => subtotal + deliveryFee;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _cartService.getCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    required String sellerId,
    required String sellerName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.addToCart(
        productId: productId,
        productName: productName,
        price: price,
        imageUrl: imageUrl,
        sellerId: sellerId,
        sellerName: sellerName,
      );
      await loadCart(); // Refresh cart after adding
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await _cartService.updateQuantity(itemId, quantity);
      await loadCart(); // Refresh cart after updating
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await _cartService.removeFromCart(itemId);
      await loadCart(); // Refresh cart after removing
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
