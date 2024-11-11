import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(CareApp());
}

// 앱의 최상위 위젯
class CareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareApp',
      theme: ThemeData(
        primaryColor: Colors.pink[100],
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(), // 앱 시작 시 스플래시 화면으로 설정
    );
  }
}

// 스플래시 화면 위젯
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후 홈 화면으로 이동
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
          'CareApp', // 앱 로고 텍스트
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

// 홈 화면 위젯
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 현재 선택된 하단 네비게이션 인덱스

  // 네비게이션 아이템 탭 시 호출하여 인덱스 업데이트
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 선택된 인덱스에 따라 표시할 페이지 반환
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return SensorDataPage(); // 센서 데이터 페이지
      case 2:
        return ChatHistoryPage(); // 채팅 히스토리 페이지
      default:
        return MainContent(); // 메인 페이지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CareApp', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _getSelectedPage(), // 현재 선택된 페이지 표시
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

// 센서 데이터 페이지 위젯
class SensorDataPage extends StatelessWidget {
  final PageController _pageController = PageController(); // PageView의 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          Column(
            children: [
              Expanded(child: _buildLineChartSection('온도', [100, 200, 150, 300, 250, 200])),
              Expanded(child: _buildLineChartSection('습도', [50, 100, 75, 150, 125, 100])),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildGaugeChartSection('소음 정도', 40, 'dB')),
              Expanded(child: _buildGaugeChartSection('공기질', 300, 'ppm')),
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

  // 게이지 차트 섹션 생성
  Widget _buildGaugeChartSection(String title, double value, String unit) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              CustomPaint(
                size: Size(150, 150),
                painter: GaugeChartPainter(value),
              ),
              SizedBox(height: 16),
              Text(
                '$value $unit',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[200]),
              ),
            ],
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

// MainContent, ChatHistoryPage는 이전 코드와 동일합니다.
class MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 기존 MainContent 코드 유지
    return Center(child: Text("Main Content Page"));
  }
}

class ChatHistoryPage extends StatefulWidget {
  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final List<Map<String, dynamic>> messages = [
    {'sender': '어르신1', 'message': '안녕하세요?', 'isUser': true},
    {'sender': '챗봇', 'message': '안녕하세요! 무엇을 도와드릴까요?', 'isUser': false},
    {'sender': '어르신1', 'message': '오늘의 날씨는 어떤가요?', 'isUser': true},
    {'sender': '챗봇', 'message': '오늘 서울은 맑고 기온은 20도입니다.', 'isUser': false},
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    setState(() {
      messages.add({'sender': '어르신1', 'message': text, 'isUser': true});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildChatMessage(
                  message['sender'],
                  message['message'],
                  isUser: message['isUser'],
                );
              },
            ),
          ),
          // 메시지 입력 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.pink[200]),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
