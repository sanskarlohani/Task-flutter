import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'wishlist_screen.dart';

/// Home screen displaying products with search, filter, and pagination
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial data
    Future.microtask(
      () => context.read<ProductProvider>().initialize(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Listen to scroll events for infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ProductProvider>().loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Store',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          // Wishlist button
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistScreen(),
                ),
              );
            },
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                return TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    provider.updateSearchQuery(value);
                  },
                );
              },
            ),
          ),
          // Filter section (expandable)
          if (_showFilters) _buildFilterSection(context),
          // Products grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null && provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await provider.fetchProducts(reset: true);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount:
                      provider.products.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at bottom
                    if (index == provider.products.length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final product = provider.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter section
  Widget _buildFilterSection(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category filter
                const Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: provider.selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) {
                          provider.updateCategory(null);
                        }
                      },
                    ),
                    ...provider.categories.map(
                      (category) => FilterChip(
                        label: Text(category),
                        selected: provider.selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            provider.updateCategory(category);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price range filter
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(provider.minPrice, provider.maxPrice),
                  min: 0,
                  max: 10000,
                  onChanged: (RangeValues values) {
                    provider.updatePriceRange(values.start, values.end);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${provider.minPrice.toStringAsFixed(0)}'),
                      Text('\$${provider.maxPrice.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Reset button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await provider.resetFilters();
                      setState(() {
                        _showFilters = false;
                      });
                    },
                    child: const Text('Reset Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
