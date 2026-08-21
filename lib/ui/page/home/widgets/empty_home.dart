import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'topo_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Empty
// ─────────────────────────────────────────────────────────────────────────────

class EmptyHome extends StatelessWidget {
  final VoidCallback onFindRoute;
  const EmptyHome({super.key, required this.onFindRoute});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: TopoBackground()),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: math.min(
                        MediaQuery.sizeOf(context).height * 0.34, 280),
                    child: const RouteSketchBox(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '这周去哪走？',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '选一条经典路线，首页展示路线封面、轨迹和天气。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CupertinoButton(
                    color: const Color(0xFFB6FF5C),
                    borderRadius: BorderRadius.circular(999),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 15),
                    onPressed: onFindRoute,
                    child: const Text(
                      '找一条路线',
                      style: TextStyle(
                        color: Color(0xFF07130F),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
