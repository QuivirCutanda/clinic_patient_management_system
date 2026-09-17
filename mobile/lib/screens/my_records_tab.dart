import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyRecordsTab extends StatefulWidget {
  const MyRecordsTab({super.key});

  @override
  State<MyRecordsTab> createState() => _MyRecordsTabState();
}

class _MyRecordsTabState extends State<MyRecordsTab> {
  List<dynamic> records = [];
  bool isLoading = true;

  static const bgWarm = Color(0xFFF8F6F0);
  static const emeraldDark = Color(0xFF064E3B);
  static const emeraldBg = Color(0xFFECFDF5);
  static const emeraldBorder = Color(0xFFA7F3D0);
  static const stone900 = Color(0xFF1C1917);
  static const stone800 = Color(0xFF292524);
  static const stone600 = Color(0xFF57534E);
  static const stone400 = Color(0xFFA8A29E);
  static const stone300 = Color(0xFFD6D3D1);

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  void fetchRecords() async {
    setState(() => isLoading = true);
    final res = await ApiService.get('/mobile/my-records');
    if (res.statusCode == 200) {
      setState(() {
        records = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _showRecordDetailsModal(Map<String, dynamic> rec) {
    final dateStr = rec['consultation_date'] != null
        ? rec['consultation_date'].toString().substring(0, 10)
        : 'N/A';

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
                        "CONSULTATION SUMMARY",
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
                        "Dr. ${rec['doctor_name'] ?? 'N/A'}",
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
                      color: emeraldBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: emeraldBorder),
                    ),
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        color: emeraldDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'monospace',
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
              _buildSectionBlock("Diagnosis", rec['diagnosis'] ?? 'No diagnosis recorded.'),
              const SizedBox(height: 12),
              _buildSectionBlock("Vital Signs", rec['vitals'] ?? 'Not specified.', isMono: true),
              const SizedBox(height: 12),
              _buildSectionBlock("Prescription List", rec['prescription_list'] ?? 'None prescribed.'),
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

  Widget _buildSectionBlock(String title, String content, {bool isMono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: stone600,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: stone300.withOpacity(0.6)),
          ),
          child: Text(
            content.isEmpty ? 'N/A' : content,
            style: TextStyle(
              fontSize: 13,
              color: stone900,
              height: 1.4,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWarm,
      body: RefreshIndicator(
        color: emeraldDark,
        onRefresh: () async => fetchRecords(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                    "MEDICAL HISTORY",
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
                "My Medical Records",
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  color: stone900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(color: emeraldDark),
                ),
              )
                  : records.isEmpty
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
                    Icon(Icons.assignment_outlined, color: stone400, size: 32),
                    SizedBox(height: 8),
                    Text(
                      "No medical records found.",
                      style: TextStyle(fontSize: 12, color: stone600),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, i) {
                  final rec = records[i];
                  final dateStr = rec['consultation_date'] != null
                      ? rec['consultation_date'].toString().substring(0, 10)
                      : 'N/A';

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
                      onTap: () => _showRecordDetailsModal(rec),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Dr. ${rec['doctor_name'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: stone900,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: stone600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(color: stone300, height: 1),
                            ),
                            RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: stone800,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Diagnosis: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: stone600,
                                    ),
                                  ),
                                  TextSpan(text: rec['diagnosis'] ?? 'None'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: stone800,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Vitals: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: stone600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: rec['vitals'] ?? 'Not specified',
                                    style: const TextStyle(fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Text(
                                  "View full record",
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
                                ),
                              ],
                            ),
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
}