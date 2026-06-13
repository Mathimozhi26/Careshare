import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    if (_isLogin) {
      final savedEmail = prefs.getString('user_email') ?? '';
      final savedPass = prefs.getString('user_password') ?? '';
      if (_emailCtrl.text.trim() == savedEmail && _passCtrl.text == savedPass) {
        await prefs.setBool('is_logged_in', true);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Invalid credentials'),
          backgroundColor: const Color(0xFF2B0A0A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } else {
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('user_email', _emailCtrl.text.trim());
      await prefs.setString('user_password', _passCtrl.text);
      await prefs.setBool('is_logged_in', true);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
                  ),
                  child: const Center(child: Text('✦', style: TextStyle(fontSize: 26, color: Color(0xFFC9A84C)))),
                ),
                const SizedBox(height: 28),
                Text(
                  _isLogin ? 'Welcome back' : 'Create account',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFF0EDE6), letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin ? 'Sign in to your CareShare AI account' : 'Start your skincare journey',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
                const SizedBox(height: 36),
                if (!_isLogin) ...[
                  _buildField(_nameCtrl, 'Full name', Icons.person_outline, validator: (v) => v!.isEmpty ? 'Enter name' : null),
                  const SizedBox(height: 14),
                ],
                _buildField(_emailCtrl, 'Email address', Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? 'Enter valid email' : null),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: Color(0xFFF0EDE6)),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF555555), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF555555), size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 32),
                _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C), strokeWidth: 2))
                    : ElevatedButton(onPressed: _submit, child: Text(_isLogin ? 'Sign in' : 'Create account')),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? "Don't have an account?  " : 'Already have an account?  ',
                        style: const TextStyle(color: Color(0xFF555555), fontSize: 14),
                        children: [TextSpan(text: _isLogin ? 'Sign up' : 'Sign in', style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w600))],
                      ),
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

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFFF0EDE6)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF555555), size: 20),
      ),
      validator: validator,
    );
  }
}