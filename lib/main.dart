import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:careapp2/SensorDataPage/SensorDataPage.dart';
import 'package:careapp2/ChatHistoryPage/ChatHistoryPage.dart';
import 'dart:convert';
import 'dart:math';

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
            Image.asset(
              'assets/image/CareApp_Logo.jpeg',
              width: 100, // 로고 크기 조정
              height: 100,
            ),
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
          height: 30, // 텍스트 높이에 맞추어 이미지 크기 조정
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

// 메인 페이지 내용 위젯
class MainContent extends StatefulWidget {
  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  int temperature = 0;
  int humidity = 0;
  int noise = 0;
  String noiseLevel = '조용함';
  String movementLevel = '활발'; // 움직임 정도 상태 변수
  List<Map<String, dynamic>> latestChat = []; // 최근 챗봇 이력 데이터 리스트

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    fetchLatestChatData(); // 최근 챗봇 이력 데이터 가져오기
  }

  // 센서 데이터 API 호출 함수
  Future<void> fetchSensorData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/sensor');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        temperature = data[0]['data']['temperature']['in'];
        humidity = data[0]['data']['humidty']['in'];
        noiseLevel = data[0]['data']['sound'];
        noise = data[0]['data']['sound_in'];
        movementLevel = data[0]['data']['movement']; // 움직임 정도 데이터
      });
    } else {
      print('Failed to fetch sensor data');
    }
  }

  // 최근 챗봇 이력 API 호출 함수
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
      child: Column(
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
                    Expanded(child: _buildSensorCard('움직임 정도', movementLevel)), // 움직임 정도로 교체
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildGaugeSensorCard('소음 정도', noise.toDouble(), 'dB')),
                    SizedBox(width: 10),
                    Expanded(child: _buildGaugeSensorCard('습도', humidity.toDouble(), '%')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // 최근 챗봇 대화 내용 섹션
          Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.35,
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
                      ? Center(child: Text('최근 대화 내역이 없습니다')) // 데이터가 없을 때 기본 메시지
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
  Widget _buildGaugeSensorCard(String title, double value, String unit) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 160,
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
            height: 60,
            width: 60,
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
            constraints: BoxConstraints(maxWidth: 350), // 최대 너비를 350으로 설정
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUser ? Colors.pink[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 14),
              softWrap: true,           // 줄 바꿈을 활성화
              maxLines: null,           // 줄 수 제한 없음
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

    // 채워지지 않은 부분을 연한 색으로 표시
    Paint backgroundArc = Paint()
      ..color = Colors.pink[100]!.withOpacity(0.2) // 연한 색상 추가
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    Paint valueArc = Paint()
      ..color = Colors.pink[200]!
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 전체 배경 아크(연한 색상)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      pi,
      pi,
      false,
      backgroundArc,
    );

    // 실제 값 아크(진한 색상)
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
