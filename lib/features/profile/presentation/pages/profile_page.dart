import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/features/onboarding/onboarding_page.dart';
import 'package:funswap/features/profile/presentation/pages/settings_page.dart';
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/services/preferences_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isDarkMode = PreferencesService.getDarkMode();
      _selectedLanguage = PreferencesService.getLanguage();
      appThemeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _updateConfig({bool? darkMode, String? language}) async {
    if (darkMode != null) {
      await PreferencesService.setDarkMode(darkMode);
    }
    if (language != null) {
      await PreferencesService.setLanguage(language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('profile_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Card (Avatar + Name)
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            // Premium Card
            _buildPremiumCard(),
            
            const SizedBox(height: 28),
            
            // Options List
            _buildOptionItem(
              icon: Icons.person_outline_rounded,
              title: 'profile_account'.tr,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('profile_account_demo'.tr)),
                );
              },
            ),
            
            _buildOptionItem(
              icon: Icons.language_rounded,
              title: 'profile_language'.tr,
              trailingText: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
            ),
            
            _buildOptionItem(
              icon: Icons.dark_mode_outlined,
              title: 'profile_dark_mode'.tr,
              trailing: Switch(
                value: _isDarkMode,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                    appThemeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  });
                  _updateConfig(darkMode: value);
                },
              ),
            ),
            
            _buildOptionItem(
              icon: Icons.help_outline_rounded,
              title: 'profile_help'.tr,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help Center: support@funswap.app')),
                );
              },
            ),
            
            _buildOptionItem(
              icon: Icons.rate_review_outlined,
              title: 'profile_feedback'.tr,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('profile_feedback_demo'.tr)),
                );
              },
            ),
            
            _buildOptionItem(
              icon: Icons.info_outline_rounded,
              title: 'profile_about'.tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingPage()),
                );
              },
            ),
            
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Avatar with beautiful borders
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'AE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abdulloh Ergashev',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'abdulloh@example.com',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B4CFB), Color(0xFF7F3DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'profile_premium_title'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'profile_premium_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('profile_premium_active'.tr)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'profile_premium_get'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.4), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 14,
                ),
              ],
            ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('select_language'.tr),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(LocalizationService.keyUz),
              _buildLanguageOption(LocalizationService.keyEn),
              _buildLanguageOption(LocalizationService.keyRu),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String lang) {
    final isSelected = _selectedLanguage == lang;
    return ListTile(
      title: Text(
        lang,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = lang;
        });
        _updateConfig(language: lang);
        LocalizationService.updateLanguage(lang); // Trigger dynamic update
        Navigator.pop(context);
      },
    );
  }
}
