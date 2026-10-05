import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConfirmedAppointmentsPage extends StatefulWidget {
  const ConfirmedAppointmentsPage({super.key});

  static const bgWarm = Color(0xFFF8F6F0);
  static const emeraldDark = Color(0xFF064E3B);
  static const emerald800 = Color(0xFF065F46);
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald200 = Color(0xFFA7F3D0);
  static const stone900 = Color(0xFF1C1917);
  static const stone800 = Color(0xFF292524);
  static const stone600 = Color(0xFF57534E);
  static const stone500 = Color(0xFF78716C);
  static const stone300 = Color(0xFFD6D3D1);
  static const stone200 = Color(0xFFE7E5E4);

  @override
  State<ConfirmedAppointmentsPage> createState() => _ConfirmedAppointmentsPageState();
}

class _ConfirmedAppointmentsPageState extends State<ConfirmedAppointmentsPage> {
  late Future<List<dynamic>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = fetchConfirmedAppointments();
  }

  Future<List<dynamic>> fetchConfirmedAppointments() async {
    final response = await ApiService.get('/mobile/appointments/confirmed');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load confirmed appointments');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _appointmentsFuture = fetchConfirmedAppointments();
    });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return 'N/A';
    try {
      String cleanTime = timeStr.trim();
      bool isPm = cleanTime.toUpperCase().contains('PM');
      bool isAm = cleanTime.toUpperCase().contains('AM');

      cleanTime = cleanTime.replaceAll(RegExp(r'[a-zA-Z]'), '').trim();
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (isPm && hour < 12) {
          hour += 12;
        } else if (isAm && hour == 12) {
          hour = 0;
        }

        String period = hour >= 12 ? 'PM' : 'AM';
        int formattedHour = hour % 12;
        if (formattedHour == 0) formattedHour = 12;

        String hourStr = formattedHour.toString().padLeft(2, '0');
        String minuteStr = minute.toString().padLeft(2, '0');

        return '$hourStr:$minuteStr $period';
      }
    } catch (_) {}
    return timeStr;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return 'N/A';
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
    } catch (_) {}
    return dateStr;
  }

  Map<String, Color> _getBadgeColors(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return {
          'bg': ConfirmedAppointmentsPage.emerald50,
          'border': ConfirmedAppointmentsPage.emerald200,
          'text': ConfirmedAppointmentsPage.emerald800,
        };
      case 'waiting':
        return {
          'bg': const Color(0xFFFFFBEB),
          'border': const Color(0xFFFDE68A),
          'text': const Color(0xFF92400E),
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'border': const Color(0xFFE5E7EB),
          'text': const Color(0xFF374151),
        };
    }
  }

  void _showAppointmentDetails(BuildContext context, Map<String, dynamic> item) {
    final doctorName = item['doctor_name'] ?? 'Doctor';
    final specialization = item['specialization'] ?? 'General Medicine';
    final formattedDate = _formatDate(item['appointment_date']);
    final formattedTime = _formatTime(item['appointment_time']);
    final status = item['status'] ?? 'Confirmed';
    final badge = _getBadgeColors(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: ConfirmedAppointmentsPage.stone300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.bold,
                      color: ConfirmedAppointmentsPage.stone900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badge['bg'],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badge['border']!),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: badge['text'],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: ConfirmedAppointmentsPage.stone200, height: 1),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person_outline, 'DOCTOR NAME', doctorName),
              const SizedBox(height: 14),
              _buildDetailRow(Icons.medical_services_outlined, 'SPECIALIZATION', specialization),
              const SizedBox(height: 14),
              _buildDetailRow(Icons.calendar_today_outlined, 'DATE', formattedDate),
              const SizedBox(height: 14),
              _buildDetailRow(Icons.access_time_outlined, 'TIME', formattedTime),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConfirmedAppointmentsPage.emeraldDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ConfirmedAppointmentsPage.emerald50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: ConfirmedAppointmentsPage.emeraldDark),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: ConfirmedAppointmentsPage.stone500,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ConfirmedAppointmentsPage.stone900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfirmedAppointmentsPage.bgWarm,
      appBar: AppBar(
        backgroundColor: ConfirmedAppointmentsPage.bgWarm,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ConfirmedAppointmentsPage.stone900),
        title: const Text(
          "Confirmed Appointments",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            color: ConfirmedAppointmentsPage.stone900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: ConfirmedAppointmentsPage.emeraldDark,
        child: FutureBuilder<List<dynamic>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ConfirmedAppointmentsPage.emeraldDark),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline_rounded, size: 36, color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ConfirmedAppointmentsPage.stone600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConfirmedAppointmentsPage.emeraldDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: ConfirmedAppointmentsPage.emerald50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_available_outlined,
                        size: 40,
                        color: ConfirmedAppointmentsPage.emeraldDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Confirmed Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Serif',
                        fontWeight: FontWeight.bold,
                        color: ConfirmedAppointmentsPage.stone900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your upcoming confirmed appointments will appear here.',
                      style: TextStyle(
                        fontSize: 13,
                        color: ConfirmedAppointmentsPage.stone500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final confirmedList = snapshot.data!;

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: confirmedList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = confirmedList[index] as Map<String, dynamic>;
                final doctorName = item['doctor_name'] ?? 'Doctor';
                final specialization = item['specialization'] ?? 'General Medicine';
                final appointmentDate = _formatDate(item['appointment_date']);
                final appointmentTime = _formatTime(item['appointment_time']);
                final status = item['status'] ?? 'Confirmed';
                final badge = _getBadgeColors(status);

                final initial = doctorName.isNotEmpty ? doctorName.replaceAll('Dr.', '').trim()[0].toUpperCase() : 'D';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ConfirmedAppointmentsPage.stone300.withOpacity(0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showAppointmentDetails(context, item),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: ConfirmedAppointmentsPage.emerald50,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: ConfirmedAppointmentsPage.emerald200),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: ConfirmedAppointmentsPage.emeraldDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Serif',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctorName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Serif',
                                          fontWeight: FontWeight.bold,
                                          color: ConfirmedAppointmentsPage.stone900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        specialization,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: ConfirmedAppointmentsPage.stone600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: badge['bg'],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: badge['border']!),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: badge['text'],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: ConfirmedAppointmentsPage.bgWarm,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: ConfirmedAppointmentsPage.emeraldDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    appointmentDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ConfirmedAppointmentsPage.stone800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.access_time_outlined,
                                    size: 14,
                                    color: ConfirmedAppointmentsPage.emeraldDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    appointmentTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ConfirmedAppointmentsPage.stone800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}