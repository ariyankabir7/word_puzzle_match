import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TelegramBannerWidget extends StatefulWidget {
  const TelegramBannerWidget({super.key});

  @override
  State<TelegramBannerWidget> createState() => _TelegramBannerWidgetState();
}

class _TelegramBannerWidgetState extends State<TelegramBannerWidget> {
  String _imgLink = '';
  String _targetLink = '';

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _imgLink = prefs.getString('telegram_img_link') ?? '';
      _targetLink = prefs.getString('telegram_link') ?? '';
    });
  }

  Future<void> _launchTelegram() async {
    if (_targetLink.isEmpty) return;
    final uri = Uri.parse(_targetLink);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_targetLink.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _launchTelegram,
          child: _imgLink.isNotEmpty
              ? Image.network(
                  _imgLink,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackBanner(),
                )
              : _buildFallbackBanner(),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF229ED9), Color(0xFF0088CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.telegram_rounded, color: Colors.white, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Our Telegram Channel!',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get daily hints, secret level updates & cash rewards!',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}
