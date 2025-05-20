import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 日期时间相关工具类
class DateTimeUtils {
  /// 格式化日期为字符串 (yyyy-MM-dd)
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '未设置';
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// 格式化日期为字符串 (yyyy年MM月dd日)
  static String formatDateChinese(DateTime? dateTime) {
    if (dateTime == null) return '未设置';
    return DateFormat('yyyy年MM月dd日').format(dateTime);
  }

  /// 格式化日期为字符串 (MM月dd日)
  static String formatDateShort(DateTime? dateTime) {
    if (dateTime == null) return '未设置';
    return DateFormat('MM月dd日').format(dateTime);
  }

  /// 格式化日期时间为字符串 (yyyy-MM-dd HH:mm)
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未设置';
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  /// 获取时间差描述（几分钟前、几小时前、几天前等）
  static String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '未知时间';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 获取问候语
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '凌晨好';
    } else if (hour < 9) {
      return '早上好';
    } else if (hour < 12) {
      return '上午好';
    } else if (hour < 14) {
      return '中午好';
    } else if (hour < 18) {
      return '下午好';
    } else if (hour < 22) {
      return '晚上好';
    } else {
      return '夜深了';
    }
  }

  /// 获取当前季节
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      return '春季';
    } else if (month >= 6 && month <= 8) {
      return '夏季';
    } else if (month >= 9 && month <= 11) {
      return '秋季';
    } else {
      return '冬季';
    }
  }

  /// 计算两个日期之间的天数
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// 判断日期是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断日期是否是明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// 判断日期是否是昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 获取友好的日期描述（今天、明天、昨天或具体日期）
  static String getFriendlyDate(DateTime date) {
    if (isToday(date)) {
      return '今天';
    } else if (isTomorrow(date)) {
      return '明天';
    } else if (isYesterday(date)) {
      return '昨天';
    } else {
      return formatDateShort(date);
    }
  }
}
