import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'pending_appointments_page.dart';
import 'confirmed_appointments_page.dart';
import 'history_appointments_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String patientName = '';
  int pendingCount = 0;
  int confirmedCount = 0;
  int historyCount = 0;
  Map<String, dynamic>? nextAppointment;
  bool isFetching = true;

  List<dynamic> doctors = [];
  bool isFetchingDoctors = false;
  int? selectedDoctorId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isBookingLoading = false;

  static const bgWarm = Color(0xFFF8F6F0);
  static const emeraldDark = Color(0xFF064E3B);
  static const emeraldBg = Color(0xFFECFDF5);
  static const emeraldBorder = Color(0xFFA7F3D0);
  static const amberAccent = Color(0xFFFBBF24);
  static const stone900 = Color(0xFF1C1917);
  static const stone800 = Color(0xFF292524);
  static const stone600 = Color(0xFF57534E);
  static const stone400 = Color(0xFFA8A29E);
  static const stone300 = Color(0xFFD6D3D1);

  @override
  void initState() {
    super.initState();
    fetchDashboard();
    fetchDoctors();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hStr:$mStr $period';
  }

  String _formatTimeString(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return '09:30 AM';
    try {
      final parts = rawTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final hStr = hour.toString().padLeft(2, '0');
        final mStr = minute.toString().padLeft(2, '0');
        return '$hStr:$mStr $period';
      }
    } catch (_) {}
    return rawTime;
  }

  Future<void> fetchDashboard() async {
    setState(() => isFetching = true);
    try {
      final res = await ApiService.get('/mobile/dashboard');
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        final counts = data['counts'] ?? {};
        setState(() {
          patientName = data['patient_name'] ?? '';
          pendingCount = counts['pending_count'] ?? 0;
          confirmedCount = counts['confirmed_count'] ?? 0;
          historyCount = counts['history_count'] ?? 0;
          nextAppointment = data['next_appointment'];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => isFetching = false);
      }
    }
  }

  Future<void> fetchDoctors() async {
    if (isFetchingDoctors) return;
    setState(() => isFetchingDoctors = true);
    try {
      final res = await ApiService.get('/mobile/doctors');
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(() => doctors = data);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => isFetchingDoctors = false);
      }
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFF7F1D1D) : emeraldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: stone800,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: stone400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: stone300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: emeraldDark),
      ),
    );
  }

  void _showBookingModal() {
    if (doctors.isEmpty) {
      fetchDoctors();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgWarm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: emeraldDark,
                        onPrimary: Colors.white,
                        onSurface: stone800,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setModalState(() => selectedDate = picked);
                setState(() => selectedDate = picked);
              }
            }

            void pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: emeraldDark,
                        onPrimary: Colors.white,
                        onSurface: stone800,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setModalState(() => selectedTime = picked);
                setState(() => selectedTime = picked);
              }
            }

            void submitBooking() async {
              if (selectedDoctorId == null || selectedDate == null || selectedTime == null) {
                _showSnackBar('Please complete all booking details.', isError: true);
                return;
              }

              setModalState(() => isBookingLoading = true);
              setState(() => isBookingLoading = true);

              final dateStr =
                  "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
              final timeStr =
                  "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

              try {
                final res = await ApiService.post('/mobile/appointments', {
                  'doctor_id': selectedDoctorId,
                  'appointment_date': dateStr,
                  'appointment_time': timeStr,
                });

                setModalState(() => isBookingLoading = false);
                setState(() => isBookingLoading = false);

                if (res.statusCode == 201 || res.statusCode == 200) {
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar('Appointment requested successfully.');
                  }
                  setState(() {
                    selectedDoctorId = null;
                    selectedDate = null;
                    selectedTime = null;
                  });
                  fetchDashboard();
                } else {
                  _showSnackBar('Failed to book appointment.', isError: true);
                }
              } catch (_) {
                setModalState(() => isBookingLoading = false);
                setState(() => isBookingLoading = false);
                _showSnackBar('An error occurred. Please try again.', isError: true);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
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
                        color: stone300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NEW APPOINTMENT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: stone600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Book a Visit",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Serif',
                              fontWeight: FontWeight.bold,
                              color: stone900,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: stone600, size: 20),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: stone300, height: 1),
                  ),

                  _buildLabel("Select Practitioner"),
                  const SizedBox(height: 6),
                  if (isFetchingDoctors)
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: stone300),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: emeraldDark),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Loading doctors...",
                            style: TextStyle(fontSize: 13, color: stone400),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration("Choose doctor"),
                      value: selectedDoctorId,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: const TextStyle(fontSize: 13, color: stone800),
                      items: doctors.map<DropdownMenuItem<int>>((doc) {
                        final int docId = doc['id'] is int
                            ? doc['id']
                            : int.parse(doc['id'].toString());
                        final String docName = doc['name']?.toString() ?? 'Doctor #$docId';
                        return DropdownMenuItem<int>(
                          value: docId,
                          child: Text(docName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => selectedDoctorId = val);
                        setState(() => selectedDoctorId = val);
                      },
                    ),
                  const SizedBox(height: 16),

                  _buildLabel("Appointment Date"),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: stone300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null
                                ? "Choose Date"
                                : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedDate == null ? stone400 : stone800,
                              fontFamily: selectedDate != null ? 'monospace' : null,
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: stone600),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Preferred Time"),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: pickTime,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: stone300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTime == null
                                ? "Choose Time"
                                : _formatTimeOfDay(selectedTime!),
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedTime == null ? stone400 : stone800,
                              fontFamily: selectedTime != null ? 'monospace' : null,
                            ),
                          ),
                          const Icon(Icons.access_time_outlined, size: 16, color: stone600),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isBookingLoading ? null : submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isBookingLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "✦ ",
                                  style: TextStyle(
                                    color: amberAccent,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Confirm Booking",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return {
          'bg': emeraldBg,
          'text': emeraldDark,
          'border': emeraldBorder,
          'label': 'CONFIRMED',
        };
      case 'pending':
        return {
          'bg': const Color(0xFFFEF3C7),
          'text': const Color(0xFF92400E),
          'border': const Color(0xFFFDE68A),
          'label': 'PENDING',
        };
      case 'cancelled':
      case 'canceled':
        return {
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFF991B1B),
          'border': const Color(0xFFFECACA),
          'label': 'CANCELLED',
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': stone600,
          'border': stone300,
          'label': status.toUpperCase(),
        };
    }
  }

  Widget _buildNextAppointmentCard() {
    if (nextAppointment == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stone300),
        ),
        child: Column(
          children: [
            const Icon(Icons.event_available_outlined, size: 36, color: stone400),
            const SizedBox(height: 8),
            const Text(
              'No Upcoming Appointments',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: stone800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Book a visit with a practitioner whenever you are ready.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: stone600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showBookingModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: emeraldDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final doctorName = nextAppointment!['doctor_name'] ?? 'Doctor';
    final date = nextAppointment!['appointment_date'] ?? '';
    final time = _formatTimeString(nextAppointment!['appointment_time']);
    final status = nextAppointment!['status'] ?? 'pending';
    final style = _getStatusStyle(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stone300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NEXT APPOINTMENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: stone600,
                  fontFamily: 'monospace',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: style['bg'] as Color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: style['border'] as Color),
                ),
                child: Text(
                  style['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: style['text'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            doctorName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: stone900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: stone600),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: stone800, fontFamily: 'monospace'),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 14, color: stone600),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(fontSize: 13, color: stone800, fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stone300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: stone900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: stone600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWarm,
      body: SafeArea(
        child: isFetching
            ? const Center(
                child: CircularProgressIndicator(color: emeraldDark),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await fetchDashboard();
                  await fetchDoctors();
                },
                color: emeraldDark,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      const SizedBox(height: 20),
                      _buildNextAppointmentCard(),
                      const SizedBox(height: 20),
                      const Text(
                        'APPOINTMENTS OVERVIEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: stone600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStatCard(
                            title: 'Pending',
                            count: pendingCount,
                            icon: Icons.hourglass_top_outlined,
                            color: const Color(0xFFD97706),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PendingAppointmentsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            title: 'Confirmed',
                            count: confirmedCount,
                            icon: Icons.check_circle_outline,
                            color: emeraldDark,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ConfirmedAppointmentsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            title: 'History',
                            count: historyCount,
                            icon: Icons.history,
                            color: stone600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryAppointmentsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: emeraldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: emeraldBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: emeraldDark, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Need a Consultation?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: emeraldDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Schedule a visit with available doctors in seconds.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: emeraldDark.withAlpha(200),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _showBookingModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: emeraldDark,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Book Now',
                                style: TextStyle(fontSize: 12, color: Colors.white),
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
  }
}