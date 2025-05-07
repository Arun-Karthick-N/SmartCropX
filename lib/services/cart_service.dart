import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';

class CartService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'cart_items';

  // Get current user ID safely
  String get _userId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }

  // Get all cart items for the current user
  Future<List<CartItem>> getCartItems() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', _userId)
        .order('created_at');

    if (response.isEmpty) return []; // ✅ Fix: Ensure data is handled properly

    return response.map((item) => CartItem.fromJson(item)).toList();
  }

  // Add item to cart
  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    required String sellerId,
    required String sellerName,
  }) async {
    final userId = _userId;

    // Check if the product already exists in the cart
    final existing = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Update quantity if it exists
      await _supabase
          .from(_tableName)
          .update({'quantity': (existing['quantity'] as int? ?? 0) + 1}).eq(
          'id', existing['id']);
    } else {
      // Add new item if it doesn't exist
      await _supabase.from(_tableName).insert({
        'id': const Uuid().v4(), // ✅ Fix: Use const for performance improvement
        'user_id': userId,
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'image_url': imageUrl,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'quantity': 1,
      });
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    final userId = _userId;

    if (quantity <= 0) {
      await removeFromCart(itemId);
    } else {
      await _supabase
          .from(_tableName)
          .update({'quantity': quantity})
          .eq('id', itemId)
          .eq('user_id', userId);
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    final userId = _userId;
    await _supabase
        .from(_tableName)
        .delete()
        .eq('id', itemId)
        .eq('user_id', userId);
  }

  // Clear entire cart
  Future<void> clearCart() async {
    final userId = _userId;
    await _supabase.from(_tableName).delete().eq('user_id', userId);
  }

  // Get cart total
  Future<double> getCartTotal() async {
    final items = await getCartItems(); // Ensure items are resolved
    return items.fold<double>(
      0.0,
          (double total, CartItem item) => total + item.totalPrice,
    );
  }
}
