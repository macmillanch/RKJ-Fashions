import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../../core/app_config.dart';

class DatabaseService {
  String get _baseUrl => AppConfig.baseUrl;

  // Users
  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/debug/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  // Products
  Stream<List<Product>> getProducts() async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/products'));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          yield data.map((json) => Product.fromJson(json)).toList();
        }
      } catch (e) {
        debugPrint('Error fetching products: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 10)); // Poll every 10s
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add product');
    }
  }

  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$productId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // Orders
  // Orders
  Stream<List<OrderModel>> getOrders() async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/orders'));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          yield data.map((json) => OrderModel.fromJson(json)).toList();
        } else {
          yield [];
        }
      } catch (e) {
        debugPrint('Error fetching orders: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 10)); // Poll every 10s
    }
  }

  Stream<List<OrderModel>> getUserOrders(String userId) async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/orders/$userId'));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          yield data.map((json) => OrderModel.fromJson(json)).toList();
        } else {
          yield [];
        }
      } catch (e) {
        debugPrint('Error fetching user orders: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 10)); // Poll every 10s
    }
  }

  Future<void> createOrder(OrderModel order) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create order');
    }
  }

  Future<void> markOrderPacked(String orderId) async {
    // Stub
  }

  Future<void> markOrderShipped(
    String orderId,
    String courier,
    String trackingId,
    String slipUrl,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'Shipped', 'tracking_id': trackingId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order');
    }
  }

  Future<void> confirmDelivery(String orderId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'Delivered'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order');
    }
  }

  Future<Map<String, dynamic>> trackSpeedPost(String consignmentNumber) async {
    const apiKey = '9a19ea9211mshc83699f10d28b68p1f7821jsn58469b993489';
    try {
      final response = await http.get(
        Uri.parse(
          'https://speedpost-tracking-api-for-india-post.p.prapidapi.com/speedpost/track/$consignmentNumber',
        ),
        headers: {
          'x-rapidapi-host':
              'speedpost-tracking-api-for-india-post.p.rapidapi.com',
          'x-rapidapi-key': apiKey,
        },
      );
      debugPrint(
        'Tracking Response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'API Error: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('Tracking Error: $e');
      return {'error': 'Network Error: $e'};
    }
  }

  // Wishlist
  Future<void> addToWishlist(String userId, Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wishlist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'productId': product.id}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/wishlist/$userId/$productId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove from wishlist');
    }
  }

  Stream<List<Product>> getWishlist(String userId) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/wishlist/$userId'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          yield data.map((json) => Product.fromJson(json)).toList();
        }
      } catch (e) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  // Addresses
  Stream<List<Map<String, dynamic>>> getAddresses(String userId) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/addresses/$userId'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          yield List<Map<String, dynamic>>.from(data);
        }
      } catch (e) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> addAddress(
    String userId,
    Map<String, dynamic> addressData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/addresses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, ...addressData}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add address');
    }
  }

  Future<void> updateAddress(
    String userId,
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/addresses/$userId/$addressId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(addressData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update address');
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/addresses/$userId/$addressId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete address');
    }
  }

  Future<void> addReview(
    String userId,
    String productId,
    int rating,
    String reviewText,
    List<String> imageUrls,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'reviewText': reviewText,
        'imageUrls': imageUrls,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add review');
    }
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String userId) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/notifications/$userId'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          yield List<Map<String, dynamic>>.from(data);
        }
      } catch (e) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future<void> markNotificationsRead(String userId) async {
    await http.put(Uri.parse('$_baseUrl/notifications/read/$userId'));
  }

  Future<void> sendNotification(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await http.post(
      Uri.parse('$_baseUrl/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, ...data}),
    );
  }

  Future<Map<String, dynamic>> getSettings() async {
    final response = await http.get(Uri.parse('$_baseUrl/settings'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  Future<void> updateSettings(Map<String, String> settings) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(settings),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update settings');
    }
  }
}
