import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/motion.dart';

// ─────────────────────────────────────────────────────────────────────────────
// P1 首页-空状态 (PRD §3.1)
// ─────────────────────────────────────────────────────────────────────────────

class EmptyHome extends StatelessWidget {
  final VoidCallback? onFindRoute;
  final String ctaLabel;

  const EmptyHome({
    super.key,
    required this.onFindRoute,
    this.ctaLabel = '找路线',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1 — 首页空态渐变背景
        const Positioned.fill(child: _HomeGradientBackground()),
        // Layer 2 — 山峦剪影
        const Positioned.fill(child: _MountainSilhouette()),
        // Layer 3 — 品牌区 + CTA
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "WALK"
                  Text(
                    'WALK',
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // "徒步旅行助手"
                  Text(
                    '徒步旅行助手',
                    style: TextStyle(
                      color: AppColors.textWeak,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // "这周去哪徒步？"
                  Text(
                    '这周去哪徒步？',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // CTA 毛玻璃按钮
                  _GlassCtaButton(
                    label: ctaLabel,
                    onTap: onFindRoute,
                  ),
                  const SizedBox(height: 16),
                  // 空态提示
                  Text(
                    '还没有行程',
                    style: TextStyle(
                      color: AppColors.textWeak,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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

// ─────────────────────────────────────────────────────────────────────────────
// 首页空态渐变背景 (PRD --gradient-home: 170deg)
// ─────────────────────────────────────────────────────────────────────────────

class _HomeGradientBackground extends StatelessWidget {
  const _HomeGradientBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.gradientHome,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 山峦剪影 (PRD P1 Layer 2)
// 两层山形：前景 + 背景，底部 280px 区域
// ─────────────────────────────────────────────────────────────────────────────

class _MountainSilhouette extends StatelessWidget {
  const _MountainSilhouette();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MountainPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mountainHeight = 280.0;
    final baseY = size.height;

    // 背景层 — rgba(255,255,255,.02)
    final bgPaint = Paint()..color = const Color(0x05FFFFFF);
    final bgPath = Path()
      ..moveTo(0, baseY)
      ..lineTo(size.width * 0.213, baseY - mountainHeight * 0.429)
      ..lineTo(size.width * 0.373, baseY - mountainHeight * 0.321)
      ..lineTo(size.width * 0.587, baseY - mountainHeight * 0.750)
      ..lineTo(size.width * 0.800, baseY - mountainHeight * 0.464)
      ..lineTo(size.width, baseY - mountainHeight * 0.571)
      ..lineTo(size.width, baseY)
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // 前景层 — rgba(255,255,255,.04)
    final fgPaint = Paint()..color = const Color(0x0AFFFFFF);
    final fgPath = Path()
      ..moveTo(0, baseY)
      ..lineTo(size.width * 0.160, baseY - mountainHeight * 0.571)
      ..lineTo(size.width * 0.267, baseY - mountainHeight * 0.429)
      ..lineTo(size.width * 0.480, baseY - mountainHeight * 0.857)
      ..lineTo(size.width * 0.693, baseY - mountainHeight * 0.500)
      ..lineTo(size.width * 0.853, baseY - mountainHeight * 0.714)
      ..lineTo(size.width, baseY - mountainHeight * 0.429)
      ..lineTo(size.width, baseY)
      ..close();
    canvas.drawPath(fgPath, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 毛玻璃 CTA 按钮 (PRD P1 Layer 4)
// 拆分：_GlassCtaButton → _PressableShell → _FrostedPill → BackdropBlur
// ─────────────────────────────────────────────────────────────────────────────

/// 入口：管理 hover / pressed 状态，传递背景色给子组件
class _GlassCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _GlassCtaButton({required this.label, required this.onTap});

  @override
  State<_GlassCtaButton> createState() => _GlassCtaButtonState();
}

class _GlassCtaButtonState extends State<_GlassCtaButton> {
  bool _pressed = false;
  bool _hovered = false;
  DateTime? _lastTap;

  Color get _bgColor {
    if (_pressed) return const Color(0x40FFFFFF); // .25
    if (_hovered) return const Color(0x33FFFFFF); // .20
    return const Color(0x1FFFFFFF); // .12
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 300) {
      return;
    }
    _lastTap = now;
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return _PressableShell(
      hovered: _hovered,
      pressed: _pressed,
      onHoverChange:
          widget.onTap == null ? (_) {} : (v) => setState(() => _hovered = v),
      onPressChange:
          widget.onTap == null ? (_) {} : (v) => setState(() => _pressed = v),
      onTap: widget.onTap == null ? null : _handleTap,
      child: _FrostedPill(
        bgColor: _bgColor,
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 交互壳：MouseRegion + GestureDetector + AnimatedScale，只管交互状态和缩放动画
class _PressableShell extends StatelessWidget {
  final bool hovered;
  final bool pressed;
  final ValueChanged<bool> onHoverChange;
  final ValueChanged<bool> onPressChange;
  final VoidCallback? onTap;
  final Widget child;

  const _PressableShell({
    required this.hovered,
    required this.pressed,
    required this.onHoverChange,
    required this.onPressChange,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTapDown: onTap == null ? null : (_) => onPressChange(true),
        onTapUp: onTap == null
            ? null
            : (_) {
                onPressChange(false);
                onTap!();
              },
        onTapCancel: onTap == null ? null : () => onPressChange(false),
        child: AnimatedScale(
          scale: pressed ? 0.97 : 1.0,
          duration: pressed ? AppMotion.press : AppMotion.feedback,
          curve: Curves.ease,
          child: child,
        ),
      ),
    );
  }
}

/// 毛玻璃药丸容器：ClipRRect + BackdropBlur + AnimatedContainer 装饰
class _FrostedPill extends StatelessWidget {
  final Color bgColor;
  final Widget child;

  const _FrostedPill({required this.bgColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropBlur(
        blur: 20,
        child: AnimatedContainer(
          duration: AppMotion.feedback,
          curve: Curves.ease,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.interactiveCtaBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BackdropBlur — 使用 ImageFilter 实现毛玻璃效果
// ─────────────────────────────────────────────────────────────────────────────

class BackdropBlur extends StatelessWidget {
  final double blur;
  final Widget child;

  const BackdropBlur({super.key, required this.blur, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
