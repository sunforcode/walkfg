import 'package:flutter/material.dart';
import 'package:walk/service/location/location_service.dart';

/// 海拔按钮组件
class AltitudeButton extends StatelessWidget {
  /// 海拔信息
  final AltitudeInfo? altitudeInfo;

  /// 是否正在获取海拔
  final bool isLoadingAltitude;

  /// 获取海拔回调
  final Future<void> Function()? onGetAltitude;

  const AltitudeButton({
    Key? key,
    this.altitudeInfo,
    this.isLoadingAltitude = false,
    this.onGetAltitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoadingAltitude ? null : onGetAltitude,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.terrain,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              if (isLoadingAltitude)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '海拔',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          if (altitudeInfo != null) ...[
            Text(
              '${altitudeInfo!.altitude.toInt()}m',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '±${altitudeInfo!.accuracy.toInt()}m',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ] else ...[
            Text(
              isLoadingAltitude ? '获取中...' : '点击获取',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
