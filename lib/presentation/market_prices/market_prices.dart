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
      "currentPrice": 2915.0,
      "unit": "quintal",
      "priceChange": 35.0,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 15)),
      "category": "Grains",
      "image": "https://images.pexels.com/photos/4110256/pexels-photo-4110256.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 2915.0},
        {"date": "2025-09-14", "price": 2880.0},
        {"date": "2025-09-13", "price": 2850.0},
        {"date": "2025-09-12", "price": 2920.0},
        {"date": "2025-09-11", "price": 2890.0},
        {"date": "2025-09-10", "price": 2860.0},
        {"date": "2025-09-09", "price": 2940.0},
      ],
    },
    {
      "id": 2,
      "name": "Rice",
      "variety": "Basmati 1121",
      "currentPrice": 4800.0,
      "unit": "quintal",
      "priceChange": -120.0,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 30)),
      "category": "Grains",
      "image": "https://images.pexels.com/photos/1393382/pexels-photo-1393382.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 4800.0},
        {"date": "2025-09-14", "price": 4920.0},
        {"date": "2025-09-13", "price": 4850.0},
        {"date": "2025-09-12", "price": 4780.0},
        {"date": "2025-09-11", "price": 4900.0},
        {"date": "2025-09-10", "price": 4750.0},
        {"date": "2025-09-09", "price": 4820.0},
      ],
    },
    {
      "id": 3,
      "name": "Tomato",
      "variety": "Hybrid Round",
      "currentPrice": 3333.0,
      "unit": "quintal",
      "priceChange": 253.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 1)),
      "category": "Vegetables",
      "image": "https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Azadpur Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 3333.0},
        {"date": "2025-09-14", "price": 3080.0},
        {"date": "2025-09-13", "price": 2900.0},
        {"date": "2025-09-12", "price": 3200.0},
        {"date": "2025-09-11", "price": 3500.0},
        {"date": "2025-09-10", "price": 3150.0},
        {"date": "2025-09-09", "price": 2800.0},
      ],
    },
    {
      "id": 4,
      "name": "Onion",
      "variety": "Red Nashik",
      "currentPrice": 2000.0,
      "unit": "quintal",
      "priceChange": -180.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 2)),
      "category": "Vegetables",
      "image": "https://images.pexels.com/photos/1323712/pexels-photo-1323712.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Azadpur Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 2000.0},
        {"date": "2025-09-14", "price": 2180.0},
        {"date": "2025-09-13", "price": 2250.0},
        {"date": "2025-09-12", "price": 2100.0},
        {"date": "2025-09-11", "price": 2300.0},
        {"date": "2025-09-10", "price": 2050.0},
        {"date": "2025-09-09", "price": 2400.0},
      ],
    },
    {
      "id": 5,
      "name": "Apple",
      "variety": "Shimla Red Delicious",
      "currentPrice": 14000.0,
      "unit": "quintal",
      "priceChange": 500.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 3)),
      "category": "Fruits",
      "image": "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Azadpur Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 14000.0},
        {"date": "2025-09-14", "price": 13500.0},
        {"date": "2025-09-13", "price": 13200.0},
        {"date": "2025-09-12", "price": 13800.0},
        {"date": "2025-09-11", "price": 13600.0},
        {"date": "2025-09-10", "price": 13000.0},
        {"date": "2025-09-09", "price": 13400.0},
      ],
    },
    {
      "id": 6,
      "name": "Turmeric",
      "variety": "Erode Finger",
      "currentPrice": 16500.0,
      "unit": "quintal",
      "priceChange": 850.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 4)),
      "category": "Spices",
      "image": "https://images.pexels.com/photos/4198015/pexels-photo-4198015.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 16500.0},
        {"date": "2025-09-14", "price": 15650.0},
        {"date": "2025-09-13", "price": 15800.0},
        {"date": "2025-09-12", "price": 16200.0},
        {"date": "2025-09-11", "price": 15900.0},
        {"date": "2025-09-10", "price": 15400.0},
        {"date": "2025-09-09", "price": 15600.0},
      ],
    },
    {
      "id": 7,
      "name": "Potato",
      "variety": "Jyoti",
      "currentPrice": 1800.0,
      "unit": "quintal",
      "priceChange": 75.0,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 45)),
      "category": "Vegetables",
      "image": "https://images.pexels.com/photos/144248/potatoes-vegetables-erdfrucht-bio-144248.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Azadpur Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 1800.0},
        {"date": "2025-09-14", "price": 1725.0},
        {"date": "2025-09-13", "price": 1750.0},
        {"date": "2025-09-12", "price": 1820.0},
        {"date": "2025-09-11", "price": 1700.0},
        {"date": "2025-09-10", "price": 1780.0},
        {"date": "2025-09-09", "price": 1650.0},
      ],
    },
    {
      "id": 8,
      "name": "Mustard Seed",
      "variety": "Black (Rai)",
      "currentPrice": 6800.0,
      "unit": "quintal",
      "priceChange": 200.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 5)),
      "category": "Oil Seeds",
      "image": "https://images.pexels.com/photos/4198719/pexels-photo-4198719.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 6800.0},
        {"date": "2025-09-14", "price": 6600.0},
        {"date": "2025-09-13", "price": 6750.0},
        {"date": "2025-09-12", "price": 6550.0},
        {"date": "2025-09-11", "price": 6700.0},
        {"date": "2025-09-10", "price": 6450.0},
        {"date": "2025-09-09", "price": 6650.0},
      ],
    },
    {
      "id": 9,
      "name": "Chana Dal",
      "variety": "Bold",
      "currentPrice": 9200.0,
      "unit": "quintal",
      "priceChange": -150.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 1)),
      "category": "Pulses",
      "image": "https://images.pexels.com/photos/4518656/pexels-photo-4518656.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 9200.0},
        {"date": "2025-09-14", "price": 9350.0},
        {"date": "2025-09-13", "price": 9180.0},
        {"date": "2025-09-12", "price": 9400.0},
        {"date": "2025-09-11", "price": 9250.0},
        {"date": "2025-09-10", "price": 9100.0},
        {"date": "2025-09-09", "price": 9300.0},
      ],
    },
    {
      "id": 10,
      "name": "Banana",
      "variety": "Robusta",
      "currentPrice": 2500.0,
      "unit": "quintal",
      "priceChange": 125.0,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 20)),
      "category": "Fruits",
      "image": "https://images.pexels.com/photos/61127/pexels-photo-61127.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Azadpur Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 2500.0},
        {"date": "2025-09-14", "price": 2375.0},
        {"date": "2025-09-13", "price": 2400.0},
        {"date": "2025-09-12", "price": 2450.0},
        {"date": "2025-09-11", "price": 2350.0},
        {"date": "2025-09-10", "price": 2475.0},
        {"date": "2025-09-09", "price": 2300.0},
      ],
    },
    {
      "id": 11,
      "name": "Cauliflower",
      "variety": "Snowball-16",
      "currentPrice": 1200.0,
      "unit": "quintal",
      "priceChange": -80.0,
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 40)),
      "category": "Vegetables",
      "image": "https://images.pexels.com/photos/1458694/pexels-photo-1458694.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Azadpur Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 1200.0},
        {"date": "2025-09-14", "price": 1280.0},
        {"date": "2025-09-13", "price": 1350.0},
        {"date": "2025-09-12", "price": 1150.0},
        {"date": "2025-09-11", "price": 1300.0},
        {"date": "2025-09-10", "price": 1250.0},
        {"date": "2025-09-09", "price": 1400.0},
      ],
    },
    {
      "id": 12,
      "name": "Coriander",
      "variety": "Eagle (Dhaniya)",
      "currentPrice": 18500.0,
      "unit": "quintal",
      "priceChange": 1200.0,
      "lastUpdated": DateTime.now().subtract(Duration(hours: 6)),
      "category": "Spices",
      "image": "https://images.pexels.com/photos/4198523/pexels-photo-4198523.jpeg?auto=compress&cs=tinysrgb&w=400",
      "market": "Delhi Mandi",
      "priceHistory": [
        {"date": "2025-09-15", "price": 18500.0},
        {"date": "2025-09-14", "price": 17300.0},
        {"date": "2025-09-13", "price": 17800.0},
        {"date": "2025-09-12", "price": 17500.0},
        {"date": "2025-09-11", "price": 18200.0},
        {"date": "2025-09-10", "price": 16900.0},
        {"date": "2025-09-09", "price": 17600.0},
      ],
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
                      values: const RangeValues(0, 20000),
                      max: 20000,
                      divisions: 200,
                      labels: const RangeLabels('₹0', '₹20,000'),
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
                                      '₹${((cropData['currentPrice'] as double? ?? 0.0) * 1.08).toStringAsFixed(2)}',
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
                                      '₹${((cropData['currentPrice'] as double? ?? 0.0) * 0.92).toStringAsFixed(2)}',
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