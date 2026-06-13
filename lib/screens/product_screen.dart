import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String _result = '', _product = '';

  final _popular = [
    'Minimalist Niacinamide 10%', 'Dot & Key Vitamin C Serum',
    'Mamaearth Onion Hair Oil', 'Plum Green Tea Toner',
    'WOW Apple Cider Vinegar Shampoo', 'mCaffeine Coffee Face Scrub',
    'Re\'equil Oily Skin Sunscreen', 'Aqualogica Glow+ Moisturiser',
  ];

  Future<void> _analyze(String product) async {
    if (product.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _result = ''; _product = product; });
    try {
      final r = await GeminiService.analyzeProduct(product);
      setState(() { _result = r; _loading = false; });
    } catch (_) {
      setState(() { _result = 'Error analysing product. Please check your API key.'; _loading = false; });
    }
  }

  String _compatibilityLabel(String result) {
    final lower = result.toLowerCase();
    if (lower.contains('avoid')) return 'avoid';
    if (lower.contains('caution')) return 'caution';
    return 'safe';
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Product checker'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Color(0xFFF0EDE6)),
                decoration: InputDecoration(
                  hintText: 'Type any product name...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF555555), size: 20),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded, color: Color(0xFF555555), size: 18), onPressed: () { _ctrl.clear(); setState(() {}); })
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: _analyze,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _analyze(_ctrl.text),
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0A0A0A), size: 22),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          if (_loading) ...[
            const SizedBox(height: 40),
            Center(child: Column(children: [
              const CircularProgressIndicator(color: Color(0xFFC9A84C), strokeWidth: 2),
              const SizedBox(height: 16),
              Text('Analysing "$_product"...', style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
              const SizedBox(height: 6),
              const Text('Checking against your profile', style: TextStyle(color: Color(0xFF444444), fontSize: 12)),
            ])),
          ] else if (_result.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: const Text('🧴', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_product, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    _compatBadge(_compatibilityLabel(_result)),
                  ])),
                ]),
                const Divider(color: Color(0xFF1E1E1E), height: 20),
                Text(_result, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 13, height: 1.7)),
              ]),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => setState(() { _result = ''; _ctrl.clear(); }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.refresh_rounded, color: Color(0xFF666666), size: 16),
                  SizedBox(width: 8),
                  Text('Check another product', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                ]),
              ),
            ),
          ] else ...[
            const Text('POPULAR IN INDIA', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _popular.map((p) => GestureDetector(
                onTap: () { _ctrl.text = p; _analyze(p); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Text(p, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('HOW IT WORKS', style: TextStyle(color: Color(0xFF555555), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 12),
                ...[
                  ('🔍', 'Type or tap any Indian product name'),
                  ('🤖', 'AI analyses ingredients vs your profile'),
                  ('⚠️', 'Get Safe / Caution / Avoid rating'),
                  ('💡', 'Receive personalised alternatives'),
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Text(item.$1, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.$2, style: const TextStyle(color: Color(0xFF666666), fontSize: 12))),
                  ]),
                )),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _compatBadge(String level) {
    final configs = {
      'safe': (const Color(0xFF0D2B1A), const Color(0xFF4ADE80), '✓ Safe for you'),
      'caution': (const Color(0xFF2B1F0A), const Color(0xFFFCD34D), '⚠ Use with caution'),
      'avoid': (const Color(0xFF2B0A0A), const Color(0xFFF87171), '✕ Avoid'),
    };
    final c = configs[level]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.$1, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.$2.withOpacity(0.4))),
      child: Text(c.$3, style: TextStyle(color: c.$2, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}