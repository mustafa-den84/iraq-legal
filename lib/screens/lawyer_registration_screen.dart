import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/supabase_service.dart';
import '../constants/app_colors.dart';
import 'lawyer_login_screen.dart';

class LawyerRegistrationScreen extends StatefulWidget {
  const LawyerRegistrationScreen({super.key});

  @override
  State<LawyerRegistrationScreen> createState() => _LawyerRegistrationScreenState();
}

class _LawyerRegistrationScreenState extends State<LawyerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _barAssociationIdController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _gender = '';
  DateTime? _birthDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _officeNameController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _nationalIdController.dispose();
    _barAssociationIdController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simple password hash (in production, use proper hashing)
      final passwordHash = _passwordController.text.hashCode.toString();

      final lawyerData = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
        'whatsapp_number': _whatsappController.text.isEmpty ? null : _whatsappController.text,
        'password_hash': passwordHash,
        'gender': _gender.isEmpty ? null : _gender,
        'birth_date': _birthDate?.toIso8601String(),
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'area': _areaController.text.isEmpty ? null : _areaController.text,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
        'office_name': _officeNameController.text.isEmpty ? null : _officeNameController.text,
        'specialization': _specializationController.text.isEmpty ? null : _specializationController.text,
        'experience_years': int.tryParse(_experienceController.text) ?? 0,
        'national_id': _nationalIdController.text.isEmpty ? null : _nationalIdController.text,
        'bar_association_id': _barAssociationIdController.text.isEmpty ? null : _barAssociationIdController.text,
        'license_number': _licenseNumberController.text.isEmpty ? null : _licenseNumberController.text,
        'status': 'pending',
        'is_verified': false,
        'is_visible': false,
        'rating': 0.0,
        'reviews_count': 0,
      };

      await SupabaseService.registerLawyer(lawyerData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please wait for approval.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LawyerLoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Lawyer Registration', style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password *',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender.isEmpty ? null : _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.text),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : 'Select date',
                    style: const TextStyle(color: AppColors.text),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _officeNameController,
                decoration: const InputDecoration(
                  labelText: 'Office Name',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience Years',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'National ID',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barAssociationIdController,
                decoration: const InputDecoration(
                  labelText: 'Bar Association ID',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'License Number',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LawyerLoginScreen()),
                  );
                },
                child: const Text('Already have an account? Login', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
