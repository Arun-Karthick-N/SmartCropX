class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  // Convert CartItem to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'image_url': imageUrl,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'quantity': quantity,
    };
  }

  // Factory method to create a CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '', // Default to empty string if null
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? 'Unknown Product',
      price: (json['price'] ?? 0).toDouble(), // Convert to double
      imageUrl: json['image_url'] ?? '',
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? 'Unknown Seller',
      quantity: json['quantity'] ?? 1, // Default to 1 if null
    );
  }
}
