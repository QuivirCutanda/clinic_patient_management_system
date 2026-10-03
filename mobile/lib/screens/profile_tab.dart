import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;

  static const bgWarm = Color(0xFFF8F6F0);
  static const emeraldDark = Color(0xFF064E3B);
  static const stone900 = Color(0xFF1C1917);
  static const stone600 = Color(0xFF57534E);
  static const stone300 = Color(0xFFD6D3D1);

  @override
  void initState() {
    super.initState();
    _fetchPatientInfo();
  }

  Future<void> _fetchPatientInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.get('/mobile/patient-info');

      if (res.statusCode == 200) {
        setState(() {
          _profileData = jsonDecode(res.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile. Server returned ${res.statusCode}.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: stone300, width: 1),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: stone900,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of your patient portal account?',
            style: TextStyle(
              fontSize: 14,
              color: stone600,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: stone600,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: emeraldDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWarm,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(emeraldDark),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: stone600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPatientInfo,
                style: ElevatedButton.styleFrom(backgroundColor: emeraldDark),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final data = _profileData ?? {};
    final fullName = data['full_name'] ?? 'N/A';
    final email = data['email'] ?? 'N/A';
    final dob = data['date_of_birth'] ?? 'N/A';
    final sex = data['sex'] ?? 'N/A';
    final contact = data['contact_number'] ?? 'N/A';
    final emergency = data['emergency_contact'] ?? 'N/A';
    final address = data['address'] ?? 'N/A';
    final insurance = data['insurance_provider'] ?? 'N/A';
    final bloodType = data['blood_type'] ?? 'N/A';
    final allergies = data['allergies'] ?? 'None reported';

    return RefreshIndicator(
      color: emeraldDark,
      onRefresh: _fetchPatientInfo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: stone900,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final didUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            profileData: data,
                          ),
                        ),
                      );
                      if (didUpdate == true) {
                        _fetchPatientInfo();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18, color: emeraldDark),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: emeraldDark, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCardSection([
                _buildProfileItem('Full Name', fullName),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Email Address', email),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Account Status', 'Active Patient', isStatus: true),
              ]),
              const SizedBox(height: 16),
              _buildSectionHeader('Personal Information'),
              _buildCardSection([
                _buildProfileItem('Date of Birth', dob),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Sex', sex),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Contact Number', contact),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Emergency Contact', emergency),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Home Address', address),
              ]),
              const SizedBox(height: 16),
              _buildSectionHeader('Medical & Insurance info'),
              _buildCardSection([
                _buildProfileItem('Insurance Provider', insurance),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Blood Type', bloodType),
                const Divider(color: stone300, height: 32),
                _buildProfileItem('Known Allergies', allergies),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: stone300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showLogoutConfirmation,
                  icon: const Icon(Icons.logout_rounded, color: stone600, size: 20),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: stone600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: stone600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stone300.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, {bool isStatus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: stone600,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: emeraldDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Active Portal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: emeraldDark,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: stone900,
            ),
          ),
      ],
    );
  }
}