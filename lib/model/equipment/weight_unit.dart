/// 重量单位
enum WeightUnit {
  /// 克
  gram,

  /// 千克
  kilogram,

  /// 磅
  pound,

  /// 盎司
  ounce
}

/// 获取重量单位名称
String getWeightUnitName(WeightUnit unit) {
  switch (unit) {
    case WeightUnit.gram:
      return 'g';
    case WeightUnit.kilogram:
      return 'kg';
    case WeightUnit.pound:
      return 'lb';
    case WeightUnit.ounce:
      return 'oz';
  }
}

/// 从字符串解析重量单位
WeightUnit parseWeightUnitFromString(String unitStr) {
  switch (unitStr.toLowerCase()) {
    case 'gram':
    case 'g':
    case '克':
      return WeightUnit.gram;
    case 'kilogram':
    case 'kg':
    case '千克':
      return WeightUnit.kilogram;
    case 'pound':
    case 'lb':
    case '磅':
      return WeightUnit.pound;
    case 'ounce':
    case 'oz':
    case '盎司':
      return WeightUnit.ounce;
    default:
      return WeightUnit.gram;
  }
}

/// 转换重量到克
double convertToGram(double weight, WeightUnit fromUnit) {
  switch (fromUnit) {
    case WeightUnit.gram:
      return weight;
    case WeightUnit.kilogram:
      return weight * 1000;
    case WeightUnit.pound:
      return weight * 453.592;
    case WeightUnit.ounce:
      return weight * 28.3495;
  }
}

/// 转换重量从克到指定单位
double convertFromGram(double weightInGram, WeightUnit toUnit) {
  switch (toUnit) {
    case WeightUnit.gram:
      return weightInGram;
    case WeightUnit.kilogram:
      return weightInGram / 1000;
    case WeightUnit.pound:
      return weightInGram / 453.592;
    case WeightUnit.ounce:
      return weightInGram / 28.3495;
  }
}
