import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  int temperature = 0;
  int humidity = 0;
  String noiseLevel = '조용함';
  String gasSensor = '유출없음';
  List<int> temperatureData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<int> humidityData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  Timer? _timer;

  Future<void> fetchSensorData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/sensor');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print(data);

      setState(() {
        temperature = data[0]['data']['temperature']['in'];
        humidity = data[0]['data']['humidty']['in'];
        noiseLevel = data[0]['data']['sound'];
        gasSensor = data[0]['data']['gas'];

        if (temperatureData.length > 10) {
          temperatureData.removeAt(0);
          humidityData.removeAt(0);
        }
        temperatureData.add(temperature);
        humidityData.add(humidity);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchSensorData();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('센서 데이터 현황', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        children: [
          Column(
            children: [
              Expanded(child: _buildLineChartSection('온도', temperatureData, temperature, '°C')),
              Expanded(child: _buildLineChartSection('습도', humidityData, humidity, '%')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildGaugeChartSection('소음 정도', noiseLevel, 'dB')),
              Expanded(child: _buildGaugeChartSection('가스 센서', gasSensor, 'ppm')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartSection(String title, List<int> data, int value, String unit) {
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
                '$value$unit',
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
                            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
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
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            if (value == data.last.toDouble()) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5), // 오른쪽으로 5픽셀 이동
                                child: Text(
                                  '$value$unit',
                                  style: TextStyle(color: Colors.pink[200], fontSize: 14),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
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

  Widget _buildGaugeChartSection(String title, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 255,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                CustomPaint(
                  size: Size(140, 140),
                  painter: GaugeChartPainter(value == '조용함' ? 40.0 : 100.0),
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

class GaugeChartPainter extends CustomPainter {
  final double value;
  GaugeChartPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    double angle = value / 100 * 180;

    Paint backgroundArc = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;

    Paint valueArc = Paint()
      ..color = Colors.pink[200]!
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      pi,
      pi,
      false,
      backgroundArc,
    );

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
