import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'contact_us_screen.dart';
import 'about_me_screen.dart';
import '../../core/providers/theme_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFC107);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // Elegant header image
            Container(
              height: 320,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/more.svg',
                    fit: BoxFit.contain,
                    width: 600,
                    height: 500,
                  ),
                ),
              ),
            ),
            // Centered menu
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MoreMenuItem(
                      icon: Icons.phone,
                      label: 'تواصل معنا',
                      iconColor: yellow,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                      ),
                    ),
                    _MoreMenuItem(
                      icon: Icons.info,
                      label: 'اعرف عني',
                      iconColor: yellow,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutMeScreen()),
                      ),
                    ),
                    _MoreMenuItem(
                      icon: Icons.settings,
                      label: 'الإعدادات',
                      iconColor: yellow,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  const _MoreMenuItem({required this.icon, required this.label, required this.onTap, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final yellow = const Color(0xFFFFC107);
        
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('الإعدادات'),
              elevation: 1,
            ),
            body: Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.brightness_5, 
                            color: !themeProvider.isDarkMode ? yellow : Colors.grey, 
                            size: 32
                          ),
                          const SizedBox(width: 16),
                          const Text('الوضع الفاتح', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Radio<bool>(
                            value: false,
                            groupValue: themeProvider.isDarkMode,
                            activeColor: yellow,
                            onChanged: (val) {
                              themeProvider.setTheme(ThemeMode.light);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.dark_mode, 
                            color: themeProvider.isDarkMode ? yellow : Colors.grey, 
                            size: 32
                          ),
                          const SizedBox(width: 16),
                          const Text('الوضع الليلي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Radio<bool>(
                            value: true,
                            groupValue: themeProvider.isDarkMode,
                            activeColor: yellow,
                            onChanged: (val) {
                              themeProvider.setTheme(ThemeMode.dark);
                            },
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
      },
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: Text(
            'صفحة $title',
            style: const TextStyle(fontSize: 22, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
