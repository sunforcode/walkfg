import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:walk/model/map/map_data_model.dart';

/// 高程图表组件
class ElevationChart extends StatefulWidget {
  /// 地图数据
  final MapDataModel mapData;

  /// 图表高度
  final double height;

  /// 点击回调
  final Function(int)? onPointSelected;

  /// 构造函数
  const ElevationChart({
    Key? key,
    required this.mapData,
    this.height = 150,
    this.onPointSelected,
  }) : super(key: key);

  @override
  State<ElevationChart> createState() => _ElevationChartState();
}

class _ElevationChartState extends State<ElevationChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // 获取轨迹点
    final trackPoints = widget.mapData.trackPoints;

    // 计算最高和最低高程
    double minElevation = double.infinity;
    double maxElevation = -double.infinity;

    for (final point in trackPoints) {
      minElevation =
          point.elevation < minElevation ? point.elevation : minElevation;
      maxElevation =
          point.elevation > maxElevation ? point.elevation : maxElevation;
    }

    // 确保最小和最大高程有差异
    if (maxElevation - minElevation < 10) {
      maxElevation = minElevation + 10;
    }

    // 添加一些边距
    minElevation = (minElevation - 10).clamp(0, double.infinity);
    maxElevation = maxElevation + 10;

    // 创建图表数据点
    final spots = <FlSpot>[];

    for (int i = 0; i < trackPoints.length; i++) {
      final point = trackPoints[i];

      spots.add(FlSpot(i.toDouble(), point.elevation));
    }

    return Container(
      height: widget.height,
      padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '高程图表',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '最高: ${maxElevation.toStringAsFixed(0)}m  最低: ${minElevation.toStringAsFixed(0)}m',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: .2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: trackPoints.length / 5,
                        getTitlesWidget: (value, meta) {
                          if (value % (trackPoints.length / 5).ceil() != 0) {
                            return const SizedBox();
                          }

                          final progress =
                              (value / trackPoints.length * 100).toInt();
                          return Text(
                            '$progress%',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxElevation - minElevation) / 3,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}m',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: (trackPoints.length - 1).toDouble(),
                  minY: minElevation,
                  maxY: maxElevation,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()}m',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent &&
                          response != null &&
                          response.lineBarSpots != null &&
                          response.lineBarSpots!.isNotEmpty) {
                        final spotIndex =
                            response.lineBarSpots!.first.spotIndex;
                        setState(() {
                          _selectedIndex = spotIndex;
                        });

                        if (widget.onPointSelected != null) {
                          widget.onPointSelected!(spotIndex);
                        }
                      }
                    },
                    handleBuiltInTouches: true,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: _selectedIndex != null,
                        getDotPainter: (spot, percent, barData, index) {
                          if (index == _selectedIndex) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: Colors.blue,
                            );
                          }
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: .2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
