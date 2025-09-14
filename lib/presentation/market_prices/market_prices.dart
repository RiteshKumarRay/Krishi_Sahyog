import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_tabs_widget.dart';
import './widgets/location_selector_widget.dart';
import './widgets/price_card_widget.dart';
import './widgets/price_trend_chart_widget.dart';
import './widgets/search_filter_widget.dart';

class MarketPrices extends StatefulWidget {
  const MarketPrices({Key? key}) : super(key: key);

  @override
  State<MarketPrices> createState() => _MarketPricesState();
}

class _MarketPricesState extends State<MarketPrices>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  String _selectedCategory = 'All';
  String _currentLocation = 'Delhi Mandi, Delhi';
  bool _hasActiveFilters = false;
  bool _isLoading = false;
  List<String> _favoriteCrops = [];
  int _selectedDetailIndex = -1;

  final List<String> _categories = [
    'All',
    'Grains',
    'Vegetables',
    'Fruits',
    'Spices',
    'Pulses',
    'Oil Seeds'
  ];

  final List<Map<String, dynamic>> _mockPriceData = [
    {
      "id": 1,
      "name": "Wheat",
      "variety": "HD-2967 (Common)",
      "currentPrice": 2150.0,
      "unit": "quintal",
      "priceChange": 2.5,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 15)),
      "category": "Grains",
      "image":
          "https://images.pexels.com/photos/4110256/pexels-photo-4110256.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2024-12-13", "price": 2100.0},
        {"date": "2024-12-12", "price": 2120.0},
        {"date": "2024-12-11", "price": 2080.0},
        {"date": "2024-12-10", "price": 2090.0},
        {"date": "2024-12-09", "price": 2110.0},
        {"date": "2024-12-08", "price": 2130.0},
        {"date": "2024-12-07", "price": 2150.0},
      ]
    },
    {
      "id": 2,
      "name": "Rice",
      "variety": "Basmati 1121",
      "currentPrice": 4500.0,
      "unit": "quintal",
      "priceChange": -1.2,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 30)),
      "category": "Grains",
      "image":
          "https://images.pexels.com/photos/1393382/pexels-photo-1393382.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2024-12-13", "price": 4500.0},
        {"date": "2024-12-12", "price": 4520.0},
        {"date": "2024-12-11", "price": 4480.0},
        {"date": "2024-12-10", "price": 4510.0},
        {"date": "2024-12-09", "price": 4490.0},
        {"date": "2024-12-08", "price": 4530.0},
        {"date": "2024-12-07", "price": 4560.0},
      ]
    },
    {
      "id": 3,
      "name": "Tomato",
      "variety": "Hybrid Round",
      "currentPrice": 35.0,
      "unit": "kg",
      "priceChange": 15.8,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 1)),
      "category": "Vegetables",
      "image":
          "https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2024-12-13", "price": 35.0},
        {"date": "2024-12-12", "price": 32.0},
        {"date": "2024-12-11", "price": 28.0},
        {"date": "2024-12-10", "price": 30.0},
        {"date": "2024-12-09", "price": 25.0},
        {"date": "2024-12-08", "price": 22.0},
        {"date": "2024-12-07", "price": 20.0},
      ]
    },
    {
      "id": 4,
      "name": "Onion",
      "variety": "Red Nashik",
      "currentPrice": 28.0,
      "unit": "kg",
      "priceChange": -5.4,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 2)),
      "category": "Vegetables",
      "image":
          "https://images.pexels.com/photos/1323712/pexels-photo-1323712.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2024-12-13", "price": 28.0},
        {"date": "2024-12-12", "price": 30.0},
        {"date": "2024-12-11", "price": 32.0},
        {"date": "2024-12-10", "price": 29.0},
        {"date": "2024-12-09", "price": 31.0},
        {"date": "2024-12-08", "price": 33.0},
        {"date": "2024-12-07", "price": 35.0},
      ]
    },
    {
      "id": 5,
      "name": "Apple",
      "variety": "Shimla Red Delicious",
      "currentPrice": 120.0,
      "unit": "kg",
      "priceChange": 3.2,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 3)),
      "category": "Fruits",
      "image":
          "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2024-12-13", "price": 120.0},
        {"date": "2024-12-12", "price": 118.0},
        {"date": "2024-12-11", "price": 115.0},
        {"date": "2024-12-10", "price": 117.0},
        {"date": "2024-12-09", "price": 114.0},
        {"date": "2024-12-08", "price": 112.0},
        {"date": "2024-12-07", "price": 110.0},
      ]
    },
    {
      "id": 6,
      "name": "Turmeric",
      "variety": "Erode Finger",
      "currentPrice": 8500.0,
      "unit": "quintal",
      "priceChange": 7.8,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 4)),
      "category": "Spices",
      "image":
          "https://images.pexels.com/photos/4198015/pexels-photo-4198015.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2024-12-13", "price": 8500.0},
        {"date": "2024-12-12", "price": 8200.0},
        {"date": "2024-12-11", "price": 8000.0},
        {"date": "2024-12-10", "price": 8100.0},
        {"date": "2024-12-09", "price": 7900.0},
        {"date": "2024-12-08", "price": 7800.0},
        {"date": "2024-12-07", "price": 7600.0},
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    List<Map<String, dynamic>> filtered = _mockPriceData;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((item) => (item['category'] as String?) == _selectedCategory)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((item) =>
              (item['name'] as String?)?.toLowerCase().contains(query) ==
                  true ||
              (item['variety'] as String?)?.toLowerCase().contains(query) ==
                  true)
          .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleFavorite(int cropId) {
    setState(() {
      final cropIdStr = cropId.toString();
      if (_favoriteCrops.contains(cropIdStr)) {
        _favoriteCrops.remove(cropIdStr);
      } else {
        _favoriteCrops.add(cropIdStr);
      }
    });
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Select Market Location',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  'Delhi Mandi, Delhi',
                  'Azadpur Mandi, Delhi',
                  'Ghazipur Mandi, Delhi',
                  'Anaj Mandi, Punjab',
                  'Kisan Mandi, Haryana',
                  'Agricultural Market, UP',
                ]
                    .map((location) => ListTile(
                          leading: CustomIconWidget(
                            iconName: 'location_on',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          title: Text(
                            location,
                            style: AppTheme.lightTheme.textTheme.bodyLarge,
                          ),
                          trailing: _currentLocation == location
                              ? CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _currentLocation = location;
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Options',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _hasActiveFilters = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RangeSlider(
                      values: const RangeValues(0, 10000),
                      max: 10000,
                      divisions: 100,
                      labels: const RangeLabels('₹0', '₹10,000'),
                      onChanged: (values) {},
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Market Distance',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Wrap(
                      spacing: 2.w,
                      children: [
                        'Within 10km',
                        'Within 25km',
                        'Within 50km',
                        'Any Distance'
                      ]
                          .map((distance) => FilterChip(
                                label: Text(distance),
                                selected: false,
                                onSelected: (selected) {
                                  setState(() {
                                    _hasActiveFilters = true;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Sort By',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Column(
                      children: [
                        'Price: Low to High',
                        'Price: High to Low',
                        'Recently Updated',
                        'Alphabetical'
                      ]
                          .map((option) => RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: null,
                                onChanged: (value) {
                                  setState(() {
                                    _hasActiveFilters = true;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasActiveFilters = true;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceDetail(int index) {
    final cropData = _filteredData[index];
    final priceHistory =
        (cropData['priceHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PriceCardWidget(
                      cropData: cropData,
                      isFavorite:
                          _favoriteCrops.contains(cropData['id'].toString()),
                      onFavoriteToggle: () =>
                          _toggleFavorite(cropData['id'] as int),
                    ),
                    PriceTrendChartWidget(
                      priceHistory: priceHistory,
                      cropName: cropData['name'] as String? ?? '',
                    ),
                    Container(
                      margin: EdgeInsets.all(4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Analysis',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Weekly High',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '₹${(cropData['currentPrice'] as double? ?? 0.0 * 1.1).toStringAsFixed(2)}',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme.colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Weekly Low',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '₹${(cropData['currentPrice'] as double? ?? 0.0 * 0.9).toStringAsFixed(2)}',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceSearch() {
    // Voice search implementation would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice search activated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredData;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Market Prices',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share functionality activated')),
              );
            },
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              // Notifications
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Price alerts configured')),
              );
            },
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: Column(
          children: [
            // Location Selector
            LocationSelectorWidget(
              currentLocation: _currentLocation,
              onLocationTap: _showLocationSelector,
              onGpsRefresh: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location refreshed')),
                );
              },
            ),

            // Search and Filter
            SearchFilterWidget(
              searchController: _searchController,
              onVoiceSearch: _handleVoiceSearch,
              onFilter: _showFilterBottomSheet,
              hasActiveFilters: _hasActiveFilters,
            ),

            // Category Tabs
            CategoryTabsWidget(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            SizedBox(height: 1.h),

            // Price List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    )
                  : filteredData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'search_off',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No crops found',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Try adjusting your search or filters',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 2.h),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final cropData = filteredData[index];
                            return PriceCardWidget(
                              cropData: cropData,
                              isFavorite: _favoriteCrops
                                  .contains(cropData['id'].toString()),
                              onTap: () => _showPriceDetail(index),
                              onFavoriteToggle: () =>
                                  _toggleFavorite(cropData['id'] as int),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quick price comparison
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Price comparison mode activated')),
          );
        },
        icon: CustomIconWidget(
          iconName: 'compare_arrows',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'Compare',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}
