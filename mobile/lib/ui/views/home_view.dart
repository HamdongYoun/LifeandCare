import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/emergency_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Life & Care', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyCard(ref),
            const SizedBox(height: 24),
            _buildStatusCard(),
            const SizedBox(height: 24),
            const Text(
              '최근 건강 요약',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(emergencyProvider.notifier).startEmergencyCountdown();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: const [
            Icon(Icons.emergency, color: Colors.white, size: 48),
            SizedBox(height: 12),
            Text(
              '응급 상황 발생',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '터치 시 즉시 119 연결 준비',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 30,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '안녕하세요, 사용자님',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '오늘의 건강 상태는 최고입니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryList() {
    return Column(
      children: [
        _buildSummaryItem(Icons.chat_bubble_outline, '상담 내역', '어제 가슴 통증 관련 상담이 있었습니다.'),
        _buildSummaryItem(Icons.local_hospital_outlined, '병원 방문 예정', '이번 주 토요일 정기 검진이 있습니다.'),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
