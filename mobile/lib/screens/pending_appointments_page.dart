import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PendingAppointmentsPage extends StatefulWidget {
  const PendingAppointmentsPage({super.key});

  static const bgWarm = Color(0xFFF8F6F0);
  static const emeraldDark = Color(0xFF064E3B);
  static const stone900 = Color(0xFF1C1917);
  static const stone800 = Color(0xFF292524);
  static const stone600 = Color(0xFF57534E);
  static const stone300 = Color(0xFFD6D3D1);

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: PendingAppointmentsPage.stone300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  color: PendingAppointmentsPage.stone900,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: PendingAppointmentsPage.stone300),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person_outline, 'Doctor Name', item['doctor_name'] ?? 'Doctor'),
              _buildDetailRow(Icons.medical_services_outlined, 'Specialization', item['specialization'] ?? 'General Medicine'),
              _buildDetailRow(Icons.calendar_today_outlined, 'Date', item['appointment_date'] ?? 'N/A'),
              _buildDetailRow(Icons.access_time_outlined, 'Time', _formatTime(item['appointment_time'])),
              _buildDetailRow(Icons.info_outline, 'Status', item['status'] ?? 'Pending'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PendingAppointmentsPage.emeraldDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PendingAppointmentsPage.emeraldDark),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: PendingAppointmentsPage.stone600),
              ),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PendingAppointmentsPage.bgWarm,
      appBar: AppBar(
        backgroundColor: PendingAppointmentsPage.bgWarm,
        elevation: 0,
        iconTheme: const IconThemeData(color: PendingAppointmentsPage.stone900),
        title: const Text(
          "Pending Appointments",
          style: TextStyle(
            fontSize: 18,
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
                  color: PendingAppointmentsPage.emeraldDark,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: PendingAppointmentsPage.stone600),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PendingAppointmentsPage.emeraldDark,
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
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 48, color: PendingAppointmentsPage.stone600),
                    SizedBox(height: 12),
                    Text(
                      'No pending appointments',
                      style: TextStyle(fontSize: 16, color: PendingAppointmentsPage.stone600),
                    ),
                  ],
                ),
              );
            }

            final pendingList = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pendingList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = pendingList[index] as Map<String, dynamic>;
                final doctorName = item['doctor_name'] ?? 'Doctor';
                final specialization = item['specialization'] ?? 'General Medicine';
                final appointmentDate = item['appointment_date'] ?? '';
                final appointmentTime = _formatTime(item['appointment_time']);
                final status = item['status'] ?? 'Pending';

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showAppointmentDetails(context, item),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PendingAppointmentsPage.stone300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialization,
                            style: const TextStyle(fontSize: 12, color: PendingAppointmentsPage.stone600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: PendingAppointmentsPage.stone600),
                              const SizedBox(width: 6),
                              Text(
                                appointmentDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PendingAppointmentsPage.stone800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time_outlined, size: 14, color: PendingAppointmentsPage.stone600),
                              const SizedBox(width: 6),
                              Text(
                                appointmentTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PendingAppointmentsPage.stone800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
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