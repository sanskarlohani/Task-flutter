import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// State management for products using ChangeNotifier
class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Product list state
  List<Product> _products = [];
  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  // Pagination state
  int _currentSkip = 0;
  int _totalProducts = 0;
  static const int pageLimit = 12;

  // Search and filter state
  String _searchQuery = '';
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 10000;
  List<String> _categories = [];

  // Wishlist state
  List<int> _wishlistIds = [];

  // Debounce timer for search
  Timer? _debounceTimer;

  // Getters
  List<Product> get products => _products;
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _totalProducts;
  int get currentSkip => _currentSkip;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  List<String> get categories => _categories;
  List<int> get wishlistIds => _wishlistIds;

  /// Initialize the provider - load wishlist and categories
  Future<void> initialize() async {
    await _loadWishlist();
    await _loadCategories();
    await fetchProducts();
  }

  /// Fetch products from API with filters
  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      _currentSkip = 0;
      _products = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.fetchProducts(
        skip: _currentSkip,
        limit: pageLimit,
        searchQuery: _searchQuery,
        selectedCategory: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

      _allProducts = result['products'];
      _totalProducts = result['total'] ?? 0;

      if (reset || _currentSkip == 0) {
        _products = _allProducts;
      } else {
        _products.addAll(_allProducts);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products (infinite scroll)
  Future<void> loadMoreProducts() async {
    if (_isLoading || _currentSkip >= _totalProducts) return;

    _currentSkip += pageLimit;
    await fetchProducts(reset: false);
  }

  /// Load all available categories
  Future<void> _loadCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  /// Update search query with debounce
  void updateSearchQuery(String query) {
    // Cancel previous debounce
    _debounceTimer?.cancel();

    _searchQuery = query;

    // Debounce for 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await fetchProducts(reset: true);
    });
  }

  /// Update selected category
  Future<void> updateCategory(String? category) async {
    _selectedCategory = category;
    await fetchProducts(reset: true);
  }

  /// Update price range filter
  Future<void> updatePriceRange(double min, double max) async {
    _minPrice = min;
    _maxPrice = max;
    await fetchProducts(reset: true);
  }

  /// Reset all filters
  Future<void> resetFilters() async {
    _searchQuery = '';
    _selectedCategory = null;
    _minPrice = 0;
    _maxPrice = 10000;
    await fetchProducts(reset: true);
  }

  /// Add product to wishlist
  Future<void> addToWishlist(Product product) async {
    if (!_wishlistIds.contains(product.id)) {
      _wishlistIds.add(product.id);
      await _saveWishlist();
      notifyListeners();
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(Product product) async {
    _wishlistIds.remove(product.id);
    await _saveWishlist();
    notifyListeners();
  }

  /// Check if product is in wishlist
  bool isInWishlist(int productId) {
    return _wishlistIds.contains(productId);
  }

  /// Save wishlist to local storage
  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'wishlist_ids', _wishlistIds.map((id) => id.toString()).toList());
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  /// Load wishlist from local storage
  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistStrings = prefs.getStringList('wishlist_ids') ?? [];
      _wishlistIds = wishlistStrings.map((id) => int.parse(id)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  /// Clear all wishlist items
  Future<void> clearWishlist() async {
    _wishlistIds.clear();
    await _saveWishlist();
    notifyListeners();
  }

  /// Get wishlist products
  List<Product> getWishlistProducts() {
    return _products.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _apiService.clearCache();
    _products = [];
    _currentSkip = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
