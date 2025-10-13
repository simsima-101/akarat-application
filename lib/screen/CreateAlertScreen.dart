import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateAlertScreen extends StatefulWidget {
  final String initialPurpose;
  final String initialPropertyType;
  final List<String> availablePropertyTypes;

  const CreateAlertScreen({
    super.key,
    required this.initialPurpose,
    required this.initialPropertyType,
    required this.availablePropertyTypes,
  });

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  Future<void> _save() async {
    // Validate the form first (only if you used _formKey on your Form)
    if (!_formKey.currentState!.validate()) return;

    // Collect the values (adjust names if yours differ)
    final alertName     = _nameCtrl.text.trim();
    final timePeriod    = _timePeriod;
    final purpose       = _purpose;
    final propertyType  = _propertyType;

    // TODO: call your API here with the values above.

    // Feedback + close
    if (!mounted) return;

    final controller = ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert saved'),
        duration: Duration(milliseconds: 1600), // <- shorter
      ),
    );

// wait until the snackbar finishes, then pop
    await controller.closed;
    if (!mounted) return;
    Navigator.pop(context, true);

  }


  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
    );
  }


  late String _timePeriod;
  late String _purpose;
  late String _propertyType;
  late List<String> _types;

  final _timePeriods = const ['Hourly', 'Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _timePeriod = _timePeriods.first;
    _purpose = widget.initialPurpose;

    // dedupe + sanitize types
    _types = widget.availablePropertyTypes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (_types.isEmpty) _types = ['Apartment'];

    final raw = widget.initialPropertyType.trim();
    _propertyType = (raw.isEmpty ||
        raw.toLowerCase() == 'all residential' ||
        !_types.contains(raw))
        ? _types.first
        : raw;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // page bg
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFFE0E0), // soft pink background
                    Color(0xFFFFFFFF), // white
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    right: -6,
                    top: -8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Form content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Create Alert',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alert Name', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: _dec('Alert Name'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                            ),
                            const SizedBox(height: 16),

                            const Text('Time Period', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _timePeriod,
                              decoration: _dec(''),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _timePeriods
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _timePeriod = v ?? _timePeriod),
                            ),
                            const SizedBox(height: 16),

                            const Text('Purpose', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _purpose,
                              decoration: _dec(''),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: const ['Rent', 'Buy', 'New Projects', 'Commercial']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _purpose = v ?? _purpose),
                            ),
                            const SizedBox(height: 16),

                            const Text('Property Type', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _propertyType,
                              decoration: _dec(''),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: widget.availablePropertyTypes
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _propertyType = v ?? _propertyType),
                            ),
                          ],
                        ),
                      ),



                      const SizedBox(height: 24),

                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: _pillButton(
                              label: 'Cancel',
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _pillButton(
                              label: 'Save Alert',
                              onTap: _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFF6B6B), // deeper red on left
                Color(0xFFFF8A8A), // lighter red on right
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
