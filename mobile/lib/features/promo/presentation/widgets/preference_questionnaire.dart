import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferenceQuestionnaire extends StatelessWidget {
  final Function(String preference) onPreferenceSelected;
  final bool isLoading;
  final String? selectedPreference;

  const PreferenceQuestionnaire({
    super.key,
    required this.onPreferenceSelected,
    this.isLoading = false,
    this.selectedPreference,
  });

  static const List<_PreferenceOption> _options = [
    _PreferenceOption('Streaming', Color(0xFFEF4444), Icons.movie),
    _PreferenceOption('Gaming', Color(0xFFFF7D00), Icons.gamepad),
    _PreferenceOption('Voice', Color(0xFF5C3E94), Icons.call),
    _PreferenceOption('Hemat', Color(0xFF060771), Icons.savings),
    _PreferenceOption('Travel', Color(0xFFF1C40F), Icons.flight),
    _PreferenceOption('Social', Color(0xFF4E56C0), Icons.people),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: const Color(0xFFFF7D00).withValues(alpha: 0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Bantu Kami Mengenalmu',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E3B3B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apa yang paling penting bagi Anda dalam memilih paket data?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // yang grid itu lah
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: _options.map((option) {
              final isSelected = selectedPreference == option.name;
              final isCurrentlyLoading = isLoading && isSelected;

              return GestureDetector(
                onTap: isLoading ? null : () => onPreferenceSelected(option.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? option.color
                        : option.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: option.color,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: option.color.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCurrentlyLoading)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isSelected ? Colors.white : option.color,
                          ),
                        )
                      else
                        Icon(
                          option.icon,
                          size: 28,
                          color: isSelected ? Colors.white : option.color,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        option.name,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : option.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih preferensi untuk mendapatkan rekomendasi AI',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[400],
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

  const _PreferenceOption(this.name, this.color, this.icon);
}
