# Product Store Flutter App

A feature-rich Flutter application that displays products from the DummyJSON API with advanced features like search, filtering, pagination, wishlist, and offline support.

## Features

### Core Features
- ✅ **Product List Screen** - Display products in a grid with image, title, price, and category
- ✅ **Real-time Search** - Search products by title with 500ms debounce
- ✅ **Filtering** - Filter products by category and price range
- ✅ **Pagination** - Infinite scrolling with automatic load-more functionality
- ✅ **Product Detail Screen** - View complete product information, images carousel, stock status
- ✅ **Responsive UI** - Works on all screen sizes

### Bonus Features
- ✅ **Wishlist System** - Add/remove products from wishlist with persistent storage
- ✅ **Offline Support** - View cached products when internet is unavailable
- ✅ **Image Caching** - Efficient image loading with cached_network_image
- ✅ **Rating & Discounts** - Display product ratings and discount badges

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── product.dart                   # Product data model with JSON serialization
├── services/
│   └── api_service.dart               # API calls and local caching service
├── providers/
│   └── product_provider.dart          # State management using Provider
├── screens/
│   ├── home_screen.dart               # Main product list with search & filters
│   ├── product_detail_screen.dart     # Detailed product view
│   └── wishlist_screen.dart           # Wishlist management
├── widgets/
│   └── product_card.dart              # Reusable product card component
└── utils/                             # (For future utilities)
```

## Dependencies

### Main Dependencies
- **provider** (v6.1.0) - State management
- **http** (v1.1.0) - HTTP requests
- **shared_preferences** (v2.2.2) - Local storage for wishlist
- **cached_network_image** (v3.3.0) - Efficient image loading
- **sqflite** (v2.3.0) - Local database (optional, for extended offline support)
- **intl** (v0.19.0) - Internationalization utilities

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK
- Any IDE (VS Code, Android Studio, IntelliJ)

### Installation Steps

1. **Clone or Extract the Project**
```bash
cd Task-flutter
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Run the Application**
```bash
flutter run
```

### Run on Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Build for Release
```bash
# iOS
flutter build ios

# Android
flutter build apk
flutter build appbundle
```

## API Integration

### DummyJSON API Endpoints Used

```
GET /products                    # Get all products with pagination
GET /products/search?q=query     # Search products by query
GET /products/category/:name     # Get products by category
GET /products/categories         # Get all available categories
GET /products/:id                # Get single product details
```

### API Parameters
- **skip**: Number of products to skip (pagination)
- **limit**: Number of products to return (default: 12)
- **q**: Search query string

## Code Structure Explanation

### Models (Product.dart)
- Handles JSON serialization and deserialization
- Contains copyWith method for immutability patterns
- Validates and transforms API data

### Services (ApiService.dart)
- Manages all API calls with error handling
- Implements caching for offline support
- Handles search, filter, and pagination
- Timeout protection for requests

### Providers (ProductProvider.dart)
- Centralized state management using ChangeNotifier
- Manages products, filters, search, and wishlist state
- Implements debounce for search (500ms)
- Handles wishlist persistence with SharedPreferences

### Screens
- **HomeScreen**: Main UI with search bar, filters, and product grid
- **ProductDetailScreen**: Detailed view with image carousel and actions
- **WishlistScreen**: Dedicated wishlist management screen

### Widgets
- **ProductCard**: Reusable component for displaying products
- Shows discount badges, wishlist button, ratings
- Handles cached image loading

## Key Implementation Details

### Search Debounce
```dart
// 500ms debounce prevents excessive API calls while user is typing
_debounceTimer = Timer(const Duration(milliseconds: 500), () async {
  await fetchProducts(reset: true);
});
```

### Infinite Scrolling
```dart
// Detects when user scrolls to bottom and loads more products
void _onScroll() {
  if (_scrollController.position.pixels == 
      _scrollController.position.maxScrollExtent) {
    context.read<ProductProvider>().loadMoreProducts();
  }
}
```

### Local Caching
```dart
// Products are cached using SharedPreferences for offline access
await prefs.setString(key, jsonEncode(products.map((p) => p.toJson()).toList()));
```

### Wishlist Persistence
```dart
// Wishlist stored as comma-separated IDs
final wishlistStrings = prefs.getStringList('wishlist_ids') ?? [];
_wishlistIds = wishlistStrings.map((id) => int.parse(id)).toList();
```

## Error Handling

The app handles various error scenarios:
- **Network Errors**: Falls back to cached data
- **API Failures**: Shows user-friendly error messages with retry option
- **Missing Images**: Shows placeholder icon instead of broken image
- **Out of Stock**: Disables buy button and shows warning

## Performance Optimizations

1. **Image Caching** - Uses cached_network_image for efficient loading
2. **Debounced Search** - Prevents excessive API calls
3. **Grid Optimization** - Uses GridView with fixed cross-axis count
4. **Lazy Loading** - Infinite scroll loads products on demand
5. **State Management** - Provider pattern minimizes rebuilds

## Troubleshooting

### Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### Dependencies Issues
```bash
# Update pubspec and get latest compatible versions
flutter pub upgrade
```

### Hot Reload Not Working
```bash
# Restart the app completely
# Hot reload doesn't always work with Provider changes
```

### API Not Responding
- Check internet connection
- Verify API endpoint is accessible
- Check app logs for detailed error messages

## API Response Example

```json
{
  "products": [
    {
      "id": 1,
      "title": "iPhone 9",
      "description": "An apple mobile...",
      "price": 549,
      "discountPercentage": 12.96,
      "rating": 4.69,
      "stock": 94,
      "category": "smartphones",
      "thumbnail": "https://...",
      "images": ["https://..."]
    }
  ],
  "total": 100,
  "skip": 0,
  "limit": 12
}
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)
- [DummyJSON API](https://dummyjson.com)
- [Dart Documentation](https://dart.dev/guides)

---
