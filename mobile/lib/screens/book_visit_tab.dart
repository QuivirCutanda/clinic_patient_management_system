import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookVisitTab extends StatefulWidget {
  const BookVisitTab({super.key});

  @override
  State<BookVisitTab> createState() => _BookVisitTabState();
}

class _BookVisitTabState extends State<BookVisitTab> {
  List<dynamic> doctors = [];
  List<dynamic> appointments = [];
  int? selectedDoctorId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  bool isFetchingAppointments = true;

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
    fetchDoctors();
    fetchAppointments();
  }

  void fetchDoctors() async {
    final res = await ApiService.get('/mobile/doctors');
    if (res.statusCode == 200) {
      setState(() => doctors = jsonDecode(res.body));
    }
  }

  void fetchAppointments() async {
    setState(() => isFetchingAppointments = true);
    final res = await ApiService.get('/mobile/appointments');
    if (res.statusCode == 200) {
      setState(() {
        appointments = jsonDecode(res.body);
        isFetchingAppointments = false;
      });
    } else {
      setState(() => isFetchingAppointments = false);
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

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return {
          'bg': const Color(0xFFECFDF5),
          'border': const Color(0xFFA7F3D0),
          'text': const Color(0xFF065F46)
        };
      case 'cancelled':
        return {
          'bg': const Color(0xFFFEF2F2),
          'border': const Color(0xFFFECACA),
          'text': const Color(0xFF991B1B)
        };
      case 'pending':
      default:
        return {
          'bg': const Color(0xFFFFFBEB),
          'border': const Color(0xFFFDE68A),
          'text': const Color(0xFF92400E)
        };
    }
  }

  void _showBookingModal() {
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

              setModalState(() => isLoading = true);
              setState(() => isLoading = true);

              final dateStr =
                  "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
              final timeStr =
                  "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

              final res = await ApiService.post('/mobile/appointments', {
                'doctor_id': selectedDoctorId,
                'appointment_date': dateStr,
                'appointment_time': timeStr,
              });

              setModalState(() => isLoading = false);
              setState(() => isLoading = false);

              if (res.statusCode == 201) {
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Appointment requested successfully.');
                }
                setState(() {
                  selectedDoctorId = null;
                  selectedDate = null;
                  selectedTime = null;
                });
                fetchAppointments();
              } else {
                _showSnackBar('Failed to book appointment.', isError: true);
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
                  DropdownButtonFormField<int>(
                    decoration: _inputDecoration("Choose doctor"),
                    value: selectedDoctorId,
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontSize: 13, color: stone800),
                    items: doctors.map<DropdownMenuItem<int>>((doc) {
                      return DropdownMenuItem<int>(
                        value: doc['id'],
                        child: Text("Dr. ${doc['name']}"),
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
                                : selectedTime!.format(context),
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
                      onPressed: isLoading ? null : submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
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

  void _showAppointmentDetailsModal(Map<String, dynamic> item) {
    final status = item['status'] ?? 'Pending';
    final style = _getStatusStyle(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgWarm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "APPOINTMENT DETAILS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: stone600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "#${item['appointment_id']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Serif',
                          fontWeight: FontWeight.bold,
                          color: stone900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: style['bg'],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: style['border']),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: style['text'],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: stone300, height: 1),
              ),
              _buildDetailRow("Doctor", "Dr. ${item['doctor_name'] ?? 'N/A'}"),
              _buildDetailRow("Doctor ID", "${item['doctor_id']}", isMono: true),
              _buildDetailRow("Patient ID", "${item['patient_id']}", isMono: true),
              _buildDetailRow("Date", "${item['appointment_date']}"),
              _buildDetailRow("Time", "${item['appointment_time']}"),
              _buildDetailRow("Created At", "${item['created_at'] ?? 'N/A'}"),
              _buildDetailRow("Updated At", "${item['updated_at'] ?? 'N/A'}"),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: stone300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      color: stone800,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDetailRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: stone600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: stone900,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWarm,
      body: RefreshIndicator(
        color: emeraldDark,
        onRefresh: () async => fetchAppointments(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
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
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: emeraldDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "CLINICAL VISITS",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: stone600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Appointments",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Serif',
                          fontWeight: FontWeight.bold,
                          color: stone900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showBookingModal,
                    icon: const Text(
                      "✦",
                      style: TextStyle(color: amberAccent, fontSize: 12),
                    ),
                    label: const Text(
                      "Book Visit",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emeraldDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: emeraldDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "HISTORY & SCHEDULE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: stone600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "My Appointments",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  color: stone900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              isFetchingAppointments
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: emeraldDark),
                ),
              )
                  : appointments.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stone300.withOpacity(0.6)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: stone400, size: 28),
                    SizedBox(height: 8),
                    Text(
                      "No appointments scheduled.",
                      style: TextStyle(fontSize: 12, color: stone600),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final item = appointments[index];
                  final status = item['status'] ?? 'Pending';
                  final style = _getStatusStyle(status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAppointmentDetailsModal(item),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Appt #${item['appointment_id']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: stone900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: style['bg'],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: style['border']),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: style['text'],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Dr. ${item['doctor_name'] ?? 'N/A'}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: stone800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 12, color: stone600),
                                const SizedBox(width: 4),
                                Text(
                                  "${item['appointment_date']} at ${item['appointment_time']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: stone600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Text(
                                  "View record",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: emeraldDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 11,
                                  color: emeraldDark,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: stone600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: stone400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: stone300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: emeraldDark, width: 1.5),
      ),
    );
  }
}