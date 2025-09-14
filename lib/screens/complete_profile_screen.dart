import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../services/firebase_auth_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _farmSizeController = TextEditingController();

  String _selectedUserType = 'farmer';
  String _selectedFarmingType = 'mixed';
  String _selectedSoilType = 'loamy';
  String _selectedIrrigation = 'canal';
  List<String> _selectedCrops = [];
  bool _isLoading = false;

  final List<String> _cropOptions = [
    'गेहूं (Wheat)', 'चावल (Rice)', 'मक्का (Maize)', 'बाजरा (Millet)',
    'ज्वार (Sorghum)', 'आलू (Potato)', 'प्याज (Onion)', 'टमाटर (Tomato)',
    'गन्ना (Sugarcane)', 'कपास (Cotton)', 'सोयाबीन (Soybean)', 'सरसों (Mustard)',
  ];

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuthService.currentUser;
      if (user != null) {
        final success = await FirebaseAuthService.updateUserProfile(
          uid: user.uid,
          userType: _selectedUserType,
          location: _locationController.text,
          cropInterests: _selectedCrops,
          experience: _experienceController.text,
          farmSize: _farmSizeController.text,
          farmingType: _selectedFarmingType,
          soilType: _selectedSoilType,
          irrigationType: _selectedIrrigation,
          primaryCrops: _selectedCrops,
        );

        if (success) {
          // Navigate to appropriate dashboard
          if (_selectedUserType == 'advisor') {
            Navigator.pushReplacementNamed(context, '/advisor-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/farmer-dashboard');
          }
        } else {
          _showError('प्रोफ़ाइल अपडेट करने में त्रुटि');
        }
      }
    } catch (e) {
      _showError('प्रोफ़ाइल पूरी करने में त्रुटि');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('प्रोफ़ाइल पूरी करें'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'आपकी जानकारी',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 3.h),

              // User Type Selection
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                decoration: InputDecoration(
                  labelText: 'आप कौन हैं?',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'farmer', child: Text('किसान')),
                  DropdownMenuItem(value: 'advisor', child: Text('कृषि सलाहकार')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUserType = value!;
                  });
                },
              ),
              SizedBox(height: 3.h),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'स्थान (जिला, राज्य)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'कृपया स्थान दर्ज करें';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Show farming specific fields only for farmers
              if (_selectedUserType == 'farmer') ...[
                // Farm Size
                TextFormField(
                  controller: _farmSizeController,
                  decoration: InputDecoration(
                    labelText: 'खेत का आकार (एकड़ में)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 3.h),

                // Crop Selection
                Text(
                  'आपकी मुख्य फसलें:',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                Wrap(
                  children: _cropOptions.map((crop) {
                    return CheckboxListTile(
                      title: Text(crop, style: TextStyle(fontSize: 12.sp)),
                      value: _selectedCrops.contains(crop),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedCrops.add(crop);
                          } else {
                            _selectedCrops.remove(crop);
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.h),

                // Farming Type
                DropdownButtonFormField<String>(
                  value: _selectedFarmingType,
                  decoration: InputDecoration(
                    labelText: 'खेती का प्रकार',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'organic', child: Text('जैविक')),
                    DropdownMenuItem(value: 'conventional', child: Text('परंपरागत')),
                    DropdownMenuItem(value: 'mixed', child: Text('मिश्रित')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFarmingType = value!;
                    });
                  },
                ),
                SizedBox(height: 3.h),

                // Soil Type
                DropdownButtonFormField<String>(
                  value: _selectedSoilType,
                  decoration: InputDecoration(
                    labelText: 'मिट्टी का प्रकार',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'clay', child: Text('चिकनी मिट्टी')),
                    DropdownMenuItem(value: 'sandy', child: Text('रेतीली मिट्टी')),
                    DropdownMenuItem(value: 'loamy', child: Text('दोमट मिट्टी')),
                    DropdownMenuItem(value: 'black', child: Text('काली मिट्टी')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSoilType = value!;
                    });
                  },
                ),
                SizedBox(height: 3.h),
              ],

              // Experience
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(
                  labelText: _selectedUserType == 'farmer' ? 'खेती का अनुभव (वर्षों में)' : 'कार्य अनुभव (वर्षों में)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 5.h),

              // Complete Profile Button
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'प्रोफ़ाइल पूरी करें',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
