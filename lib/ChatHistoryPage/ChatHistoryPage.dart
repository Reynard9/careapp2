import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:careapp2/ChatSummaryPage/ChatSummaryPage.dart';

class ChatHistoryPage extends StatefulWidget {
  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<Map<String, dynamic>> chatList = [];

  @override
  void initState() {
    super.initState();
    fetchChatHistData();
  }

  Future<void> fetchChatHistData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        chatList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Failed to fetch data');
    }
  }

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
          width: 720,
          padding: const EdgeInsets.all(16.0),
          child: chatList.isEmpty
              ? Center(child: Text('데이터가 없습니다'))
              : ListView.builder(
            itemCount: chatList.length,
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
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: Offset(0, 6),
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
                                  formatDate(chatData['created_at'] ?? ''),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  chatData['summary'] ?? '요약 없음',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotSummaryPage()),
          );
        },
        label: Text('챗봇 요약 보고서'),
        icon: Icon(Icons.description),
        backgroundColor: Colors.pink[100],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: _CustomFloatingActionButtonAnimator(),
    );
  }
}

class _CustomFloatingActionButtonAnimator extends FloatingActionButtonAnimator {
  @override
  Offset getOffset({Offset? begin, Offset? end, double? progress}) {
    if (end != null) {
      return Offset(end.dx, end.dy - 20); // 우측 하단에서 20픽셀 위로 이동
    }
    return begin ?? Offset.zero;
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return parent;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 0, end: 1).animate(parent);
  }
}

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
    fetchChatDetailData(widget.sessionId);
  }

  Future<void> fetchChatDetailData(int sessionId) async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/$sessionId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
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
          width: 720,
          padding: const EdgeInsets.all(16.0),
          child: chatDetailList.isEmpty
              ? Center(child: Text('대화 내역이 없습니다'))
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
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: isUser ? Colors.pink[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 14),
              softWrap: true,
              overflow: TextOverflow.visible,
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
