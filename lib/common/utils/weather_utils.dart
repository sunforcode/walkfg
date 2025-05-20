import 'package:flutter/material.dart';

/// 天气相关工具类
class WeatherUtils {
  /// 获取天气描述
  static String getWeatherDescription(String condition) {
    switch (condition.toLowerCase()) {
      case '晴':
      case '晴朗':
        return '晴朗';
      case '多云':
        return '多云';
      case '阴':
        return '阴天';
      case '小雨':
      case '中雨':
      case '大雨':
      case '暴雨':
      case '雨':
        return '下雨';
      case '雷雨':
        return '雷雨';
      case '雪':
      case '小雪':
      case '中雪':
      case '大雪':
        return '下雪';
      case '雾':
        return '有雾';
      default:
        return '普通';
    }
  }

  /// 获取天气状况文本
  static String getWeatherConditionText(String condition) {
    switch (condition.toLowerCase()) {
      case '晴':
      case '晴朗':
        return '阳光明媚';
      case '多云':
        return '云朵点缀';
      case '阴':
        return '天色阴沉';
      case '小雨':
        return '小雨淅沥';
      case '中雨':
      case '大雨':
      case '暴雨':
      case '雨':
        return '雨水充沛';
      case '雷雨':
        return '雷电交加';
      case '雪':
      case '小雪':
      case '中雪':
      case '大雪':
        return '白雪皑皑';
      case '雾':
        return '雾气弥漫';
      default:
        return condition;
    }
  }

  /// 获取天气对应的颜色
  static Color getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case '晴':
      case '晴朗':
        return const Color(0xFF4A90E2); // 蓝色
      case '多云':
        return const Color(0xFF5E9FE0); // 浅蓝色
      case '阴':
        return const Color(0xFF7F8C8D); // 灰色
      case '小雨':
      case '中雨':
      case '大雨':
      case '暴雨':
      case '雨':
        return const Color(0xFF3498DB); // 深蓝色
      case '雷雨':
        return const Color(0xFF2C3E50); // 深灰蓝色
      case '雪':
      case '小雪':
      case '中雪':
      case '大雪':
        return const Color(0xFF9B59B6); // 紫色
      case '雾':
        return const Color(0xFFBDC3C7); // 浅灰色
      default:
        return const Color(0xFF4A90E2); // 默认蓝色
    }
  }

  /// 判断天气是否适合徒步
  static bool isSuitableForHiking(String condition) {
    switch (condition.toLowerCase()) {
      case '晴':
      case '晴朗':
      case '多云':
        return true;
      case '阴':
        return true; // 阴天也适合徒步，不会太晒
      case '小雨':
        return false; // 小雨不太适合
      case '中雨':
      case '大雨':
      case '暴雨':
      case '雨':
      case '雷雨':
      case '雪':
      case '中雪':
      case '大雪':
        return false; // 这些天气不适合徒步
      case '小雪':
        return false; // 小雪也不太适合
      case '雾':
        return false; // 雾天视线不好，不适合徒步
      default:
        return true; // 默认适合
    }
  }

  /// 获取天气建议
  static String getWeatherAdvice(String condition, double temperature) {
    if (!isSuitableForHiking(condition)) {
      switch (condition.toLowerCase()) {
        case '小雨':
          return '今天有小雨，如果要徒步请带好雨具。';
        case '中雨':
        case '大雨':
        case '暴雨':
        case '雨':
          return '今天雨势较大，不建议进行徒步活动。';
        case '雷雨':
          return '今天有雷雨，为安全考虑请取消徒步计划。';
        case '雪':
        case '小雪':
        case '中雪':
        case '大雪':
          return '今天有雪，路面可能湿滑，不建议徒步。';
        case '雾':
          return '今天有雾，视线不佳，不适合徒步活动。';
        default:
          return '今天天气不适合徒步活动。';
      }
    } else {
      if (temperature < 5) {
        return '今天温度较低，徒步时请注意保暖。';
      } else if (temperature > 30) {
        return '今天温度较高，徒步时请注意防晒和补充水分。';
      } else {
        return '今天天气适合徒步活动，祝您玩得愉快！';
      }
    }
  }
}
