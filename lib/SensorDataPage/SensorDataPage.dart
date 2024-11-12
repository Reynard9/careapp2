import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// 센서 데이터 페이지 위젯
class SensorDataPage extends StatelessWidget {
  final PageController _pageController = PageController(); // PageView의 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('센서 데이터 현황', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          // 첫 번째 페이지 - 온도와 습도 그래프
          Column(
            children: [
              Expanded(child: _buildLineChartSection('온도', [100, 200, 150, 300, 250, 200])),
              Expanded(child: _buildLineChartSection('습도', [50, 100, 75, 150, 125, 100])),
            ],
          ),
          // 두 번째 페이지 - 소음 정도와 가스 센서 그래프
          Row(
            children: [
              Expanded(child: _buildGaugeChartSection('소음 정도', 40, 'dB')),
              Expanded(child: _buildGaugeChartSection('가스 센서', 300, 'ppm')), // '공기질'을 '가스 센서'로 변경
            ],
          ),
        ],
      ),
    );
  }

  // 라인 차트 섹션 생성
  Widget _buildLineChartSection(String title, List<double> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${data.last.toInt()} ▲', // 현재 수치 표시 (마지막 값)
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[200]),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: data
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                            .toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Colors.pink[200]!, Colors.pink[100]!],
                        ),
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [Colors.pink[200]!.withOpacity(0.3), Colors.pink[100]!.withOpacity(0.1)],
                            stops: [0.5, 1.0],
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 게이지 차트 섹션 생성 - 소음 정도와 가스 센서 카드의 높이를 살짝 더 늘림
  Widget _buildGaugeChartSection(String title, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 255, // 카드 높이를 255로 설정하여 여백을 10픽셀 더 늘림
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // 높이를 내용에 맞춰 최소화
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                CustomPaint(
                  size: Size(140, 140), // 게이지 차트 크기를 140x140으로 유지
                  painter: GaugeChartPainter(value),
                ),
                SizedBox(height: 8),
                Text(
                  '$value $unit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink[200]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 게이지 차트를 그리는 CustomPainter 클래스
class GaugeChartPainter extends CustomPainter {
  final double value;
  GaugeChartPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    double angle = value / 100 * 180; // 값에 따라 각도를 설정 (0-100)

    // 배경 원호
    Paint backgroundArc = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;

    // 값 원호
    Paint valueArc = Paint()
      ..color = Colors.pink[200]!
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 원호 그리기
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      pi,
      pi, // 180도 (원호 반)
      false,
      backgroundArc,
    );

    // 값에 따른 원호 그리기
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      pi,
      angle * pi / 180,
      false,
      valueArc,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
