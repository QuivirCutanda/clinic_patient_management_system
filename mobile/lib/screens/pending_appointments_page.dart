import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PendingAppointmentsPage extends StatefulWidget {
  const PendingAppointmentsPage({super.key});

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
  State<PendingAppointmentsPage> createState() => _PendingAppointmentsPageState();
}

class _PendingAppointmentsPageState extends State<PendingAppointmentsPage> {
  late Future<List<dynamic>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = fetchPendingAppointments();
  }

  Future<List<dynamic>> fetchPendingAppointments() async {
    final response = await ApiService.get('/mobile/appointments/pending');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load pending appointments');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _appointmentsFuture = fetchPendingAppointments();
    });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return 'N/A';
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]);
        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hour:$minuteStr $period';
      }
    } catch (_) {}
    return timeStr;
  }

  void _showAppointmentDetails(BuildContext context, Map<String, dynamic> item) {
    final doctorName = item['doctor_name'] ?? 'Doctor';
    final specialization = item['specialization'] ?? 'General Medicine';
    final appointmentDate = item['appointment_date'] ?? 'N/A';
    final appointmentTime = _formatTime(item['appointment_time']);
    final status = item['status'] ?? 'Pending';

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
                    color: PendingAppointmentsPage.stone300,
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
                      color: PendingAppointmentsPage.stone900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFF92400E),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: PendingAppointmentsPage.stone200, height: 1),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person_outline, 'DOCTOR NAME', doctorName),
              const SizedBox(height: 14),
              _buildDetailRow(Icons.medical_services_outlined, 'SPECIALIZATION', specialization),
              const SizedBox(height: 14),
              _buildDetailRow(Icons.calendar_today_outlined, 'DATE', appointmentDate),
              const SizedBox(height: 14),
              _buildDetailRow(Icons.access_time_outlined, 'TIME', appointmentTime),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PendingAppointmentsPage.emeraldDark,
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
            color: PendingAppointmentsPage.emerald50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: PendingAppointmentsPage.emeraldDark),
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
                  color: PendingAppointmentsPage.stone500,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: PendingAppointmentsPage.stone900,
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
      backgroundColor: PendingAppointmentsPage.bgWarm,
      appBar: AppBar(
        backgroundColor: PendingAppointmentsPage.bgWarm,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: PendingAppointmentsPage.stone900),
        title: const Text(
          "Pending Appointments",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            color: PendingAppointmentsPage.stone900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: PendingAppointmentsPage.emeraldDark,
        child: FutureBuilder<List<dynamic>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(PendingAppointmentsPage.emeraldDark),
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
                          color: PendingAppointmentsPage.stone600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PendingAppointmentsPage.emeraldDark,
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
                        color: PendingAppointmentsPage.emerald50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 40,
                        color: PendingAppointmentsPage.emeraldDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Pending Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Serif',
                        fontWeight: FontWeight.bold,
                        color: PendingAppointmentsPage.stone900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your requested appointments will appear here.',
                      style: TextStyle(
                        fontSize: 13,
                        color: PendingAppointmentsPage.stone500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final pendingList = snapshot.data!;

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: pendingList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = pendingList[index] as Map<String, dynamic>;
                final doctorName = item['doctor_name'] ?? 'Doctor';
                final specialization = item['specialization'] ?? 'General Medicine';
                final appointmentDate = item['appointment_date'] ?? 'N/A';
                final appointmentTime = _formatTime(item['appointment_time']);
                final status = item['status'] ?? 'Pending';

                final initial = doctorName.isNotEmpty ? doctorName.replaceAll('Dr.', '').trim()[0].toUpperCase() : 'D';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PendingAppointmentsPage.stone300.withOpacity(0.8)),
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
                                    color: PendingAppointmentsPage.emerald50,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: PendingAppointmentsPage.emerald200),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: PendingAppointmentsPage.emeraldDark,
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
                                          color: PendingAppointmentsPage.stone900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        specialization,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: PendingAppointmentsPage.stone600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF92400E),
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
                                color: PendingAppointmentsPage.bgWarm,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: PendingAppointmentsPage.emeraldDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    appointmentDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: PendingAppointmentsPage.stone800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.access_time_outlined,
                                    size: 14,
                                    color: PendingAppointmentsPage.emeraldDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    appointmentTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: PendingAppointmentsPage.stone800,
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