import 'package:flutter/material.dart';

class ChatHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History', style: TextStyle(color: Colors.pink[200])),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 5, // 예시로 5개의 카드만 생성
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0), // 카드 간 간격을 넓게 설정하여 그림자가 겹치지 않도록 함
              child: Container(
                height: 120, // 카드 크기를 1.5배로 늘림
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
                              '2024-11-06 14:30', // 예시 날짜 형식
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '채팅 요약 예시 ${index + 1}', // 예시 요약 내용
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
            );
          },
        ),
      ),
    );
  }
}
