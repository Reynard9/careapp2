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
  String reportContent = "챗봇 요약 보고서를 불러오는 중...";

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    final url = Uri.parse('http://203.250.148.52:48003/api/chat/${widget.sessionId}/report');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        reportContent = data['report'] ?? '요약 보고서가 없습니다.';
      });
    } else {
      setState(() {
        reportContent = '챗봇 요약 보고서를 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '챗봇 요약 보고서',
          style: TextStyle(color: Colors.pink[200]),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            reportContent,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
