# Features Checklist & Testing Guide

Use this checklist to verify all features are working correctly in the app.

## 🚀 Pre-Launch Checklist

### Setup
- [ ] Ran `flutter pub get` successfully
- [ ] No build errors when running `flutter run`
- [ ] App launches without crashes
- [ ] App shows product grid on home screen

## ✅ Core Feature Testing

### 1. Product List Screen
**Location**: Home Screen (Main Screen)
- [ ] Products load in grid view (2 columns)
- [ ] Product images display
- [ ] Product titles are visible
- [ ] Prices are shown
- [ ] Categories are displayed
- [ ] Rating stars are shown
- [ ] Discount badges appear on products with discounts
- [ ] Loading spinner appears while loading initially
- [ ] Products are properly spaced and formatted

### 2. Search Functionality
**Location**: Search bar at top of home screen
**How to Test**:
1. Tap the search box
2. Type a product name slowly (e.g., "phone")
3. Wait 500ms after typing stops
4. Verify results update

- [ ] Search bar is visible at top
- [ ] Can type in search field
- [ ] Results update after 500ms debounce (not immediately)
- [ ] Correct products appear for search
- [ ] No results show error/empty message
- [ ] Can clear search and see all products again
- [ ] Multiple search terms work (e.g., "apple phone")

### 3. Filter Functionality
**Location**: Filter icon (⚙️) in top-right corner
**How to Test**:
1. Tap filter icon
2. Select a category
3. Verify products update
4. Adjust price range slider
5. Verify products update again

- [ ] Filter icon is visible and clickable
- [ ] Filter section expands/collapses
- [ ] Category options display
- [ ] "All" category option works
- [ ] Selecting category filters products
- [ ] Price slider is draggable
- [ ] Price values display correctly
- [ ] Filtering by price works
- [ ] Multiple filters work together
- [ ] Reset filters button clears all filters
- [ ] Filter section collapses after reset

### 4. Pagination (Infinite Scrolling)
**Location**: Product grid on home screen
**How to Test**:
1. Scroll down to bottom of product list
2. Verify more products load automatically
3. Repeat scrolling down

- [ ] Can scroll through product list
- [ ] Loading indicator appears at bottom when loading more
- [ ] More products load automatically at bottom
- [ ] New products are appended (not replacing)
- [ ] Scrolling smooth without freezes
- [ ] Products don't duplicate
- [ ] Eventually shows message when all products loaded

### 5. Product Detail Screen
**Location**: Tap any product card
**How to Test**:
1. Tap any product card on home screen
2. Verify detail screen appears

- [ ] Product image displays large
- [ ] Product title is shown
- [ ] Full description is visible
- [ ] Price is displayed prominently
- [ ] Category badge shows
- [ ] Rating is displayed with star icon
- [ ] Discount percentage shown (if applicable)
- [ ] Stock status is displayed
- [ ] Stock count shown for in-stock items
- [ ] Out of stock warning for unavailable products
- [ ] "Buy Now" button visible and functional (demo)

### 6. Product Detail - Image Carousel
**Location**: Detail screen images
**How to Test**:
1. On detail screen, look at image indicators
2. Tap different indicators to switch images

- [ ] Multiple images displayed if available
- [ ] Image indicators/dots visible at bottom
- [ ] Can switch between images by tapping dots
- [ ] Current image highlighted in indicators
- [ ] Images load without error
- [ ] Placeholder shown while loading

## 🎁 Bonus Feature Testing

### 7. Wishlist Functionality
**Location**: Heart icons on products and in detail screen
**How to Test**:
1. Tap heart icon on any product card
2. Verify heart fills red and snackbar shows
3. Navigate to wishlist screen
4. Verify product appears

- [ ] Heart icon appears on product cards
- [ ] Tapping heart adds to wishlist
- [ ] Heart fills red when in wishlist
- [ ] Snackbar shows "Added to wishlist"
- [ ] Can remove from wishlist
- [ ] Heart empties when removed
- [ ] Snackbar shows "Removed from wishlist"
- [ ] Wishlist button in top-right navigates to wishlist
- [ ] Wishlisted products show in wishlist screen
- [ ] Can remove items from wishlist screen

### 8. Wishlist Screen
**Location**: Heart icon in top-right corner
**How to Test**:
1. Tap wishlist icon in top-right
2. Verify wishlisted products appear
3. Tap a product to view details

- [ ] Wishlist screen opens
- [ ] Wishlisted products display in grid
- [ ] Products show correct information
- [ ] Can tap products to view details
- [ ] Empty state message when no wishlist items
- [ ] Can return to home screen
- [ ] Products can be removed from wishlist screen

### 9. Wishlist Persistence
**How to Test**:
1. Add products to wishlist
2. Close app completely
3. Reopen app
4. Go to wishlist screen

