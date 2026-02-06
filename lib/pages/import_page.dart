import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../providers/providers.dart';

class ImportPage extends ConsumerWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(importStateProvider);
    final error = ref.watch(importErrorProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                _buildLogo().animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                const SizedBox(height: 48),
                _buildDropZone(context, ref, importState, error)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 32),
                _buildPrivacyNote()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms),
                const Spacer(),
                _buildHowToExport(context)
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.analytics_outlined,
            size: 48,
            color: AppColors.background,
          ),
        ),
        const SizedBox(height: 24),
        GradientText(
          text: 'WhatStat',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'WhatsApp Chat Analyzer',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone(
    BuildContext context,
    WidgetRef ref,
    ImportState state,
    String? error,
  ) {
    final isLoading = state == ImportState.picking || state == ImportState.parsing;
    
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderColor: error != null 
          ? AppColors.error.withOpacity(0.5)
          : AppColors.primary.withOpacity(0.3),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLoading ? Icons.hourglass_top : Icons.upload_file,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isLoading 
                ? (state == ImportState.picking ? 'Selecting file...' : 'Analyzing your chat...')
                : 'Import WhatsApp Chat',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your chat from WhatsApp and select the .txt file',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          NeonButton(
            label: isLoading ? 'Processing...' : 'Choose File',
            icon: Icons.folder_open,
            onPressed: () => importChatFile(ref),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock,
            size: 16,
            color: AppColors.neonGreen,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '100% Private • All analysis happens on your device',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHowToExport(BuildContext context) {
    return TextButton(
      onPressed: () => _showExportInstructions(context),
      child: Text(
        'How to export WhatsApp chat?',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showExportInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How to Export WhatsApp Chat',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep('1', 'Open the chat you want to analyze'),
            _buildStep('2', 'Tap the menu (⋮) → More → Export chat'),
            _buildStep('3', 'Choose "Without media" for faster export'),
            _buildStep('4', 'Save the .txt file and import it here'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
