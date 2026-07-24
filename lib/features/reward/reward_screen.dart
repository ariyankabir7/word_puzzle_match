import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/services/api_service.dart';
import '../../shared/widgets/banner_ad_widget.dart';
import '../../shared/widgets/telegram_banner_widget.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  int _currentLevel = 1;
  int _targetLevel = 15;
  double _rewardAmount = 500.0;
  String _rewardCurrency = 'INR';
  String _rewardIconUrl = '';

  String _selectedMethod = 'upi'; // 'upi' or 'google_play'
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingHistory = false;
  List<ClaimRequestModel> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadPrefsData();
    _fetchHistoryData();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _currentLevel = prefs.getInt('current_level') ?? 1;
      _targetLevel = prefs.getInt('target_level') ?? 15;
      _rewardAmount = prefs.getDouble('reward_amount') ?? 500.0;
      _rewardCurrency = prefs.getString('reward_currency') ?? 'INR';
      _rewardIconUrl = prefs.getString('reward_icon_url') ?? '';
    });
  }

  Future<void> _fetchHistoryData() async {
    setState(() => _isLoadingHistory = true);
    final result = await ApiService().fetchHistory();
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = false;
      if (result.isSuccess && result.data != null) {
        _historyList = result.data!;
      }
    });
  }

  Future<void> _submitClaim() async {
    final details = _detailsController.text.trim();
    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedMethod == 'upi'
                ? 'Please enter a valid UPI ID (e.g. user@upi)'
                : 'Please enter a valid Phone or Email for Google Play Voucher',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ApiService().submitClaim(
      method: _selectedMethod,
      details: details,
      amount: _rewardAmount,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.isSuccess) {
      _detailsController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Claim submitted successfully! Claim ID: ${result.data}',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.lushGreen,
        ),
      );
      _fetchHistoryData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Failed to submit claim. Please try again.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = _currentLevel >= _targetLevel;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image matching game theme
          Positioned.fill(
            child: Image.asset(
              AppImages.bgHome,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Safe Area Content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textDark,
                            size: 20,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rewards & Withdrawals',
                        style: GoogleFonts.fredoka(
                          color: AppColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reward Banner & Level Progress Card
                        _buildProgressCard(isUnlocked),

                        const SizedBox(height: 20),

                        // Claim Input Box
                        _buildClaimBox(isUnlocked),

                        const SizedBox(height: 20),

                        // Telegram Join Banner
                        const TelegramBannerWidget(),

                        const SizedBox(height: 20),

                        // Withdrawal History Section
                        _buildHistorySection(),

                        const SizedBox(height: 20),

                        // Bottom Banner Ad
                        const Center(child: BannerAdWidget()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool isUnlocked) {
    final progressFraction = (_currentLevel / _targetLevel).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [const Color(0xFF059669), const Color(0xFF10B981)]
              : [AppColors.skyBlue, AppColors.skyBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked ? AppColors.sunshineYellow : Colors.white,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: _rewardIconUrl.isNotEmpty
                    ? Image.network(
                        _rewardIconUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.card_giftcard_rounded, color: AppColors.sunshineYellow, size: 34),
                      )
                    : const Icon(Icons.card_giftcard_rounded, color: AppColors.sunshineYellow, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${_rewardAmount.toInt()} $_rewardCurrency Reward',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked
                          ? '🎉 UNLOCKED! Claim your reward now!'
                          : 'Reach Level $_targetLevel to unlock cash claim',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked ? AppColors.sunshineYellow : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level Progress',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '$_currentLevel / $_targetLevel',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 12,
                  backgroundColor: Colors.black26,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked ? AppColors.sunshineYellow : AppColors.sunshineYellow,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildClaimBox(bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Withdrawal Method',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text('UPI ID', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  selected: _selectedMethod == 'upi',
                  selectedColor: AppColors.skyBlue,
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(
                    color: _selectedMethod == 'upi' ? AppColors.skyBlue : Colors.grey.shade300,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedMethod == 'upi' ? Colors.white : AppColors.textDark,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMethod = 'upi');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.confirmation_number_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text('Play Voucher', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  selected: _selectedMethod == 'google_play',
                  selectedColor: AppColors.skyBlue,
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(
                    color: _selectedMethod == 'google_play' ? AppColors.skyBlue : Colors.grey.shade300,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedMethod == 'google_play' ? Colors.white : AppColors.textDark,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMethod = 'google_play');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _detailsController,
            enabled: isUnlocked,
            style: GoogleFonts.nunito(color: AppColors.textDark, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: _selectedMethod == 'upi'
                  ? 'Enter UPI ID (e.g. name@upi)'
                  : 'Enter Mobile Number or Email ID',
              hintStyle: GoogleFonts.nunito(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (isUnlocked && !_isSubmitting) ? _submitClaim : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sunshineYellow,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: isUnlocked ? 4 : 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppColors.textDark, strokeWidth: 3),
                    )
                  : Text(
                      isUnlocked ? 'CLAIM REWARD NOW' : 'LOCKED (Reach Level $_targetLevel)',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? AppColors.textDark : Colors.grey.shade500,
                        letterSpacing: 1.1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Withdrawal History',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textMedium),
                onPressed: _fetchHistoryData,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppColors.skyBlue),
              ),
            )
          else if (_historyList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No previous withdrawal claims found.',
                  style: GoogleFonts.nunito(color: AppColors.textMedium, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historyList.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final item = _historyList[index];
                final statusColor = switch (item.status.toLowerCase()) {
                  'success' || 'approved' => Colors.green.shade700,
                  'pending' => Colors.amber.shade800,
                  _ => Colors.red.shade700,
                };

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.amount.toInt()} (${item.method.toUpperCase()})',
                        style: GoogleFonts.fredoka(
                          color: AppColors.textDark,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: GoogleFonts.fredoka(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Details: ${item.details}',
                        style: GoogleFonts.nunito(color: AppColors.textMedium, fontSize: 13),
                      ),
                      if (item.code != null)
                        Text(
                          'Voucher Code: ${item.code}',
                          style: GoogleFonts.nunito(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      if (item.note != null)
                        Text(
                          'Note: ${item.note}',
                          style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      Text(
                        item.date,
                        style: GoogleFonts.nunito(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
