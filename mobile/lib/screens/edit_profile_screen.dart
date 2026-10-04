import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const emeraldDark = Color(0xFF064E3B);
  static const stone900 = Color(0xFF1C1917);
  static const bgWarm = Color(0xFFF8F6F0);

  bool _isSaving = false;

  late TextEditingController _fullNameCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _bloodCtrl;
  late TextEditingController _allergiesCtrl;

  String _selectedSex = 'Male';

  @override
  void initState() {
    super.initState();
    final data = widget.profileData;

    _fullNameCtrl = TextEditingController(text: data['full_name'] ?? '');
    _dobCtrl = TextEditingController(text: data['date_of_birth'] ?? '');
    _addressCtrl = TextEditingController(text: data['address'] ?? '');
    _contactCtrl = TextEditingController(text: data['contact_number'] ?? '');
    _emergencyCtrl = TextEditingController(text: data['emergency_contact'] ?? '');
    _insuranceCtrl = TextEditingController(text: data['insurance_provider'] ?? '');
    _bloodCtrl = TextEditingController(text: data['blood_type'] ?? '');
    _allergiesCtrl = TextEditingController(text: data['allergies'] ?? '');

    _selectedSex = data['sex'] == 'Female' ? 'Female' : 'Male';
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _emergencyCtrl.dispose();
    _insuranceCtrl.dispose();
    _bloodCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_dobCtrl.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobCtrl.text.trim());
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: emeraldDark,
              onPrimary: Colors.white,
              onSurface: stone900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final year = picked.year.toString();
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dobCtrl.text = '$year-$month-$day';
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);

    final payload = {
      "full_name": _fullNameCtrl.text.trim(),
      "date_of_birth": _dobCtrl.text.trim(),
      "sex": _selectedSex,
      "address": _addressCtrl.text.trim(),
      "contact_number": _contactCtrl.text.trim(),
      "emergency_contact": _emergencyCtrl.text.trim(),
      "insurance_provider": _insuranceCtrl.text.trim(),
      "blood_type": _bloodCtrl.text.trim(),
      "allergies": _allergiesCtrl.text.trim()
    };

    try {
      final res = await ApiService.put('/mobile/patient-info', payload);

      final resData = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showDialog(
          title: resData['status']?.toString().toUpperCase() ?? 'SUCCESS',
          message: resData['message'] ?? 'Patient information updated successfully',
          isSuccess: true,
        );
      } else {
        _showDialog(
          title: 'ERROR',
          message: resData['message'] ?? 'Failed to update profile.',
          isSuccess: false,
        );
      }
    } catch (e) {
      _showDialog(
        title: 'ERROR',
        message: 'A network error occurred. Please try again.',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: isSuccess ? emeraldDark : Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (isSuccess) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWarm,
      appBar: AppBar(
        backgroundColor: bgWarm,
        elevation: 0,
        iconTheme: const IconThemeData(color: stone900),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: stone900, fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(label: 'Full Name', controller: _fullNameCtrl),
            _buildTextField(
              label: 'Date of Birth',
              controller: _dobCtrl,
              readOnly: true,
              onTap: () => _selectDate(context),
              suffixIcon: const Icon(Icons.calendar_today, color: emeraldDark),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: InputDecoration(
                  labelText: 'Sex',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSex = val);
                },
              ),
            ),
            _buildTextField(label: 'Address', controller: _addressCtrl),
            _buildTextField(label: 'Contact Number', controller: _contactCtrl),
            _buildTextField(label: 'Emergency Contact', controller: _emergencyCtrl),
            _buildTextField(label: 'Insurance Provider', controller: _insuranceCtrl),
            _buildTextField(label: 'Blood Type', controller: _bloodCtrl),
            _buildTextField(label: 'Allergies', controller: _allergiesCtrl),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSaving ? null : _updateProfile,
                child: _isSaving
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}