import 'package:flutter/material.dart';
import 'package:careapp2/SensorDataPage/SensorDataPage.dart'; // SensorDataPage 파일을 임포트합니다.
import 'package:careapp2/ChatHistoryPage/ChatHistoryPage.dart'; // ChatHistoryPage 파일을 임포트합니다.

void main() {
  runApp(CareApp());
}

// 앱의 최상위 위젯
class CareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareApp', // 앱 제목 설정
      theme: ThemeData(
        primaryColor: Colors.pink[100], // 주요 색상 설정
        scaffoldBackgroundColor: Colors.white, // 배경색 설정
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

// 스플래시 화면의 상태 관리
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 홈 화면으로 자동 전환
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // 홈 페이지로 이동
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'CareApp', // 스플래시 화면의 앱 이름 텍스트
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

// 홈 화면 상태 관리
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 현재 선택된 하단 네비게이션 인덱스

  // 네비게이션 아이템 탭 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 인덱스를 업데이트하여 선택된 페이지를 변경합니다.
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
        title: Text('CareApp', style: TextStyle(color: Colors.pink[200])), // 앱바 제목 설정
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _getSelectedPage(), // 현재 선택된 페이지를 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 현재 인덱스 설정
        onTap: _onItemTapped, // 탭 시 호출할 함수
        selectedItemColor: Colors.pink[200], // 선택된 아이템 색상
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // 홈 아이템
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Sensor Data'), // 센서 데이터 아이템
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'), // 채팅 아이템
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
      padding: const EdgeInsets.all(16.0), // 전체 패딩 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 프로필 정보 표시 섹션
          Row(
            children: [
              CircleAvatar(
                radius: 30, // 프로필 이미지 크기 설정
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // 임시 이미지
              ),
              SizedBox(width: 10), // 간격 설정
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('어르신1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 이름
                  Text('나이 n세', style: TextStyle(color: Colors.grey)), // 나이 정보
                  Text('서울 광진구', style: TextStyle(color: Colors.grey)), // 위치 정보
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
                    Expanded(child: _buildSensorCard('소음 정도', '40 dB')),
                    SizedBox(width: 10),
                    Expanded(child: _buildSensorCard('공기질', '300 ppm')),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSensorCard('움직임', '활발')),
                    SizedBox(width: 10),
                    Expanded(child: _buildSensorCard('응급상황 발생 여부', '없음')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // 최근 챗봇 이력 섹션
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

  // 센서 카드 위젯
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

  // 챗봇 메시지 생성 위젯
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
