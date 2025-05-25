import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/page/trip_plan/components/track_download_card.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';

/// 更多部分
class MoreSection extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 构造函数
  const MoreSection({
    Key? key,
    required this.route,
    required this.trackPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 轨迹下载卡片
          CupertinoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitleWidget(title: '轨迹下载'),
                TrackDownloadCard(
                  route: route,
                  trackPoints: trackPoints,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 天气预报卡片
          _buildWeatherCard(),

          const SizedBox(height: 16),

          // 安全信息卡片
          _buildSafetyCard(),

          const SizedBox(height: 16),

          // 分享行程卡片
          _buildShareCard(),
        ],
      ),
    );
  }

  /// 构建天气预报卡片
  Widget _buildWeatherCard() {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(title: '天气预报'),
          const SizedBox(height: 8),

          // 天气预报列表
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWeatherItem('周一', '晴', '18°/8°', CupertinoIcons.sun_max_fill),
                _buildWeatherItem('周二', '多云', '16°/7°', CupertinoIcons.cloud_sun_fill),
                _buildWeatherItem('周三', '小雨', '14°/6°', CupertinoIcons.cloud_rain_fill),
                _buildWeatherItem('周四', '阴', '15°/7°', CupertinoIcons.cloud_fill),
                _buildWeatherItem('周五', '晴', '17°/8°', CupertinoIcons.sun_max_fill),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 天气提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.info_circle,
                  color: CupertinoColors.systemBlue,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '周三有雨，建议携带雨具和防水外套',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建天气项
  Widget _buildWeatherItem(String day, String weather, String temperature, IconData icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            icon,
            color: CupertinoColors.systemYellow,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            weather,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建安全信息卡片
  Widget _buildSafetyCard() {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(title: '安全信息'),
          const SizedBox(height: 8),

          // 紧急联系人
          _buildSafetyItem(
            '紧急联系人',
            '添加紧急联系人，在行程中遇到紧急情况时可快速联系',
            CupertinoIcons.person_crop_circle_badge_exclam,
            () {
              // TODO: 添加紧急联系人
            },
          ),

          const Divider(),

          // 紧急撤离路线
          _buildSafetyItem(
            '紧急撤离路线',
            '查看路线上的紧急撤离点和撤离路线',
            CupertinoIcons.arrow_uturn_right_circle,
            () {
              // TODO: 查看紧急撤离路线
            },
          ),

          const Divider(),

          // 安全提示
          _buildSafetyItem(
            '安全提示',
            '查看该路线的安全注意事项和建议',
            CupertinoIcons.shield,
            () {
              // TODO: 查看安全提示
            },
          ),
        ],
      ),
    );
  }

  /// 构建安全项
  Widget _buildSafetyItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分享行程卡片
  Widget _buildShareCard() {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(title: '分享行程'),
          const SizedBox(height: 16),

          // 分享按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareButton(
                '微信好友',
                CupertinoIcons.chat_bubble_fill,
                CupertinoColors.systemGreen,
                () {
                  // TODO: 分享到微信好友
                },
              ),
              _buildShareButton(
                '朋友圈',
                CupertinoIcons.person_2_fill,
                CupertinoColors.systemGreen,
                () {
                  // TODO: 分享到朋友圈
                },
              ),
              _buildShareButton(
                '生成图片',
                CupertinoIcons.photo,
                CupertinoColors.systemBlue,
                () {
                  // TODO: 生成分享图片
                },
              ),
              _buildShareButton(
                '复制链接',
                CupertinoIcons.link,
                CupertinoColors.systemGrey,
                () {
                  // TODO: 复制分享链接
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建分享按钮
  Widget _buildShareButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}