import 'package:flutter/material.dart';

// 채팅 히스토리 페이지 위젯
class ChatHistoryPage extends StatefulWidget {
  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

// 채팅 히스토리 페이지 상태 관리
class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final List<Map<String, dynamic>> messages = [
    {'sender': '어르신1', 'message': '안녕하세요?', 'isUser': true},
    {'sender': '챗봇', 'message': '안녕하세요! 무엇을 도와드릴까요?', 'isUser': false},
    {'sender': '어르신1', 'message': '오늘의 날씨는 어떤가요?', 'isUser': true},
    {'sender': '챗봇', 'message': '오늘 서울은 맑고 기온은 20도입니다.', 'isUser': false},
  ];

  final TextEditingController _controller = TextEditingController(); // 텍스트 입력 컨트롤러

  // 메시지 전송 함수
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

  // 채팅 메시지 표시 위젯
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
