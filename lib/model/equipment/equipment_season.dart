import 'equipment_list_model.dart';

/// 获取季节名称
String getSeasonName(SeasonSuitability season) {
  switch (season) {
    case SeasonSuitability.spring:
      return '春季';
    case SeasonSuitability.summer:
      return '夏季';
    case SeasonSuitability.autumn:
      return '秋季';
    case SeasonSuitability.winter:
      return '冬季';
    case SeasonSuitability.allSeasons:
      return '四季';
  }
}

/// 从字符串解析季节
SeasonSuitability parseSeasonFromString(String seasonStr) {
  switch (seasonStr.toLowerCase()) {
    case 'spring':
    case '春季':
      return SeasonSuitability.spring;
    case 'summer':
    case '夏季':
      return SeasonSuitability.summer;
    case 'autumn':
    case 'fall':
    case '秋季':
      return SeasonSuitability.autumn;
    case 'winter':
    case '冬季':
      return SeasonSuitability.winter;
    case 'allseasons':
    case 'all_seasons':
    case '四季':
      return SeasonSuitability.allSeasons;
    default:
      return SeasonSuitability.allSeasons;
  }
}