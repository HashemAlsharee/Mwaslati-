import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

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
    final green = const Color(0xFF4CAF50);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'اعرف عنا',
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
                
                // Developer Image
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
                      child: Image.asset(
                        'assets/images/hashem.jpg',
                        fit: BoxFit.cover,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Main content
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
                  child: Column(
                    children: [
                      // Title
                      const Text(
                        ' عن المطوّر ''👨‍💻',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Main paragraph
                      const Text(
                        'مرحبًا، أنا هاشم عصام الشرعي، مطوّر تطبيق "مواصلاتي".\n\n'
                        'قمت بتصميم وتطوير هذا التطبيق بهدف تسهيل التنقّل داخل الشوارع اليمنية عبر توفير وسيلة ذكية لعرض خطوط الباصات والمساعدة في تخطيط الرحلات اليومية.\n\n'
                        'أؤمن أن التكنولوجيا يمكن أن تصنع فرقًا حقيقيًا في حياتنا اليومية، ولهذا حرصت على أن يكون التطبيق بسيطًا، عمليًا، ومتاحًا للجميع.\n\n'
                        'شكرًا لاستخدامك مواصلاتي 🤝',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Subtitle
                const Text(
                  'يمكنك دعمي ومتابعتي عبر مواقع التواصل الاجتماعي',
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
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            iconPath,
            width: 48,
            height: 68,
          ),
        ),
      ),
    );
  }
} 