import 'package:flutter/material.dart';
import '../utils/colors.dart';

class HolographicCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final bool isAlert;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const HolographicCard({
    super.key,
    required this.child,
    this.accentColor,
    this.isAlert = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isAlert ? AppColors.alertRed : (accentColor ?? AppColors.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.holographicGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF00000025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top-left corner glow
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 80,
                  height: 2,
                  color: borderColor.withOpacity(0.6),
                ),
              ),
              // Bottom glow line
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: borderColor.withOpacity(0.15),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class HolographicAlertCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HolographicAlertCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF2D1515), const Color(0xFF1A0A0A)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.alertRed.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.alertRed.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Red top accent
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: 3, color: AppColors.alertRed),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
