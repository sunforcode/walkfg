import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 登录屏幕
class LoginScreen extends StatelessWidget {
  /// 构造函数
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.hiking,
              size: 80,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 40),
            Text(
              'Walk',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '徒步旅行助手',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: const InputDecoration(
                labelText: '电子邮件',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('登录'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/register');
              },
              child: const Text('没有账号？注册'),
            ),
            TextButton(
              onPressed: () {
                context.go('/forgot-password');
              },
              child: const Text('忘记密码？'),
            ),
          ],
        ),
      ),
    );
  }
}