import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 忘记密码屏幕
class ForgotPasswordScreen extends StatelessWidget {
  /// 构造函数
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('忘记密码'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_reset,
              size: 80,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 40),
            Text(
              '重置密码',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '请输入您的电子邮件，我们将向您发送重置密码的链接',
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 显示发送成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('重置密码链接已发送到您的邮箱'),
                  ),
                );
                
                // 返回登录页面
                Future.delayed(const Duration(seconds: 2), () {
                  context.go('/login');
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('发送重置链接'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('返回登录'),
            ),
          ],
        ),
      ),
    );
  }
}