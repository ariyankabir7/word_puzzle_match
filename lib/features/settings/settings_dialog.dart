import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/app_providers.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  late bool soundEnabled;
  late bool musicEnabled;
  late bool hapticEnabled;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    soundEnabled = storage.getSoundEnabled();
    musicEnabled = storage.getMusicEnabled();
    hapticEnabled = storage.getHapticEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(storageServiceProvider);
    final audio = ref.read(audioServiceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(AppImages.gear, width: 32, height: 32),
                    const SizedBox(width: 10),
                    Text('Settings', style: AppTextStyles.headingMedium),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),

            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded, color: AppColors.skyBlue),
              title: Text('Sound Effects', style: AppTextStyles.bodyLarge),
              value: soundEnabled,
              activeThumbColor: AppColors.lushGreen,
              onChanged: (val) {
                setState(() => soundEnabled = val);
                storage.setSoundEnabled(val);
                audio.updateSettings(sound: val, music: musicEnabled);
                if (val) audio.playButtonTap();
              },
            ),

            SwitchListTile(
              secondary: const Icon(Icons.music_note_rounded, color: AppColors.softPurple),
              title: Text('Background Music', style: AppTextStyles.bodyLarge),
              value: musicEnabled,
              activeThumbColor: AppColors.lushGreen,
              onChanged: (val) {
                setState(() => musicEnabled = val);
                storage.setMusicEnabled(val);
                audio.updateSettings(sound: soundEnabled, music: val);
                if (val) {
                  audio.playMusic('audio/bg_music.mp3');
                } else {
                  audio.stopMusic();
                }
              },
            ),

            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded, color: AppColors.sunshineYellow),
              title: Text('Haptic Vibration', style: AppTextStyles.bodyLarge),
              value: hapticEnabled,
              activeThumbColor: AppColors.lushGreen,
              onChanged: (val) {
                setState(() => hapticEnabled = val);
                storage.setHapticEnabled(val);
                if (val) {
                  ref.read(hapticsServiceProvider).selectionClick();
                }
              },
            ),

            const SizedBox(height: 12),
            const Divider(),

            TextButton.icon(
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.restore_rounded, color: Colors.redAccent),
              label: const Text(
                'Reset Progress',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Word Puzzle Match v1.1.0\n100% Offline Game Engine',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'Are you sure you want to reset all levels, stars, coins, and power-ups? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(playerProgressProvider.notifier).resetProgress();
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game progress reset to level 1.')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
