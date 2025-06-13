import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 天气安全展示组件
class TripWeatherSafetyDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripWeatherSafetyDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.cloud_sun,
                size: 20,
                color: CupertinoColors.systemTeal,
              ),
              const SizedBox(width: 8),
              const Text(
                '天气安全',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '需关注',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 天气安全信息卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 天气信息
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.cloud_sun_rain,
                      size: 16,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '天气预报',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '待查询',
                        style: TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.systemBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '出行前请关注天气预报，做好相应准备',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),

                const SizedBox(height: 16),

                // 安全提醒
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.shield,
                      size: 16,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '安全提醒',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '重要',
                        style: TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.systemRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '请携带必要的安全装备，告知家人行程安排',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),

                // 安全检查清单
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 14,
                            color: CupertinoColors.systemRed,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '安全检查清单',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildSafetyCheckItem('携带急救包和常用药品'),
                      _buildSafetyCheckItem('检查通讯设备和备用电源'),
                      _buildSafetyCheckItem('告知家人详细行程计划'),
                      _buildSafetyCheckItem('了解当地紧急联系方式'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.systemRed,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
