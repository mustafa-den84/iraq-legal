import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../models/lawyer.dart';
import '../constants/app_colors.dart';

class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> {
  Lawyer? _lawyer;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMessage;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _officeNameController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('lawyerToken');

      if (token == null) {
        Navigator.of(context).pop();
        return;
      }

      final lawyer = await SupabaseService.fetchLawyerProfile(token);
      if (lawyer != null) {
        setState(() {
          _lawyer = lawyer;
          _isLoading = false;
          _populateControllers();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_lawyer == null) return;
    _fullNameController.text = _lawyer!.fullName;
    _phoneController.text = _lawyer!.phone;
    _whatsappController.text = _lawyer!.whatsappNumber ?? '';
    _cityController.text = _lawyer!.city ?? '';
    _areaController.text = _lawyer!.area ?? '';
    _addressController.text = _lawyer!.address ?? '';
    _officeNameController.text = _lawyer!.officeName ?? '';
    _specializationController.text = _lawyer!.specialization ?? '';
    _experienceController.text = _lawyer!.experienceYears?.toString() ?? '';
  }

  Future<void> _saveProfile() async {
    if (_lawyer == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updateData = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
        'whatsapp_number': _whatsappController.text.isEmpty ? null : _whatsappController.text,
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'area': _areaController.text.isEmpty ? null : _areaController.text,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
        'office_name': _officeNameController.text.isEmpty ? null : _officeNameController.text,
        'specialization': _specializationController.text.isEmpty ? null : _specializationController.text,
        'experience_years': int.tryParse(_experienceController.text) ?? 0,
      };

      final updated = await SupabaseService.updateLawyerProfile(_lawyer!.id, updateData);

      setState(() {
        _lawyer = updated;
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lawyerToken');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Lawyer Dashboard', style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.text),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lawyer == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage ?? 'Failed to load profile', style: const TextStyle(color: AppColors.text)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_lawyer!.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Status: ${_lawyer!.status.toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        ),

                      if (_isEditing) ...[
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          style: const TextStyle(color: AppColors.text),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          style: const TextStyle(color: AppColors.text),
                          keyboardType: TextInputType.phone,
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
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                child: const Text('Save'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => setState(() => _isEditing = false),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _buildInfoRow('Full Name', _lawyer!.fullName),
                        _buildInfoRow('Phone', _lawyer!.phone),
                        if (_lawyer!.whatsappNumber != null) _buildInfoRow('WhatsApp', _lawyer!.whatsappNumber!),
                        if (_lawyer!.city != null) _buildInfoRow('City', _lawyer!.city!),
                        if (_lawyer!.area != null) _buildInfoRow('Area', _lawyer!.area!),
                        if (_lawyer!.address != null) _buildInfoRow('Address', _lawyer!.address!),
                        if (_lawyer!.officeName != null) _buildInfoRow('Office Name', _lawyer!.officeName!),
                        if (_lawyer!.specialization != null) _buildInfoRow('Specialization', _lawyer!.specialization!),
                        if (_lawyer!.experienceYears != null) _buildInfoRow('Experience Years', '${_lawyer!.experienceYears} years'),
                        if (_lawyer!.nationalId != null) _buildInfoRow('National ID', _lawyer!.nationalId!),
                        if (_lawyer!.barAssociationId != null) _buildInfoRow('Bar Association ID', _lawyer!.barAssociationId!),
                        if (_lawyer!.licenseNumber != null) _buildInfoRow('License Number', _lawyer!.licenseNumber!),
                        _buildInfoRow('Rating', '${_lawyer!.rating.toStringAsFixed(1)} / 5.0'),
                        _buildInfoRow('Reviews', '${_lawyer!.reviewsCount}'),
                        _buildInfoRow('Verified', _lawyer!.isVerified ? 'Yes' : 'No'),
                        _buildInfoRow('Visible', _lawyer!.isVisible ? 'Yes' : 'No'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => setState(() => _isEditing = true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 16)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