- [ ] Wishlist items persist after closing app
- [ ] Same products in wishlist after restart
- [ ] Heart icons correctly show saved state
- [ ] No data loss

### 10. Offline Support
**How to Test**:
1. Load some products (so they cache)
2. Disable internet connection
3. Try to load products/search

- [ ] App doesn't crash without internet
- [ ] Previously loaded products display
- [ ] Cached products available for viewing
- [ ] Search works on cached products
- [ ] Filtering works on cached data
- [ ] Product details load from cache
- [ ] Error message shows gracefully

### 11. Image Caching
**How to Test**:
1. Load products for first time
2. Go to product detail
3. Close and reopen app
4. Navigate to same product

- [ ] Images load on first visit
- [ ] Images load faster on subsequent visits
- [ ] Placeholder shows while loading
- [ ] Error icon if image fails to load

### 12. Stock & Discount Indicators
**Location**: Product cards and detail screen
- [ ] Discount badge shows percentage
- [ ] Stock status shows for unavailable items
- [ ] "Out of Stock" warning visible
- [ ] Buy button disabled when out of stock
- [ ] Stock count shown for available items

## 🔧 Error Handling Tests

### Network Error Handling
**How to Test**:
1. Disable internet
2. Force app to refresh/reload

- [ ] Error message displays
- [ ] Retry button appears
- [ ] Can retry to load products
- [ ] Falls back to cache if available

### Empty Results
- [ ] Shows "No products found" when search yields nothing
- [ ] Shows empty state in wishlist when empty
- [ ] Appropriate messages for all empty states

## 📊 Performance Tests

### Scrolling Performance
- [ ] Smooth scrolling through product list
- [ ] No janky animations
- [ ] No freezes while loading
- [ ] Pagination doesn't interrupt scrolling

### Search Performance
- [ ] Search doesn't freeze app
- [ ] 500ms debounce prevents excessive updates
- [ ] Typing is responsive

### Memory
- [ ] App doesn't crash with lots of products
- [ ] No significant slowdown with time
- [ ] Images unload properly

## 🎨 UI/UX Tests

### Responsive Layout
- [ ] Works on different screen sizes
- [ ] No overflow errors
- [ ] Text readable everywhere
- [ ] Buttons easily tappable

### Navigation
- [ ] Can navigate between screens smoothly
- [ ] Back button works correctly
- [ ] Navigation flow is logical

### Visual Design
- [ ] Colors are consistent
- [ ] Spacing is appropriate
- [ ] Icons are clear and visible
- [ ] Typography is readable

## 📋 Complete Test Flow

Follow this flow to test entire app:

1. **Launch App**
   - [ ] Opens without errors

2. **Browse Products**
   - [ ] Grid displays correctly
   - [ ] Scroll loads more products

3. **Search Test**
   - [ ] Search for "phone"
   - [ ] Verify results

4. **Filter Test**
   - [ ] Filter by electronics
   - [ ] Adjust price to $100-$500
   - [ ] Verify filtered results

5. **Product Detail Test**
   - [ ] Tap first product
   - [ ] View details
   - [ ] Check image carousel
   - [ ] Check all information

6. **Wishlist Test**
   - [ ] Add to wishlist from detail
   - [ ] Go to wishlist screen
   - [ ] Verify product appears
   - [ ] Remove from wishlist

7. **Pagination Test**
   - [ ] Go back to home
   - [ ] Scroll to bottom
   - [ ] Verify more products load
   - [ ] Repeat scrolling

8. **Persistence Test**
   - [ ] Close app completely
   - [ ] Reopen app
   - [ ] Check wishlist items remain

9. **Offline Test**
   - [ ] Disable internet
   - [ ] Try to search/filter
   - [ ] View cached products
   - [ ] Verify graceful handling

## ✅ Final Verification

After testing all features:

- [ ] All core features working
- [ ] All bonus features working
- [ ] No crashes or errors
- [ ] UI looks good
- [ ] Performance is smooth
- [ ] Error handling works
- [ ] Data persists correctly
- [ ] Ready to submit

## 📝 Notes for Testing

### Testing Tips
1. Test on both phone and tablet if possible
2. Test with slow internet to see loading states
3. Test with different screen orientations
4. Test rapid tapping of buttons
5. Test search with empty/no results

### Common Issues
If something doesn't work:
1. Check Flutter console for errors
2. Verify internet connection
3. Try `flutter clean` and `flutter run`
4. Check that API (dummyjson.com) is accessible
5. Verify SharedPreferences has permissions

### Recording Results
- [ ] Take screenshots of each major feature
- [ ] Note any issues found
- [ ] Record performance observations
- [ ] Test on multiple devices if possible

---

**All Tests Passed?** 🎉 Your app is ready to submit!

---
