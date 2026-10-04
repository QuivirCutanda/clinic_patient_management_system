import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConfirmedAppointmentsPage extends StatefulWidget {
  const ConfirmedAppointmentsPage({super.key});

  static const bgWarm = Color(0xFFF8F6F0);
  static const emeraldDark = Color(0xFF064E3B);
  static const stone900 = Color(0xFF1C1917);
  static const stone800 = Color(0xFF292524);
  static const stone600 = Color(0xFF57534E);
  static const stone300 = Color(0xFFD6D3D1);

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
    if (timeStr == null || timeStr.isEmpty) return 'N/A';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        String period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        String minuteStr = minute.toString().padLeft(2, '0');
        return '$hour:$minuteStr $period';
      }
    } catch (_) {}
    return timeStr;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
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
          'bg': const Color(0xFFECFDF5),
          'border': const Color(0xFFA7F3D0),
          'text': const Color(0xFF065F46),
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
    final status = item['status'] ?? 'Confirmed';
    final badge = _getBadgeColors(status);
    final formattedDate = _formatDate(item['appointment_date']);
    final formattedTime = _formatTime(item['appointment_time']);

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
                    color: ConfirmedAppointmentsPage.stone300,
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
                  color: ConfirmedAppointmentsPage.stone900,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: ConfirmedAppointmentsPage.stone300),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person_outline, 'Doctor Name', item['doctor_name'] ?? 'Doctor'),
              if (item['specialization'] != null)
                _buildDetailRow(Icons.medical_services_outlined, 'Specialization', item['specialization']),
              _buildDetailRow(Icons.calendar_today_outlined, 'Date', formattedDate),
              _buildDetailRow(Icons.access_time_outlined, 'Time', formattedTime),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: ConfirmedAppointmentsPage.emeraldDark),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(fontSize: 12, color: ConfirmedAppointmentsPage.stone600),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badge['bg'],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: badge['border']!),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badge['text'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConfirmedAppointmentsPage.emeraldDark,
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
          Icon(icon, size: 20, color: ConfirmedAppointmentsPage.emeraldDark),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: ConfirmedAppointmentsPage.stone600),
              ),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfirmedAppointmentsPage.bgWarm,
      appBar: AppBar(
        backgroundColor: ConfirmedAppointmentsPage.bgWarm,
        elevation: 0,
        iconTheme: const IconThemeData(color: ConfirmedAppointmentsPage.stone900),
        title: const Text(
          "Confirmed Appointments",
          style: TextStyle(
            fontSize: 18,
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
                  color: ConfirmedAppointmentsPage.emeraldDark,
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
                        style: const TextStyle(color: ConfirmedAppointmentsPage.stone600),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConfirmedAppointmentsPage.emeraldDark,
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
                    Icon(Icons.event_available_outlined, size: 48, color: ConfirmedAppointmentsPage.stone600),
                    SizedBox(height: 12),
                    Text(
                      'No confirmed appointments',
                      style: TextStyle(fontSize: 16, color: ConfirmedAppointmentsPage.stone600),
                    ),
                  ],
                ),
              );
            }

            final confirmedList = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: confirmedList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = confirmedList[index] as Map<String, dynamic>;
                final doctorName = item['doctor_name'] ?? 'Doctor';
                final specialization = item['specialization'] ?? 'General Medicine';
                final appointmentDate = _formatDate(item['appointment_date']);
                final appointmentTime = _formatTime(item['appointment_time']);
                final status = item['status'] ?? 'Confirmed';
                final badge = _getBadgeColors(status);

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
                        border: Border.all(color: ConfirmedAppointmentsPage.stone300),
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
                                  color: ConfirmedAppointmentsPage.stone900,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badge['bg'],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: badge['border']!),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: badge['text'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialization,
                            style: const TextStyle(fontSize: 12, color: ConfirmedAppointmentsPage.stone600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: ConfirmedAppointmentsPage.stone600),
                              const SizedBox(width: 6),
                              Text(
                                appointmentDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ConfirmedAppointmentsPage.stone800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time_outlined, size: 14, color: ConfirmedAppointmentsPage.stone600),
                              const SizedBox(width: 6),
                              Text(
                                appointmentTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ConfirmedAppointmentsPage.stone800,
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