import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '', _email = '', _skin = '', _hair = '', _gender = '', _allergies = '', _conditions = '', _cycle = '', _apiKey = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name = p.getString('user_name') ?? '';
      _email = p.getString('user_email') ?? '';
      _skin = p.getString('skin_type') ?? '';
      _hair = p.getString('hair_type') ?? '';
      _gender = p.getString('gender') ?? '';
      _allergies = p.getString('allergies') ?? '';
      _conditions = p.getString('conditions') ?? '';
      _cycle = p.getString('cycle_info') ?? '';
      _apiKey = p.getString('api_key') ?? '';
    });
  }

  Future<void> _logout() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('is_logged_in', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _showApiKeyDialog() {
    final ctrl = TextEditingController(text: _apiKey);
    bool obscure = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('API Key', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 17, fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Enter your Grok (xAI) API key.\nGet it from console.x.ai', style: TextStyle(color: Color(0xFF666666), fontSize: 13, height: 1.5)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              obscureText: obscure,
              style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'xai-...',
                hintStyle: const TextStyle(color: Color(0xFF444444)),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF555555), size: 18),
                  onPressed: () => setDialogState(() => obscure = !obscure),
                ),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF555555)))),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('api_key', ctrl.text.trim());
                setState(() => _apiKey = ctrl.text.trim());
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('API key saved!'),
                  backgroundColor: const Color(0xFF0D2B1A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())).then((_) => _load()),
            child: const Text('Edit', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w600)),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(child: Text(_name.isNotEmpty ? _name[0].toUpperCase() : 'C', style: const TextStyle(color: Color(0xFF0A0A0A), fontSize: 34, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 14),
          Text(_name, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_email, style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
          const SizedBox(height: 28),

          _section('PERSONAL', [
            if (_gender.isNotEmpty) _row(Icons.person_outline_rounded, 'Gender', _gender),
            if (_skin.isNotEmpty) _row(Icons.face_outlined, 'Skin type', _skin),
            if (_hair.isNotEmpty) _row(Icons.dry_outlined, 'Hair type', _hair),
          ]),

          const SizedBox(height: 14),
          _section('HEALTH', [
            _row(Icons.warning_amber_outlined, 'Allergies', _allergies.isNotEmpty ? _allergies : 'None listed'),
            _row(Icons.medical_information_outlined, 'Conditions', _conditions.isNotEmpty ? _conditions : 'None listed'),
            if (_cycle.isNotEmpty) _row(Icons.calendar_month_outlined, 'Cycle phase', _cycle),
          ]),

          const SizedBox(height: 14),
          // API Key section
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI SETTINGS', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showApiKeyDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _apiKey.isNotEmpty ? const Color(0xFFC9A84C).withOpacity(0.3) : const Color(0xFF2A2A2A)),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _apiKey.isNotEmpty ? const Color(0xFF1C1507) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _apiKey.isNotEmpty ? const Color(0xFFC9A84C).withOpacity(0.4) : const Color(0xFF2A2A2A)),
                    ),
                    child: Icon(Icons.key_rounded, color: _apiKey.isNotEmpty ? const Color(0xFFC9A84C) : const Color(0xFF555555), size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Grok API Key', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      _apiKey.isNotEmpty ? '${_apiKey.substring(0, 8)}••••••••••••••••' : 'Tap to add API key',
                      style: TextStyle(color: _apiKey.isNotEmpty ? const Color(0xFF4ADE80) : const Color(0xFF555555), fontSize: 12),
                    ),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: const Color(0xFF444444), size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Get your API key from console.x.ai — works with Grok 3', style: TextStyle(color: Color(0xFF444444), fontSize: 11)),
            ),
          ]),

          const SizedBox(height: 28),
          GestureDetector(
            onTap: _logout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B0A0A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF991B1B).withOpacity(0.4)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 18),
                SizedBox(width: 8),
                Text('Sign out', style: TextStyle(color: Color(0xFFF87171), fontSize: 15, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          const Text('CareShare AI v2.0', style: TextStyle(color: Color(0xFF333333), fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Column(children: rows.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < rows.length - 1) const Divider(color: Color(0xFF1E1E1E), height: 1, indent: 48),
        ])).toList()),
      ),
    ]);
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF555555), size: 18),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}