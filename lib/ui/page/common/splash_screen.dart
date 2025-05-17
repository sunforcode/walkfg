import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 启动页面
class SplashScreen extends StatefulWidget {
  /// 构造函数
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 延迟2秒后跳转到首页
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hiking,
                  size: 80,
                  color: Color(0xFF4CAF50),
                ),
              ),

              const SizedBox(height: 24),

              // 应用名称
              const Text(
                'Walk',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // 应用标语
              const Text(
                '徒步旅行助手',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 48),

              // 加载指示器
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
