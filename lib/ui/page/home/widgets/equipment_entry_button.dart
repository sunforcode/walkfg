import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Equipment module entry button
// ─────────────────────────────────────────────────────────────────────────────

class EquipmentEntryButton extends StatelessWidget {
  final VoidCallback onTap;

  const EquipmentEntryButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Icon(
          CupertinoIcons.bag,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
