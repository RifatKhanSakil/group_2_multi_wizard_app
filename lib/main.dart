import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MultiStepWizardApp());
}

class MultiStepWizardApp extends StatelessWidget {
  const MultiStepWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi-Step Form Wizard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
      home: const FormWizardScreen(),
    );
  }
}

class FormWizardScreen extends StatefulWidget {
  const FormWizardScreen({super.key});

  @override
  State<FormWizardScreen> createState() => _FormWizardScreenState();
}

class _FormWizardScreenState extends State<FormWizardScreen> {
  int _currentStep = 0;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _enableNotifications = true;
  String _preferredTheme = 'Light';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_name', _nameController.text);
    await prefs.setString('draft_email', _emailController.text);
    await prefs.setString('draft_phone', _phoneController.text);
    await prefs.setString('draft_address', _addressController.text);
    await prefs.setBool('draft_notifications', _enableNotifications);
    await prefs.setString('draft_theme', _preferredTheme);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Draft saved successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('draft_name') ?? '';
      _emailController.text = prefs.getString('draft_email') ?? '';
      _phoneController.text = prefs.getString('draft_phone') ?? '';
      _addressController.text = prefs.getString('draft_address') ?? '';
      _enableNotifications = prefs.getBool('draft_notifications') ?? true;
      _preferredTheme = prefs.getString('draft_theme') ?? 'Light';
    });
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_name');
    await prefs.remove('draft_email');
    await prefs.remove('draft_phone');
    await prefs.remove('draft_address');
    await prefs.remove('draft_notifications');
    await prefs.remove('draft_theme');
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) return _step1Key.currentState!.validate();
    if (_currentStep == 1) return _step2Key.currentState!.validate();
    if (_currentStep == 2) return _step3Key.currentState!.validate();
    return true;
  }

  void _onStepContinue() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() => _currentStep += 1);
      } else {
        _clearDraft();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Color(0xFF6366F1), size: 28),
                SizedBox(width: 10),
                Text('Success!'),
              ],
            ),
            content: const Text(
              'Your multi-step form has been submitted successfully.',
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentStep = 0;
                    _nameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                    _addressController.clear();
                  });
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Multi-Step Form Wizard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: Color(0xFF6366F1),
            ),
            tooltip: 'Save Draft',
            onPressed: _saveDraft,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  onStepTapped: (step) {
                    if (step < _currentStep || _validateCurrentStep()) {
                      setState(() => _currentStep = step);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: details.onStepContinue,
                              child: Text(
                                _currentStep == 3
                                    ? 'Submit Application'
                                    : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: details.onStepCancel,
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    // Step 1: Personal
                    Step(
                      title: const Text(
                        'Personal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.editing,
                      content: SingleChildScrollView(
                        child: Form(
                          key: _step1Key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Please enter your legal name and contact email.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'John Doe',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                validator: (val) => (val == null || val.isEmpty)
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  hintText: 'john@example.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Please enter your email';
                                  if (!val.contains('@'))
                                    return 'Enter a valid email address';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Step 2: Contact
                    Step(
                      title: const Text(
                        'Contact',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.editing,
                      content: SingleChildScrollView(
                        child: Form(
                          key: _step2Key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Where can we reach you?',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  hintText: '+1 (555) 000-0000',
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                validator: (val) => (val == null || val.isEmpty)
                                    ? 'Please enter your phone number'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Street Address',
                                  hintText: '123 Main St, City, Country',
                                  prefixIcon: Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF6366F1),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                validator: (val) => (val == null || val.isEmpty)
                                    ? 'Please enter your address'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Step 3: Preferences
                    Step(
                      title: const Text(
                        'Preferences',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2
                          ? StepState.complete
                          : StepState.editing,
                      content: SingleChildScrollView(
                        child: Form(
                          key: _step3Key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'App Preferences',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Customize your app notification and theme settings.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: SwitchListTile(
                                  title: const Text(
                                    'Enable Notifications',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Receive push alerts and updates',
                                  ),
                                  value: _enableNotifications,
                                  activeColor: const Color(0xFF6366F1),
                                  onChanged: (val) => setState(
                                    () => _enableNotifications = val,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _preferredTheme,
                                decoration: const InputDecoration(
                                  labelText: 'Theme Preference',
                                  prefixIcon: Icon(
                                    Icons.palette_outlined,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                items: ['Light', 'Dark', 'System'].map((theme) {
                                  return DropdownMenuItem(
                                    value: theme,
                                    child: Text(theme),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _preferredTheme = val!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Step 4: Review
                    Step(
                      title: const Text(
                        'Review',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      isActive: _currentStep >= 3,
                      state: StepState.editing,
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Review Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Confirm your details before submitting.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildReviewRow(
                                    'Full Name',
                                    _nameController.text,
                                    Icons.person,
                                  ),
                                  const Divider(height: 24),
                                  _buildReviewRow(
                                    'Email Address',
                                    _emailController.text,
                                    Icons.email,
                                  ),
                                  const Divider(height: 24),
                                  _buildReviewRow(
                                    'Phone Number',
                                    _phoneController.text,
                                    Icons.phone,
                                  ),
                                  const Divider(height: 24),
                                  _buildReviewRow(
                                    'Address',
                                    _addressController.text,
                                    Icons.location_on,
                                  ),
                                  const Divider(height: 24),
                                  _buildReviewRow(
                                    'Notifications',
                                    _enableNotifications
                                        ? 'Enabled'
                                        : 'Disabled',
                                    Icons.notifications,
                                  ),
                                  const Divider(height: 24),
                                  _buildReviewRow(
                                    'Theme',
                                    _preferredTheme,
                                    Icons.palette,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'N/A' : value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
