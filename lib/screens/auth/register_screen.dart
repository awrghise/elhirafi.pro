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
import '../../data/professions_data.dart';
import '../../models/user_model.dart';
import '../../models/profession_model.dart'; // استيراد Profession model

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
  String? _selectedProfession;
  String? _selectedCountry;
  String? _selectedRegion; // لتخزين المنطقة/الجهة
  String? _selectedPrimaryCity; // لتخزين المدينة/العمالة
  File? _image;
  String? _networkImageUrl;

  final ImagePicker _picker = ImagePicker();
  final ProfessionsData _professionsData = ProfessionsData();
  List<String> _regions = [];
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.userToEdit != null) {
      final user = widget.userToEdit!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _userType = user.userType;
      // --- بداية التعديل 1: استخدام الحقول الصحيحة ---
      _selectedProfession = user.profession;
      _selectedCountry = user.country;
      _selectedPrimaryCity = user.primaryWorkCity;
      // --- نهاية التعديل 1 ---
      _networkImageUrl = user.profileImageUrl;

      // تحميل المناطق والمدن إذا كانت الدولة محددة
      if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
        _regions = CitiesData.getRegions(_selectedCountry!);
        // ملاحظة: لا يمكننا تحديد المنطقة تلقائيًا من المدينة فقط، لذا سنتركها
      }

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
    if (_userType == AppStrings.craftsman && (_selectedProfession == null || _selectedPrimaryCity == null || _selectedCountry == null)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إكمال جميع الحقول المطلوبة للحرفي (الدولة، المهنة، مدينة العمل)')),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      if (widget.isEditing) {
        // --- بداية التعديل 2: استخدام الحقول الصحيحة في التحديث ---
        Map<String, dynamic> updates = {
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'profession': _selectedProfession,
          'primaryWorkCity': _selectedPrimaryCity,
          'country': _selectedCountry,
        };
        // --- نهاية التعديل 2 ---
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
        // --- بداية التعديل 3: استخدام الحقول الصحيحة في التسجيل ---
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          userType: _userType!,
          profession: _selectedProfession,
          primaryWorkCity: _selectedPrimaryCity,
          country: _selectedCountry,
          profileImage: _image,
        );
        // --- نهاية التعديل 3 ---
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم التسجيل بنجاح')),
          );
        }
      }
      if (mounted) {
        // العودة إلى الشاشة السابقة بعد إتمام العملية بنجاح
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
        backgroundColor: AppColors.primaryColor,
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
                      _buildCountryDropdown(),
                      const SizedBox(height: 16),
                      _buildProfessionDropdown(),
                      const SizedBox(height: 16),
                      _buildRegionDropdown(), // --- إضافة قائمة المناطق
                      const SizedBox(height: 16),
                      _buildPrimaryCityDropdown(), // --- تعديل قائمة المدن
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

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          isExpanded: true,
          hint: const Text(AppStrings.selectCountry),
          items: CitiesData.getCountries().map((String country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(country, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCountry = newValue;
              _regions = newValue != null ? CitiesData.getRegions(newValue) : [];
              _selectedRegion = null;
              _cities = [];
              _selectedPrimaryCity = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildProfessionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProfession,
          isExpanded: true,
          hint: const Text(AppStrings.selectProfession),
          items: _professionsData.getAllProfessions().map((Profession profession) {
            return DropdownMenuItem<String>(
              value: profession.conceptKey, // استخدام conceptKey كقيمة فريدة
              child: Text(profession.getNameByDialect('AR'), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedProfession = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
        color: _selectedCountry == null ? Colors.grey[200] : Colors.transparent,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRegion,
          isExpanded: true,
          hint: const Text('اختر الجهة / الولاية'),
          items: _regions.map((String region) {
            return DropdownMenuItem<String>(
              value: region,
              child: Text(region, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: _selectedCountry == null ? null : (newValue) {
            setState(() {
              _selectedRegion = newValue;
              _cities = (newValue != null && _selectedCountry != null)
                  ? CitiesData.getCities(_selectedCountry!, newValue)
                  : [];
              _selectedPrimaryCity = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPrimaryCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
        color: _selectedRegion == null ? Colors.grey[200] : Colors.transparent,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPrimaryCity,
          isExpanded: true,
          hint: const Text('اختر مدينة العمل الأساسية'),
          items: _cities.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: _selectedRegion == null ? null : (newValue) {
            setState(() {
              _selectedPrimaryCity = newValue;
            });
          },
        ),
      ),
    );
  }
}
