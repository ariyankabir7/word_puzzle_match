import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_providers.dart';

class DailyRewardsDialog extends ConsumerWidget {
  const DailyRewardsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DailyRewardsDialog(),
    );
  }

  static const List<Map<String, dynamic>> daysRewards = [
    {'day': 1, 'reward': '50 Coins', 'icon': '🪙', 'coins': 50, 'gems': 0, 'hints': 0, 'shuffles': 0},
    {'day': 2, 'reward': '100 Coins', 'icon': '🪙', 'coins': 100, 'gems': 0, 'hints': 0, 'shuffles': 0},
    {'day': 3, 'reward': '2 Hints', 'icon': '💡', 'coins': 0, 'gems': 0, 'hints': 2, 'shuffles': 0},
    {'day': 4, 'reward': '200 Coins', 'icon': '🪙', 'coins': 200, 'gems': 0, 'hints': 0, 'shuffles': 0},
    {'day': 5, 'reward': '10 Gems', 'icon': '💎', 'coins': 0, 'gems': 10, 'hints': 0, 'shuffles': 0},
    {'day': 6, 'reward': '300 Coins + 2 Shuffles', 'icon': '🔄', 'coins': 300, 'gems': 0, 'hints': 0, 'shuffles': 2},
    {'day': 7, 'reward': '25 Gems + Super Pack', 'icon': '🎁', 'coins': 500, 'gems': 25, 'hints': 3, 'shuffles': 3},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final notifier = ref.read(playerProgressProvider.notifier);

    final currentStreakDay = (progress.loginStreak == 0) ? 1 : ((progress.loginStreak - 1) % 7) + 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Rewards 🎁', style: AppTextStyles.headingMedium),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              'Log in daily to claim your streak rewards!',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final dayData = daysRewards[index];
                final dayNum = dayData['day'] as int;
                final isClaimed = progress.claimedDailyRewards.contains(dayNum);
                final isCurrent = dayNum == currentStreakDay && !isClaimed;

                return GestureDetector(
                  onTap: isCurrent
                      ? () {
                          final success = notifier.claimDailyReward(
                            dayNum,
                            dayData['coins'] as int,
                            dayData['gems'] as int,
                            dayData['hints'] as int,
                            dayData['shuffles'] as int,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Claimed Day $dayNum: ${dayData['reward']}!'),
                                backgroundColor: AppColors.lushGreen,
                              ),
                            );
                          }
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isClaimed
                          ? Colors.grey.shade200
                          : isCurrent
                              ? const Color(0xFFFFF7D6)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.sunshineYellow
                            : isClaimed
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                        width: isCurrent ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Day $dayNum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isClaimed ? Colors.grey : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dayData['icon'] as String, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          isClaimed ? 'Claimed' : (dayData['reward'] as String).split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isClaimed
                                ? Colors.grey
                                : isCurrent
                                    ? AppColors.lushGreen
                                    : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ).animate(target: isCurrent ? 1 : 0).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
