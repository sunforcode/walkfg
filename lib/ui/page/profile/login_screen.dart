import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'auth/register_screen.dart';
import 'auth/forgot_password_screen.dart';
import '../../../service/user_service.dart';

/// 登录屏幕
class LoginScreen extends StatefulWidget {
  /// 构造函数
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// 用户名控制器
  final TextEditingController _usernameController = TextEditingController();

  /// 密码控制器
  final TextEditingController _passwordController = TextEditingController();

  /// 是否显示密码
  bool _obscurePassword = true;

  /// 是否正在登录
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint('LoginScreen: _handleLogin called');
    debugPrint('LoginScreen: username: $username');
    debugPrint('LoginScreen: password: ${password.isNotEmpty ? '***' : 'empty'}');

    // 简单的表单验证
    if (username.isEmpty) {
      _showErrorDialog('请输入用户名');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('请输入密码');
      return;
    }

    // 设置登录状态
    setState(() {
      _isLoggingIn = true;
    });

    try {
      debugPrint('LoginScreen: Calling UserService.login...');
      
      // 调用实际的登录API
      final user = await UserService.login(username, password);
      
      debugPrint('LoginScreen: Login successful, user: ${user.username}');

      // 登录成功，返回个人主页
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
        Navigator.of(context).pop(true); // 返回true表示登录成功
      }
    } catch (e) {
      debugPrint('LoginScreen: Login error: $e');
      
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
        
        // 显示错误信息
        String errorMessage = '登录失败';
        if (e.toString().contains('用户名或密码错误')) {
          errorMessage = '用户名或密码错误';
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage = '用户名或密码错误';
        } else if (e.toString().contains('404')) {
          errorMessage = '服务器连接失败';
        } else if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
          errorMessage = '网络连接失败，请检查网络';
        }
        
        _showErrorDialog(errorMessage);
      }
    }
  }

  /// 显示错误对话框
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 导航到注册页面
  void _navigateToRegister() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  /// 导航到忘记密码页面
  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('登录'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                CupertinoIcons.person_crop_circle_fill,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 40),
              const Text(
                'Walk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '徒步旅行助手',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CupertinoTextField(
                controller: _usernameController,
                placeholder: '用户名',
                keyboardType: TextInputType.text,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    CupertinoIcons.person,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: '密码',
                obscureText: _obscurePassword,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    CupertinoIcons.lock,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: CupertinoButton(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    color: CupertinoColors.systemGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: _isLoggingIn
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white)
                    : const Text('登录'),
                onPressed: _isLoggingIn ? null : _handleLogin,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('没有账号？注册'),
                    onPressed: _navigateToRegister,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('忘记密码？'),
                    onPressed: _navigateToForgotPassword,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
