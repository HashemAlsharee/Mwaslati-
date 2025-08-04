import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFC107);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'تواصل معنا',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Contact SVG Image
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: SvgPicture.asset(
                        'assets/images/contact.svg',
                        fit: BoxFit.cover,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Main paragraph
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'نحن دائمًا سعداء بسماع آرائك وملاحظاتك!\nسواء كنت تواجه مشكلة في التطبيق، لديك اقتراح لتحسين الخدمة، أو ترغب في التواصل معنا لسبب آخر، لا تتردد!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Subtitle
                const Text(
                  'تابع مواصلاتي على وسائل التواصل الاجتماعي لمعرفة كل ماهو جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Social Media Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialMediaButton(
                      iconPath: 'assets/icons/whatsapp.png',
                      color: const Color(0xFF25D366),
                      onTap: () => _launchURL('https://wa.me/967772792995'),
                    ),
                    _SocialMediaButton(
                      iconPath: 'assets/icons/facebook.png',
                      color: const Color(0xFF1877F2),
                      onTap: () => _launchURL('https://www.facebook.com/H.ALsharee'),
                    ),
                    _SocialMediaButton(
                      iconPath: 'assets/icons/instagram.png',
                      color: const Color(0xFFE4405F),
                      onTap: () => _launchURL('https://www.instagram.com/mr.has7em'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialMediaButton extends StatelessWidget {
  final String iconPath;
  final Color color;
  final VoidCallback onTap;

  const _SocialMediaButton({
    required this.iconPath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            iconPath,
            width: 70,
            height: 55,
          ),
        ),
      ),
    );
  }
} 