import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:walk/service/user_service.dart';
import '../login_screen.dart';

/// 注册屏幕
class RegisterScreen extends StatefulWidget {
  /// 构造函数
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// 用户名控制器
  final TextEditingController _usernameController = TextEditingController();

  /// 邮箱控制器
  final TextEditingController _emailController = TextEditingController();

  /// 密码控制器
  final TextEditingController _passwordController = TextEditingController();

  /// 确认密码控制器
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// 是否显示密码
  bool _obscurePassword = true;

  /// 是否显示确认密码
  bool _obscureConfirmPassword = true;

  /// 是否正在注册
  bool _isRegistering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 检查用户名格式（只能包含字母、数字和下划线）
  bool _isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    return regex.hasMatch(username);
  }

  /// 处理注册
  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    debugPrint('RegisterScreen: _handleRegister called');
    debugPrint('RegisterScreen: username: $username');
    debugPrint('RegisterScreen: email: $email');
    debugPrint('RegisterScreen: password: ${password.isNotEmpty ? '***' : 'empty'}');

    // 表单验证
    if (username.isEmpty) {
      _showErrorDialog('请输入用户名');
      return;
    }

    // 用户名格式验证（重要：后端要求只能包含字母、数字和下划线）
    if (username.length < 3) {
      _showErrorDialog('用户名长度不能少于3个字符');
      return;
    }

    if (username.length > 50) {
      _showErrorDialog('用户名长度不能超过50个字符');
      return;
    }

    if (!_isValidUsername(username)) {
      _showErrorDialog('用户名只能包含字母、数字和下划线');
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog('请输入电子邮件');
      return;
    }

    // 简单邮箱格式验证
    if (!email.contains('@')) {
      _showErrorDialog('邮箱格式不正确');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('请输入密码');
      return;
    }

    // 密码长度验证
    if (password.length < 6) {
      _showErrorDialog('密码长度不能少于6个字符');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showErrorDialog('请确认密码');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('两次输入的密码不一致');
      return;
    }

    // 设置注册状态
    setState(() {
      _isRegistering = true;
    });

    try {
      debugPrint('RegisterScreen: Calling UserService.register...');
      
      // 调用实际的注册API（后端会自动登录并返回token）
      final user = await UserService.register(
        username: username,
        password: password,
        email: email,
      );
      
      debugPrint('RegisterScreen: Registration successful, user: ${user.username}');

      // 注册成功，返回个人主页
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
        Navigator.of(context).pop(true); // 返回true表示注册成功
      }
    } catch (e) {
      debugPrint('RegisterScreen: Registration error: $e');
      
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
        
        // 显示错误信息
        String errorMessage = '注册失败';
        if (e.toString().contains('用户名已存在') || e.toString().contains('username')) {
          errorMessage = '用户名已存在';
        } else if (e.toString().contains('邮箱已被注册') || e.toString().contains('email')) {
          errorMessage = '该邮箱已被注册';
        } else if (e.toString().contains('409') || e.toString().contains('Conflict')) {
          errorMessage = '用户名或邮箱已存在';
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

  /// 导航到登录页面
  void _navigateToLogin() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('注册'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const Icon(
                CupertinoIcons.person_add,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 40),
              const Text(
                '创建账号',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '开始您的徒步旅行',
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
                controller: _emailController,
                placeholder: '电子邮件',
                keyboardType: TextInputType.emailAddress,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    CupertinoIcons.mail,
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
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _confirmPasswordController,
                placeholder: '确认密码',
                obscureText: _obscureConfirmPassword,
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
                    _obscureConfirmPassword
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    color: CupertinoColors.systemGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
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
                child: _isRegistering
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white)
                    : const Text('注册'),
                onPressed: _isRegistering ? null : _handleRegister,
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('已有账号？登录'),
                onPressed: _navigateToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
