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
import '../../models/profession_model.dart'; // <-- تم تغيير مسار الاستيراد هنا
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
  String? _selectedCountry;
  String? _selectedPrimaryCity;
  File? _image;
  String? _networkImageUrl;

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
      _selectedCountry = user.country;
      _selectedPrimaryCity = user.primaryWorkCity;
      _networkImageUrl = user.profileImageUrl;
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
          const SnackBar(content: Text('الرجاء إكمال جميع الحقول المطلوبة للحرفي (بما في ذلك المدينة الأساسية)')),
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
                      _buildCountryDropdown(),
                      const SizedBox(height: 16),
                      _buildProfessionDropdown(),
                      const SizedBox(height: 16),
                      _buildPrimaryCityDropdown(),
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
          value: _selectedProfessionKey,
          isExpanded: true,
          hint: const Text(AppStrings.selectProfession),
          items: _professionsData.getAllProfessions().map((profession) {
            return DropdownMenuItem<String>(
              value: profession.conceptKey,
              child: Text(profession.getNameByDialect('AR'), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedProfessionKey = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPrimaryCityDropdown() {
    final regions = _selectedCountry != null ? CitiesData.getRegions(_selectedCountry!) : <String>[];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
        color: _selectedCountry == null ? Colors.grey[200] : Colors.transparent,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPrimaryCity,
          isExpanded: true,
          hint: const Text('اختر مدينة العمل الأساسية'),
          items: regions.expand((region) {
            return CitiesData.getCities(_selectedCountry!, region);
          }).toSet().toList().map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: _selectedCountry == null ? null : (newValue) {
            setState(() {
              _selectedPrimaryCity = newValue;
            });
          },
        ),
      ),
    );
  }
}
