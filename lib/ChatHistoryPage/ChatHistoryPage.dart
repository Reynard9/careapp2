import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatHistoryPage extends StatefulWidget {
  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<Map<String, dynamic>> chatList = []; // 채팅 기록 리스트

  @override
  void initState() {
    super.initState();
    fetchChatHistData(); // 초기 로드 시 데이터 가져오기
  }

  // 채팅 목록 API 호출 함수
  Future<void> fetchChatHistData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/list'); // 실제 API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print('API Data: $data'); // API 응답 데이터 출력

      setState(() {
        // JSON 데이터를 리스트로 변환하여 상태에 저장
        chatList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  // 날짜 포맷팅 함수
  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '날짜 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 720, // 화면 너비 고정
          padding: const EdgeInsets.all(16.0),
          child: chatList.isEmpty
              ? Center(child: Text('데이터가 없습니다')) // 데이터가 없을 때 기본 메시지
              : ListView.builder(
            itemCount: chatList.length, // 채팅 기록의 개수에 맞게 표시
            itemBuilder: (context, index) {
              final chatData = chatList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(sessionId: chatData['id']),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0), // 카드 간 간격 설정
                  child: Container(
                    height: 120, // 카드 크기 설정
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: Offset(0, 6), // 그림자 위치 조정
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  formatDate(chatData['created_at'] ?? ''), // 포맷된 날짜 표시
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  chatData['summary'] ?? '요약 없음', // 요약 표시
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink[200]),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// 개별 채팅 세부 페이지
class ChatDetailPage extends StatefulWidget {
  final int sessionId;

  ChatDetailPage({required this.sessionId});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Map<String, dynamic>> chatDetailList = [];

  @override
  void initState() {
    super.initState();
    fetchChatDetailData(widget.sessionId); // 선택된 세션의 대화 데이터를 가져오기
  }

  // 선택된 세션의 상세 채팅 API 호출
  Future<void> fetchChatDetailData(int sessionId) async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/$sessionId'); // 실제 API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print('API Chat Detail Data: $data'); // API 응답 데이터 출력

      setState(() {
        // 세션의 "chats" 리스트를 저장
        chatDetailList = List<Map<String, dynamic>>.from(data['chats']);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Detail', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 720, // 화면 너비 고정
          padding: const EdgeInsets.all(16.0),
          child: chatDetailList.isEmpty
              ? Center(child: Text('대화 내역이 없습니다')) // 데이터가 없을 때 기본 메시지
              : ListView.builder(
            itemCount: chatDetailList.length,
            itemBuilder: (context, index) {
              final chat = chatDetailList[index];
              final isUser = chat['type'] == 'user';
              return _buildChatMessage(isUser ? "어르신1" : "챗봇", chat['content'] ?? '', isUser: isUser);
            },
          ),
        ),
      ),
    );
  }

  // 채팅 메시지 위젯
  Widget _buildChatMessage(String sender, String message, {required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
            constraints: BoxConstraints(maxWidth: 400), // 메시지 최대 너비 제한을 400으로 줄임
            decoration: BoxDecoration(
              color: isUser ? Colors.pink[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 14),
              softWrap: true, // 자동 줄바꿈 활성화
              overflow: TextOverflow.visible, // 오버플로우 시 내용이 화면 안에 유지됨
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
