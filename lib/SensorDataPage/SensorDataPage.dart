import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:async';

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  int temperature = 0;
  int humidity = 0;
  int soundIn = 0; // 소음 dB 값을 위한 변수
  List<int> temperatureData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<int> humidityData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<int> soundData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; // 소음 데이터 리스트
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
        soundIn = data[0]['data']['sound_in']; // 소음 dB 값

        // 데이터 업데이트
        if (temperatureData.length > 10) {
          temperatureData.removeAt(0);
          humidityData.removeAt(0);
          soundData.removeAt(0);
        }
        temperatureData.add(temperature);
        humidityData.add(humidity);
        soundData.add(soundIn);
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
        title: Text(
          '센서 데이터 현황',
          style: TextStyle(
            color: Colors.pink[200],
            fontWeight: FontWeight.bold, // 글자 두께를 추가하여 더 두껍게 설정
            fontSize: 25, // 필요한 경우 글자 크기 조정
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLineChartSection('온도', temperatureData, temperature, '°C'),
            SizedBox(height: 8),
            _buildLineChartSection('습도', humidityData, humidity, '%'),
            SizedBox(height: 8),
            _buildLineChartSection('소음 정도', soundData, soundIn, 'dB'), // 소음 정도 그래프 추가
          ],
        ),
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
                '$value $unit',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[200]),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 100,
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
                                padding: const EdgeInsets.only(right: 5),
                                child: Text(
                                  '$value $unit',
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
}
