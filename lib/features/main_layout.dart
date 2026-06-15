import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/features/home/presentation/pages/home_page.dart';
import 'package:funswap/features/files/presentation/pages/my_files_page.dart';
import 'package:funswap/features/favorites/presentation/pages/favorites_page.dart';
import 'package:funswap/features/profile/presentation/pages/profile_page.dart';
import 'package:funswap/features/conversion/presentation/pages/conversion_page.dart';

import 'package:funswap/core/services/localization_service.dart';

class MainLayout extends StatefulWidget {
  final int initialTab;
  const MainLayout({super.key, this.initialTab = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void setTab(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(onTabChange: setTab),
      MyFilesPage(onTabChange: setTab),
      const FavoritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentTab,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConversionPage(),
            ),
          ).then((value) {
            // Refresh current state if needed
            setState(() {});
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 8,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side tabs
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: Icons.home_filled,
                    label: 'tab_home'.tr,
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.folder,
                    label: 'tab_files'.tr,
                  ),
                ],
              ),
              
              // Right side tabs
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTabItem(
                    index: 2,
                    icon: Icons.star_rounded,
                    label: 'tab_favorites'.tr,
                  ),
                  _buildTabItem(
                    index: 3,
                    icon: Icons.person_rounded,
                    label: 'tab_profile'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentTab == index;
    return MaterialButton(
      minWidth: 80,
      onPressed: () => setTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
