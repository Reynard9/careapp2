import 'package:flutter/material.dart';
import 'package:careapp2/SensorDataPage/SensorDataPage.dart';
import 'package:careapp2/ChatHistoryPage/ChatHistoryPage.dart';
import 'dart:math';

void main() {
  runApp(CareApp());
}

class CareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        child: Text(
          'CareApp',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.pink[200],
            letterSpacing: 1.5,
          ),
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
        title: Text(
          'CareApp',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[200]),
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
class MainContent extends StatelessWidget {
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
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('어르신1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('나이 n세', style: TextStyle(color: Colors.grey)),
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
                    Expanded(child: _buildSensorCard('온도', '23°C')),
                    SizedBox(width: 10),
                    Expanded(child: _buildSensorCard('가스 센서', '양호')),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildGaugeSensorCard('소음 정도', 40, 'dB')),
                    SizedBox(width: 10),
                    Expanded(child: _buildGaugeSensorCard('습도', 55, '%')),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSensorCard('움직임 정도', '활발')),
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
                  child: ListView(
                    children: [
                      _buildChatMessage("어르신1", "오늘 날씨가 어떤가요?", isUser: true),
                      _buildChatMessage("챗봇", "오늘 서울은 맑고 기온은 20도입니다.", isUser: false),
                      _buildChatMessage("어르신1", "내일도 비슷한가요?", isUser: true),
                      _buildChatMessage("챗봇", "네, 내일도 맑은 날씨가 예상됩니다.", isUser: false),
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

  // 일반 센서 카드 위젯 (온도, 가스 센서 등)
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
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUser ? Colors.pink[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message, style: TextStyle(fontSize: 14)),
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

// 게이지 차트를 그리는 CustomPainter 클래스
class GaugeChartPainter extends CustomPainter {
  final double value;
  GaugeChartPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    double angle = value / 100 * 180;

    // 배경 원호
    Paint backgroundArc = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // 값 원호
    Paint valueArc = Paint()
      ..color = Colors.pink[200]!
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 배경 원호 그리기
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      pi,
      pi,
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
