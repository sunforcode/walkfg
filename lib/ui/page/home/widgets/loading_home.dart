import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'topo_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────────────────────

class LoadingHome extends StatelessWidget {
  const LoadingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: TopoBackground()),
        Center(child: CupertinoActivityIndicator(color: Colors.white)),
      ],
    );
  }
}
