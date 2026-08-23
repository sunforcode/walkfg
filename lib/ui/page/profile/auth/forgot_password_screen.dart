import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 忘记密码屏幕
class ForgotPasswordScreen extends StatefulWidget {
  /// 构造函数
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  /// 邮箱控制器
  final TextEditingController _emailController = TextEditingController();

  /// 是否正在发送
  bool _isSending = false;

  /// 是否已发送
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// 处理发送重置链接
  void _handleSendResetLink() {
    final email = _emailController.text.trim();

    // 简单的表单验证
    if (email.isEmpty) {
      _showErrorDialog('请输入电子邮件');
      return;
    }

    // 设置发送状态
    setState(() {
      _isSending = true;
    });

    // 模拟发送过程
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSending = false;
        _isSent = true;
      });

      // 显示发送成功提示
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('发送成功'),
          content: Text('重置密码链接已发送到 $email'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                // 返回登录页面
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('忘记密码'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                CupertinoIcons.lock_rotation,
                size: 80,
                color: AppColors.interactiveAccent,
              ),
              const SizedBox(height: 40),
              const Text(
                '重置密码',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '请输入您的电子邮件，我们将向您发送重置密码的链接',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textWeak,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CupertinoTextField(
                controller: _emailController,
                placeholder: '电子邮件',
                keyboardType: TextInputType.emailAddress,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    CupertinoIcons.mail,
                    color: AppColors.textWeak,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !_isSent,
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: _isSent
                    ? AppColors.badgeVerifiedBg
                    : AppColors.interactiveAccent,
                child: _isSending
                    ? const CupertinoActivityIndicator(color: AppColors.bgBase)
                    : Text(_isSent ? '已发送' : '发送重置链接'),
                onPressed:
                    (_isSending || _isSent) ? null : _handleSendResetLink,
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('返回登录'),
                onPressed: _navigateToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
