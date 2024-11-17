import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:careapp2/SensorDataPage/SensorDataPage.dart';
import 'package:careapp2/ChatHistoryPage/ChatHistoryPage.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(CareApp());
}

class CareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'CareApp',
      theme: ThemeData(
        primaryColor: Colors.pink[100],
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'CareApp',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.pink[200],
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return SensorDataPage();
      case 2:
        return ChatHistoryPage();
      default:
        return MainContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/image/CareApp.jpeg',
          height: 30,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink[200],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Sensor Data'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}

class MainContent extends StatefulWidget {
  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  int temperature = 0;
  int humidity = 0;
  int noise = 0;
  int emergencyCnt = 0;
  String noiseLevel = '조용함';
  String movementLevel = '활발';
  List<Map<String, dynamic>> latestChat = [];
  Timer? _timer;
  bool isEmergency = false; // 응급상황 여부

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    fetchLatestChatData();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchSensorData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/sensor');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        temperature = data[0]['data']['temperature']['in'];
        if (temperature >= 50) {
          emergencyCnt = emergencyCnt + 1;
        }
        if (emergencyCnt >= 5 && !isEmergency) {
          isEmergency = true;
          emergencyCnt = 0 ;
        }
        humidity = data[0]['data']['humidty']['in'];
        noiseLevel = data[0]['data']['sound'];
        noise = data[0]['data']['sound_in'];
        movementLevel = data[0]['data']['movement'];
      });
    } else {
      print('Failed to fetch sensor data');
    }
  }

  Future<void> fetchLatestChatData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/latest');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        latestChat = List<Map<String, dynamic>>.from(data['chats']);
      });
    } else {
      print('Failed to fetch latest chat data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 프로필 정보 표시 섹션
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/image/profile.png'),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('김세종', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('나이 80세', style: TextStyle(color: Colors.grey)),
                          Text('서울 광진구', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 센서 데이터 확인 섹션
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('센서 데이터 확인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildSensorCard('온도', '$temperature°C')),
                            SizedBox(width: 10),
                            Expanded(child: _buildSensorCard('움직임 정도', movementLevel)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildGaugeSensorCard('소음 정도', noise.toDouble(), 'dB', 55)),
                            SizedBox(width: 10),
                            Expanded(child: _buildGaugeSensorCard('습도', humidity.toDouble(), '%', 55)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // 최근 챗봇 대화 내용 섹션
                  Container(
                    padding: EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('최근 챗봇 이력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Expanded(
                          child: latestChat.isEmpty
                              ? Center(child: Text('최근 대화 내역이 없습니다'))
                              : ListView.builder(
                            itemCount: latestChat.length,
                            itemBuilder: (context, index) {
                              final chat = latestChat[index];
                              return _buildChatMessage(
                                chat['type'] == 'user' ? "김세종" : "챗봇",
                                chat['content'],
                                isUser: chat['type'] == 'user',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isEmergency) _buildEmergencyBanner(),
            ],
          )

    );
  }

  // 응급상황 배너 위젯
  Widget _buildEmergencyBanner() {
    // 7초 후 자동으로 배너를 닫기 위한 타이머 설정
    Future.delayed(Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          isEmergency = false; // 7초 후 응급상황 배너를 자동으로 닫음
        });
      }
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.redAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '응급상황! 온도가 50도를 초과했습니다!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                isEmergency = false; // 사용자가 배너를 닫으면 응급상황 해제
              });
            },
          ),
        ],
      ),
    );
  }

  // 일반 센서 카드 위젯 (온도, 움직임 정도 등)
  Widget _buildSensorCard(String title, String data) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(data, style: TextStyle(fontSize: 20, color: Colors.pink[200])),
        ],
      ),
    );
  }

  // 게이지 차트가 포함된 센서 카드 위젯 (습도, 소음 정도)
  Widget _buildGaugeSensorCard(String title, double value, String unit, double size) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SizedBox(
            height: size,
            width: size,
            child: CustomPaint(
              painter: GaugeChartPainter(value),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$value $unit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink[200]),
          ),
        ],
      ),
    );
  }

  // 채팅 메시지 생성 위젯
  Widget _buildChatMessage(String sender, String message, {required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: Text(sender[0], style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
          if (!isUser) SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: 270),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUser ? Colors.pink[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 14),
              softWrap: true,
              overflow: TextOverflow.clip,
            ),
          ),
          if (isUser) SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.pink[200],
              child: Text(sender[0], style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
        ],
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
      ..color = Colors.pink[100]!.withOpacity(0.2)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    Paint valueArc = Paint()
      ..color = Colors.pink[200]!
      ..strokeWidth = 10
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
