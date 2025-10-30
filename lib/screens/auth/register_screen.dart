import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../data/cities_data.dart';
import '../../models/profession_model.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  final bool isEditing;
  final UserModel? userToEdit;

  const RegisterScreen({
    super.key,
    this.isEditing = false,
    this.userToEdit,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _userType;
  String? _selectedProfessionKey;
  File? _image;
  String? _networkImageUrl;

  // --- بداية التعديل 1: إضافة متغيرات الحالة الجديدة ---
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedPrimaryCity;
  // --- نهاية التعديل 1 ---

  final ImagePicker _picker = ImagePicker();
  final ProfessionsData _professionsData = ProfessionsData();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.userToEdit != null) {
      final user = widget.userToEdit!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _userType = user.userType;
      _selectedProfessionKey = user.profession;
      _selectedCountry = user.country.isNotEmpty ? user.country : null;
      _selectedPrimaryCity = user.primaryWorkCity.isNotEmpty ? user.primaryWorkCity : null;
      _networkImageUrl = user.profileImageUrl;
      // ملاحظة: لا يمكننا إعادة بناء الجهة والإقليم بسهولة من المدينة فقط، لذا سنتركها فارغة عند التعديل
      // وسيتعين على المستخدم إعادة تحديدها إذا أراد تغيير المدينة.
    } else {
      _userType = AppStrings.client;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _networkImageUrl = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userType == AppStrings.craftsman && (_selectedProfessionKey == null || _selectedPrimaryCity == null || _selectedCountry == null)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إكمال جميع الحقول المطلوبة للحرفي (بما في ذلك المدينة)')),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      if (widget.isEditing) {
        Map<String, dynamic> updates = {
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'profession': _selectedProfessionKey,
          'primaryWorkCity': _selectedPrimaryCity,
          'country': _selectedCountry,
        };
        await authProvider.updateUserProfileWithImage(
          userId: widget.userToEdit!.id,
          data: updates,
          newImage: _image,
        );
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
          );
        }
      } else {
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          userType: _userType!,
          profession: _selectedProfessionKey,
          primaryWorkCity: _selectedPrimaryCity,
          country: _selectedCountry,
          profileImage: _image,
        );
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم التسجيل بنجاح')),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'تعديل الملف الشخصي' : 'إنشاء حساب'),
      ),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'الاسم',
                      validator: (value) => value!.isEmpty ? AppStrings.nameRequired : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      labelText: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !widget.isEditing,
                      validator: (value) => value!.isEmpty ? AppStrings.emailRequired : null,
                    ),
                    const SizedBox(height: 16),
                    if (!widget.isEditing)
                      CustomTextField(
                        controller: _passwordController,
                        labelText: AppStrings.password,
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? AppStrings.passwordRequired : null,
                      ),
                    if (!widget.isEditing) const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: AppStrings.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? AppStrings.phoneRequired : null,
                    ),
                    const SizedBox(height: 20),
                    if (widget.isEditing)
                      _buildStaticInfoBox('نوع الحساب', _userType ?? '')
                    else
                      _buildUserTypeSelector(),
                    const SizedBox(height: 16),
                    if (_userType == AppStrings.craftsman) ...[
                      _buildProfessionDropdown(),
                      const SizedBox(height: 20),
                      Text("منطقة العمل", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                      const Divider(),
                      _buildCountryDropdown(),
                      const SizedBox(height: 16),
                      _buildRegionDropdown(), // القائمة الجديدة للجهات
                      const SizedBox(height: 16),
                      _buildProvinceDropdown(), // القائمة الجديدة للأقاليم
                      const SizedBox(height: 16),
                      _buildCityDropdown(), // القائمة النهائية للمدن
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      text: widget.isEditing ? 'حفظ التغييرات' : 'إنشاء حساب',
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- بداية التعديل 2: إضافة وتعديل دوال بناء القوائم المنسدلة ---

  // دالة بناء قائمة منسدلة عامة لتقليل التكرار
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    bool isEnabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
        color: isEnabled ? Colors.transparent : Colors.grey[200],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
          disabledHint: Text(hint, style: TextStyle(color: Colors.grey[500])),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return _buildDropdown(
      hint: 'اختر الدولة',
      value: _selectedCountry,
      items: CitiesData.getCountries(),
      onChanged: (newValue) {
        setState(() {
          _selectedCountry = newValue;
          _selectedRegion = null;
          _selectedProvince = null;
          _selectedPrimaryCity = null;
        });
      },
    );
  }

  Widget _buildRegionDropdown() {
    final regions = _selectedCountry != null ? CitiesData.getRegions(_selectedCountry!) : <String>[];
    return _buildDropdown(
      hint: 'اختر الجهة / الولاية',
      value: _selectedRegion,
      items: regions,
      isEnabled: _selectedCountry != null,
      onChanged: (newValue) {
        setState(() {
          _selectedRegion = newValue;
          _selectedProvince = null;
          _selectedPrimaryCity = null;
        });
      },
    );
  }

  Widget _buildProvinceDropdown() {
    final provinces = (_selectedCountry != null && _selectedRegion != null)
        ? CitiesData.getCities(_selectedCountry!, _selectedRegion!)
        : <String>[];
    return _buildDropdown(
      hint: 'اختر الإقليم / العمالة',
      value: _selectedProvince,
      items: provinces,
      isEnabled: _selectedRegion != null,
      onChanged: (newValue) {
        setState(() {
          _selectedProvince = newValue;
          _selectedPrimaryCity = null;
        });
      },
    );
  }

  Widget _buildCityDropdown() {
    final cities = (_selectedCountry != null && _selectedRegion != null && _selectedProvince != null)
        ? CitiesData.getDistricts(_selectedCountry!, _selectedRegion!, _selectedProvince!)
        : <String>[];
    return _buildDropdown(
      hint: 'اختر المدينة',
      value: _selectedPrimaryCity,
      items: cities,
      isEnabled: _selectedProvince != null,
      onChanged: (newValue) {
        setState(() {
          _selectedPrimaryCity = newValue;
        });
      },
    );
  }
  
  // --- نهاية التعديل 2 ---

  Widget _buildProfessionDropdown() {
    return _buildDropdown(
      hint: AppStrings.selectProfession,
      value: _selectedProfessionKey,
      items: _professionsData.getAllProfessions().map((p) => p.getNameByDialect('AR')).toList(),
      onChanged: (newValue) {
        // البحث عن المفتاح المقابل للاسم المختار
        final selectedProfession = _professionsData.findProfessionByName(newValue ?? '', 'AR');
        setState(() {
          _selectedProfessionKey = selectedProfession?.conceptKey;
        });
      },
    );
  }

  Widget _buildStaticInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _image != null
                ? FileImage(_image!)
                : (_networkImageUrl != null && _networkImageUrl!.isNotEmpty
                    ? NetworkImage(_networkImageUrl!)
                    : null) as ImageProvider?,
            child: (_image == null && (_networkImageUrl == null || _networkImageUrl!.isEmpty))
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _userType,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: AppStrings.client, child: Text(AppStrings.client)),
            DropdownMenuItem(value: AppStrings.craftsman, child: Text(AppStrings.craftsman)),
            DropdownMenuItem(value: AppStrings.supplier, child: Text(AppStrings.supplier)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _userType = value;
              });
            }
          },
        ),
      ),
    );
  }
}
