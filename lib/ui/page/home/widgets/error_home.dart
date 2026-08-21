import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'topo_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class ErrorHome extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onChange;
  const ErrorHome({super.key, required this.onRetry, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: TopoBackground()),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.exclamationmark_triangle,
                      color: Color(0xFFB6FF5C), size: 42),
                  const SizedBox(height: 18),
                  const Text('当前路线加载失败',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text('可以重试，或者换一条路线。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 15)),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        onPressed: onRetry,
                        child: const Text('重试',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      CupertinoButton(
                        color: const Color(0xFFB6FF5C),
                        borderRadius: BorderRadius.circular(999),
                        onPressed: onChange,
                        child: const Text('更换路线',
                            style: TextStyle(
                                color: Color(0xFF07130F),
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
