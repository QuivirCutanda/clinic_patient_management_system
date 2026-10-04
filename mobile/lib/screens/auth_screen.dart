
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
const AuthScreen({super.key});

@override
State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _nameController = TextEditingController();
final _contactController = TextEditingController();
final _emergencyController = TextEditingController();
final _insuranceController = TextEditingController();

bool _isLogin = true;
bool _isLoading = false;

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
_nameController.dispose();
_contactController.dispose();
_emergencyController.dispose();
_insuranceController.dispose();
super.dispose();
}

void _submit() async {
FocusScope.of(context).unfocus();
setState(() => _isLoading = true);

try {
if (_isLogin) {
final res = await ApiService.post('/mobile/login', {
'email': _emailController.text.trim(),
'password': _passwordController.text,
});

if (res.statusCode == 200) {
final data = jsonDecode(res.body);
final prefs = await SharedPreferences.getInstance();
await prefs.setString('mobile_token', data['token']);
await prefs.setString('patient_name', data['patient']['full_name']);

if (mounted) {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (_) => const HomeScreen()),
);
}
} else {
_showSnackBar("Login Failed. Please check your credentials.", isError: true);
}
} else {
final res = await ApiService.post('/mobile/register', {
'email': _emailController.text.trim(),
'password': _passwordController.text,
'full_name': _nameController.text.trim(),
'contact_number': _contactController.text.trim(),
'emergency_contact': _emergencyController.text.trim(),
'insurance_provider': _insuranceController.text.trim(),
});

final resData = jsonDecode(res.body);

if (res.statusCode == 201 || res.statusCode == 200 || resData['status'] == 'success') {
setState(() => _isLogin = true);
_showSnackBar("Registration successful! Please sign in.");
} else {
_showSnackBar("Registration Failed.", isError: true);
}
}
} catch (e) {
_showSnackBar("Connection error: $e", isError: true);
} finally {
if (mounted) setState(() => _isLoading = false);
}
}

void _showSnackBar(String msg, {bool isError = false}) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
backgroundColor: isError ? const Color(0xFF7F1D1D) : const Color(0xFF064E3B),
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

@override
Widget build(BuildContext context) {
const bgWarm = Color(0xFFF8F6F0);
const emeraldDark = Color(0xFF064E3B);
const stone800 = Color(0xFF292524);
const stone600 = Color(0xFF57534E);
const stone300 = Color(0xFFD6D3D1);

return Scaffold(
backgroundColor: bgWarm,
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
width: 8,
height: 8,
decoration: const BoxDecoration(
color: emeraldDark,
shape: BoxShape.circle,
),
),
const SizedBox(width: 8),
const Text(
"PATIENT PORTAL",
style: TextStyle(
fontSize: 10,
fontWeight: FontWeight.bold,
letterSpacing: 1.5,
color: stone600,
fontFamily: 'monospace',
),
),
],
),
const SizedBox(height: 8),

Text(
_isLogin ? "Welcome Back" : "Create Account",
textAlign: TextAlign.center,
style: const TextStyle(
fontFamily: 'Serif',
fontSize: 28,
fontWeight: FontWeight.bold,
color: stone800,
letterSpacing: -0.5,
),
),
const SizedBox(height: 32),

Container(
padding: const EdgeInsets.all(24.0),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: stone300.withOpacity(0.6)),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.02),
blurRadius: 4,
offset: const Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
if (!_isLogin) ...[
_buildLabel("Full Name"),
const SizedBox(height: 6),
TextField(
controller: _nameController,
style: const TextStyle(fontSize: 13, color: stone800),
decoration: _inputDecoration("e.g. Juan Dela Cruz"),
),
const SizedBox(height: 16),
],

_buildLabel("Email Address"),
const SizedBox(height: 6),
TextField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
style: const TextStyle(fontSize: 13, color: stone800),
decoration: _inputDecoration("name@example.com"),
),
const SizedBox(height: 16),

_buildLabel("Password"),
const SizedBox(height: 6),
TextField(
controller: _passwordController,
obscureText: true,
style: const TextStyle(fontSize: 13, color: stone800),
decoration: _inputDecoration("••••••••"),
),
const SizedBox(height: 16),

if (!_isLogin) ...[
_buildLabel("Contact Number"),
const SizedBox(height: 6),
TextField(
controller: _contactController,
keyboardType: TextInputType.phone,
style: const TextStyle(fontSize: 13, color: stone800),
decoration: _inputDecoration("09123456789"),
),
const SizedBox(height: 16),

_buildLabel("Emergency Contact"),
const SizedBox(height: 6),
TextField(
controller: _emergencyController,
keyboardType: TextInputType.phone,
style: const TextStyle(fontSize: 13, color: stone800),
decoration: _inputDecoration("09987654321"),
),
const SizedBox(height: 16),

_buildLabel("Insurance Provider"),
const SizedBox(height: 6),
TextField(
controller: _insuranceController,
style: const TextStyle(fontSize: 13, color: stone800),
decoration: _inputDecoration("PhilHealth"),
),
const SizedBox(height: 16),
],

const SizedBox(height: 8),

SizedBox(
width: double.infinity,
height: 48,
child: ElevatedButton(
onPressed: _isLoading ? null : _submit,
style: ElevatedButton.styleFrom(
backgroundColor: emeraldDark,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8),
),
),
child: _isLoading
? const SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
"✦ ",
style: TextStyle(
color: Color(0xFFFBBF24),
fontSize: 12,
),
),
Text(
_isLogin ? 'Sign In' : 'Register Account',
style: const TextStyle(
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
),
const SizedBox(height: 20),

TextButton(
onPressed: () {
setState(() {
_isLogin = !_isLogin;
});
},
child: Text(
_isLogin
? "Don't have an account? Sign up"
    : 'Already have an account? Sign in',
style: const TextStyle(
fontSize: 12,
color: stone600,
fontWeight: FontWeight.w500,
),
),
),
],
),
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
color: Color(0xFF57534E),
),
);
}

InputDecoration _inputDecoration(String hint) {
return InputDecoration(
hintText: hint,
hintStyle: const TextStyle(color: Color(0xFFA8A29E), fontSize: 13),
contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
filled: true,
fillColor: Colors.white,
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
borderSide: const BorderSide(color: Color(0xFFD6D3D1)),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.5),
),
);
}
}
