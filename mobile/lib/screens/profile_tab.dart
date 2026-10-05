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
  static const emerald800 = Color(0xFF065F46);
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald200 = Color(0xFFA7F3D0);
  static const stone900 = Color(0xFF1C1917);
  static const stone600 = Color(0xFF57534E);
  static const stone500 = Color(0xFF78716C);
  static const stone300 = Color(0xFFD6D3D1);
  static const stone200 = Color(0xFFE7E5E4);

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
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

    final initials = fullName != 'N/A' && fullName.isNotEmpty
        ? fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'P';

    return RefreshIndicator(
      color: emeraldDark,
      onRefresh: _fetchPatientInfo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: emeraldDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'PATIENT PORTAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: stone500,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: stone900,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
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
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: stone300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.edit_outlined, size: 16, color: emeraldDark),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: emeraldDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: emeraldDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: emerald50,
                        shape: BoxShape.circle,
                        border: Border.all(color: emerald200, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: emeraldDark,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: emerald50.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: emerald800,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: emerald200.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'Active Patient',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: emerald50,
                                fontFamily: 'monospace',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Personal Information'),
              _buildCardSection([
                _buildProfileItem('Date of Birth', dob, icon: Icons.cake_outlined),
                const Divider(color: stone200, height: 28),
                _buildProfileItem('Sex', sex, icon: Icons.person_outline),
                const Divider(color: stone200, height: 28),
                _buildProfileItem('Contact Number', contact, icon: Icons.phone_outlined),
                const Divider(color: stone200, height: 28),
                _buildProfileItem('Emergency Contact', emergency, icon: Icons.contact_phone_outlined),
                const Divider(color: stone200, height: 28),
                _buildProfileItem('Home Address', address, icon: Icons.home_outlined),
              ]),
              const SizedBox(height: 20),
              _buildSectionHeader('Medical & Insurance Info'),
              _buildCardSection([
                _buildProfileItem('Insurance Provider', insurance, icon: Icons.verified_user_outlined),
                const Divider(color: stone200, height: 28),
                _buildProfileItem('Blood Type', bloodType, icon: Icons.bloodtype_outlined),
                const Divider(color: stone200, height: 28),
                _buildProfileItem('Known Allergies', allergies, icon: Icons.warning_amber_outlined),
              ]),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: stone300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showLogoutConfirmation,
                  icon: const Icon(Icons.logout_rounded, color: stone600, size: 18),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: stone600,
                      fontSize: 15,
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
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: stone600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stone300.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, {required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: stone500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: stone500,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: stone900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}