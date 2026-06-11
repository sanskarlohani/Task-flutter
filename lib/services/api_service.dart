import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// Service class to handle all API calls and caching
class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const String productsEndpoint = '$baseUrl/products';
  static const int defaultLimit = 12; // Products per page
  static const String cacheKeyPrefix = 'cached_products_';
  static const String productItemCacheKeyPrefix = 'cached_product_';
  static const String categoryListCacheKey = 'cached_categories';

  String _buildCacheKey({
    required int skip,
    required int limit,
    required String searchQuery,
    required String? selectedCategory,
    required double minPrice,
    required double maxPrice,
  }) {
    return [
      cacheKeyPrefix,
      'skip=$skip',
      'limit=$limit',
      'q=${searchQuery.trim().toLowerCase()}',
      'cat=${selectedCategory?.trim().toLowerCase() ?? ''}',
      'min=$minPrice',
      'max=$maxPrice',
    ].join('|');
  }

  /// Fetch products with pagination, search, and filter
  /// [skip]: Number of products to skip (for pagination)
  /// [limit]: Number of products to fetch
  /// [searchQuery]: Search term for product title
  /// [selectedCategory]: Filter by category
  /// [minPrice]: Minimum price filter
  /// [maxPrice]: Maximum price filter
  Future<Map<String, dynamic>> fetchProducts({
    int skip = 0,
    int limit = defaultLimit,
    String searchQuery = '',
    String? selectedCategory,
    double minPrice = 0,
    double maxPrice = double.infinity,
  }) async {
    final cacheKey = _buildCacheKey(
      skip: skip,
      limit: limit,
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    try {
      // Build URL with query parameters
      String url = '$productsEndpoint?skip=$skip&limit=$limit';

      // Add search functionality
      if (searchQuery.isNotEmpty) {
        url = '$baseUrl/products/search?q=$searchQuery&limit=$limit&skip=$skip';
      } else if (selectedCategory != null && selectedCategory.isNotEmpty) {
        url =
            '$baseUrl/products/category/$selectedCategory?skip=$skip&limit=$limit';
      }

      // Fetch from API
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Product> products = [];

        // Parse products
        if (data['products'] != null) {
          products = List<Product>.from(
            (data['products'] as List).map((x) => Product.fromJson(x)),
          );
        }

        // Apply price filter
        if (minPrice > 0 || maxPrice < double.infinity) {
          products = products
              .where((p) => p.price >= minPrice && p.price <= maxPrice)
              .toList();
        }

        // Cache the products
        await _cacheProducts(products, cacheKey);

        return {
          'products': products,
          'total': data['total'] ?? 0,
          'skip': skip,
          'limit': limit,
        };
      } else {
        // Try to load from cache on error
        final cached = await _getCachedProducts(cacheKey);
        if (cached.isNotEmpty) {
          return {
            'products': cached,
            'total': cached.length,
            'skip': skip,
            'limit': limit,
            'fromCache': true,
          };
        }
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Attempt to load from cache if API fails
      final cached = await _getCachedProducts(cacheKey);
      if (cached.isNotEmpty) {
        return {
          'products': cached,
          'total': cached.length,
          'skip': skip,
          'limit': limit,
          'fromCache': true,
        };
      }
      rethrow;
    }
  }

  /// Fetch all categories available
  Future<List<String>> fetchCategories() async {
    try {
      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedCategories = prefs.getString(categoryListCacheKey);
      if (cachedCategories != null) {
        return List<String>.from(
          json.decode(cachedCategories) as List,
        );
      }

      // Fetch from API
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/categories'),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> categories = json.decode(response.body);
        final categoryList = List<String>.from(categories);

        // Cache categories
        await prefs.setString(categoryListCacheKey, json.encode(categoryList));

        return categoryList;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Return empty list if API fails
      return [];
    }
  }

  /// Fetch a single product by ID
  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$id'),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final product = Product.fromJson(json.decode(response.body));
        await _cacheProduct(product);
        return product;
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cache products locally using SharedPreferences
  Future<void> _cacheProducts(List<Product> products, String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = json.encode(
        products.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(cacheKey, jsonList);

      for (final product in products) {
        await prefs.setString(
          '$productItemCacheKeyPrefix${product.id}',
          json.encode(product.toJson()),
        );
      }
    } catch (e) {
      // Silently fail caching - not critical
      print('Cache error: $e');
    }
  }

  Future<void> _cacheProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$productItemCacheKeyPrefix${product.id}',
        json.encode(product.toJson()),
      );
    } catch (e) {
      print('Cache error: $e');
    }
  }

  /// Retrieve cached products
  Future<List<Product>> _getCachedProducts(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        final List<dynamic> decoded = json.decode(cachedJson);
        return decoded.map((p) => Product.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Retrieve a cached single product, if available.
  Future<Product?> getCachedProductById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('$productItemCacheKeyPrefix$id');
      if (cachedJson == null) return null;
      return Product.fromJson(json.decode(cachedJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached products
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith(cacheKeyPrefix) ||
            key.startsWith(productItemCacheKeyPrefix) ||
            key == categoryListCacheKey) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
