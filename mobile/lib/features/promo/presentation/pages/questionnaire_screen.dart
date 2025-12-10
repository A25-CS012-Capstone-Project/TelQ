import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_route.dart';
import '../../../../di/injection.dart';
import '../../domain/usecases/submit_cold_start.dart';
import '../../domain/usecases/trigger_pipeline.dart';
import '../../../auth/presentation/widgets/widget_bubble.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  String? _selectedPreference;
  bool _isLoading = false;

  static const List<_PreferenceOption> _options = [
    _PreferenceOption('Streaming', Color(0xFFEF4444), Icons.movie, 'Nonton film & video'),
    _PreferenceOption('Gaming', Color(0xFFFF7D00), Icons.gamepad, 'Main game online'),
    _PreferenceOption('Voice', Color(0xFF5C3E94), Icons.call, 'Telepon & video call'),
    _PreferenceOption('Hemat', Color(0xFF060771), Icons.savings, 'Kuota murah & efisien'),
    _PreferenceOption('Travel', Color(0xFFF1C40F), Icons.flight, 'Roaming & perjalanan'),
    _PreferenceOption('Social', Color(0xFF4E56C0), Icons.people, 'Media sosial & chat'),
  ];

  Future<void> _submitPreference() async {
    if (_selectedPreference == null) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');

      if (customerId == null) {
        _showError('Customer ID tidak ditemukan');
        return;
      }

      // Submit cold-start preference
      final submitColdStart = getIt<SubmitColdStart>();
      await submitColdStart.call(
        customerId: customerId,
        preference: _selectedPreference!,
      );

      // Trigger pipeline to generate recommendations
      final triggerPipeline = getIt<TriggerPipeline>();
      await triggerPipeline.call(customerId);

      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoute.home.path,
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: Stack(
        children: [
          // Background bubbles
          ...BubblePresets.standardSet(),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7D00), Color(0xFFFFA600)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7D00).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bantu Kami Mengenalmu',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3E3B3B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih preferensi utamamu untuk mendapatkan\nrekomendasi paket yang tepat',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Options Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        final isSelected = _selectedPreference == option.name;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              // Toggle selection
                              if (_selectedPreference == option.name) {
                                _selectedPreference = null;
                              } else {
                                _selectedPreference = option.name;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? option.color : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? option.color : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: option.color.withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    option.icon,
                                    size: 36,
                                    color: isSelected ? Colors.white : option.color,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    option.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : const Color(0xFF3E3B3B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.description,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: isSelected ? Colors.white70 : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Confirm Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedPreference == null || _isLoading
                              ? null
                              : _submitPreference,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7D00),
                            disabledBackgroundColor: Colors.grey[300],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _selectedPreference != null ? 8 : 0,
                            shadowColor: const Color(0xFFFF7D00).withValues(alpha: 0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _selectedPreference == null
                                      ? 'Pilih Preferensi'
                                      : 'Lanjutkan dengan $_selectedPreference',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kamu bisa mengubah preferensi kapan saja di profil',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceOption {
  final String name;
  final Color color;
  final IconData icon;
  final String description;

  const _PreferenceOption(this.name, this.color, this.icon, this.description);
}
