import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/services/preferences_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  String _storageLocation = 'internal'; // 'internal' or 'sd'
  String _autoDelete = '7d'; // 'never', '1d', '7d', '30d'
  double _cacheSize = 45.3;

  @override
  void initState() {
    super.initState();
    _notifications = PreferencesService.getNotifications();
    _storageLocation = PreferencesService.getStorageLocation();
    _autoDelete = PreferencesService.getAutoDelete();
  }

  String _getStorageLabel(String value) {
    if (value == 'internal') return 'settings_storage_internal'.tr;
    if (value == 'sd') return 'settings_storage_sd'.tr;
    return value;
  }

  String _getAutoDeleteLabel(String value) {
    if (value == 'never') return 'settings_delete_never'.tr;
    if (value == '1d') return 'settings_delete_1d'.tr;
    if (value == '7d') return 'settings_delete_7d'.tr;
    if (value == '30d') return 'settings_delete_30d'.tr;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('settings_title'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Section 1: Umumiylar
            Text(
              'settings_general'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingItem(
              icon: Icons.notifications_none_rounded,
              title: 'settings_notifications'.tr,
              trailing: Switch(
                value: _notifications,
                activeColor: AppColors.primary,
                onChanged: (value) async {
                  setState(() {
                    _notifications = value;
                  });
                  await PreferencesService.setNotifications(value);
                },
              ),
            ),
            
            _buildSettingItem(
              icon: Icons.storage_rounded,
              title: 'settings_storage'.tr,
              trailingText: _getStorageLabel(_storageLocation),
              onTap: () => _showStorageDialog(),
            ),
            
            _buildSettingItem(
              icon: Icons.auto_delete_outlined,
              title: 'settings_auto_delete'.tr,
              trailingText: _getAutoDeleteLabel(_autoDelete),
              onTap: () => _showAutoDeleteDialog(),
            ),
            
            const SizedBox(height: 28),
            
            // Section 2: Boshqalar
            Text(
              'settings_other'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingItem(
              icon: Icons.cleaning_services_outlined,
              title: 'settings_cache'.tr,
              trailingText: '${_cacheSize.toStringAsFixed(1)} MB',
              onTap: () {
                setState(() {
                  _cacheSize = 0.0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('settings_cache_cleared'.tr)),
                );
              },
            ),
            
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'settings_privacy'.tr,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy: www.funswap.app/privacy')),
                );
              },
            ),
            
            _buildSettingItem(
              icon: Icons.gavel_rounded,
              title: 'settings_terms'.tr,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of Use: www.funswap.app/terms')),
                );
              },
            ),
            
            _buildSettingItem(
              icon: Icons.delete_forever_rounded,
              title: 'settings_delete_account'.tr,
              textColor: AppColors.accentRed,
              iconColor: AppColors.accentRed,
              onTap: () => _showDeleteAccountDialog(),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
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
          child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.white,
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

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('settings_storage_title'.tr),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('settings_storage_internal'.tr),
                trailing: _storageLocation == 'internal' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () async {
                  setState(() => _storageLocation = 'internal');
                  await PreferencesService.setStorageLocation('internal');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('settings_storage_sd'.tr),
                trailing: _storageLocation == 'sd' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () async {
                  setState(() => _storageLocation = 'sd');
                  await PreferencesService.setStorageLocation('sd');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAutoDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('settings_auto_delete_title'.tr),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDeleteOption('never'),
              _buildDeleteOption('1d'),
              _buildDeleteOption('7d'),
              _buildDeleteOption('30d'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeleteOption(String value) {
    final isSelected = _autoDelete == value;
    return ListTile(
      title: Text(_getAutoDeleteLabel(value)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () async {
        setState(() => _autoDelete = value);
        await PreferencesService.setAutoDelete(value);
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('settings_delete_confirm_title'.tr, style: const TextStyle(color: AppColors.accentRed)),
          content: Text('settings_delete_confirm_desc'.tr),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('account_deleted'.tr)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
              child: Text('delete'.tr),
            ),
          ],
        );
      },
    );
  }
}
