import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 注册屏幕
class RegisterScreen extends StatelessWidget {
  /// 构造函数
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
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
              '创建账号',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '开始您的徒步旅行',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: const InputDecoration(
                labelText: '用户名',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '确认密码',
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
              child: const Text('注册'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('已有账号？登录'),
            ),
          ],
        ),
      ),
    );
  }
}