import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyBillsTab extends StatefulWidget {
  const MyBillsTab({super.key});

  @override
  State<MyBillsTab> createState() => _MyBillsTabState();
}

class _MyBillsTabState extends State<MyBillsTab> {
  List<dynamic> bills = [];
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
    fetchBills();
  }

  void fetchBills() async {
    setState(() => isLoading = true);
    final res = await ApiService.get('/mobile/my-bills');
    if (res.statusCode == 200) {
      setState(() {
        bills = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return {
          'bg': const Color(0xFFECFDF5),
          'border': const Color(0xFFA7F3D0),
          'text': const Color(0xFF065F46)
        };
      case 'unpaid':
      case 'pending':
      default:
        return {
          'bg': const Color(0xFFFEF2F2),
          'border': const Color(0xFFFECACA),
          'text': const Color(0xFF991B1B)
        };
    }
  }

  void _showReceiptModal(Map<String, dynamic> bill) {
    final status = bill['status'] ?? 'Paid';
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
                        "OFFICIAL RECEIPT",
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
                        "Invoice #${bill['id']}",
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
              _buildDetailRow("Invoice ID", "#${bill['id']}", isMono: true),
              _buildDetailRow("Amount Paid", "₱${bill['fee_amount']}", isMono: true, isBold: true),
              _buildDetailRow("Payment Method", "${bill['payment_method'] ?? 'N/A'}"),
              _buildDetailRow("Status", status, isColorText: true, textColor: style['text']),
              if (bill['created_at'] != null)
                _buildDetailRow("Issued Date", "${bill['created_at']}"),
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

  Widget _buildDetailRow(
      String label,
      String value, {
        bool isMono = false,
        bool isBold = false,
        bool isColorText = false,
        Color textColor = stone900,
      }) {
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
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isColorText ? textColor : stone900,
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
        onRefresh: () async => fetchBills(),
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
                    "FINANCIAL STATEMENT",
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
                "My Bills & Receipts",
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
                  : bills.isEmpty
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
                    Icon(Icons.receipt_long_outlined, color: stone400, size: 32),
                    SizedBox(height: 8),
                    Text(
                      "No billing records found.",
                      style: TextStyle(fontSize: 12, color: stone600),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bills.length,
                itemBuilder: (context, i) {
                  final bill = bills[i];
                  final status = bill['status'] ?? 'Unpaid';
                  final bool isPaid = status.toLowerCase() == 'paid';
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Invoice #${bill['id']}",
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
                          const SizedBox(height: 8),
                          Text(
                            "₱${bill['fee_amount']}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: stone900,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Payment Method: ${bill['payment_method'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: stone600,
                            ),
                          ),
                          if (!isPaid) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 13,
                                  color: style['text'],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Please settle payment at the clinic counter.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: style['text'],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (isPaid) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(color: stone300, height: 1),
                            ),
                            InkWell(
                              onTap: () => _showReceiptModal(bill),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 14,
                                      color: emeraldDark,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "View Digital Receipt",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: emeraldDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: emeraldDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
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