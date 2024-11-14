import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotSummaryPage extends StatefulWidget {
  final int sessionId;

  ChatbotSummaryPage({required this.sessionId});

  @override
  _ChatbotSummaryPageState createState() => _ChatbotSummaryPageState();
}

class _ChatbotSummaryPageState extends State<ChatbotSummaryPage> {
  String title = "챗봇 요약 보고서를 불러오는 중...";
  List<Map<String, dynamic>> contents = [];
  String createdAt = "";

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/${widget.sessionId}/summary');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print (data);
      setState(() {
        title = data['title'] ?? '요약 보고서';
        createdAt = data['created_at'] ?? '';
        contents = List<Map<String, dynamic>>.from(data['contents']);
      });
    } else {
      setState(() {
        title = '챗봇 요약 보고서를 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '챗봇 요약 보고서📄',
          style: TextStyle(color: Colors.pink[200]),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[200],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "생성 일시: $createdAt",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    final item = contents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['subtitle'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[200],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['context'] ?? '',
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
