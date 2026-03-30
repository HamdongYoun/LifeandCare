import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';

class HealthProfileView extends ConsumerWidget {
  const HealthProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatHistory = ref.watch(chatProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('내 건강 대시보드', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildHealthMetricGrid(),
            const SizedBox(height: 24),
            const Text('최근 AI 상담 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildChatSummaryList(chatHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('환자님 (예시)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('남성, 72세', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('혈압', '120/80', Icons.favorite, Colors.redAccent),
        _buildMetricCard('맥박', '72 bpm', Icons.bolt, Colors.orangeAccent),
        _buildMetricCard('걸음수', '5,432', Icons.directions_walk, Colors.greenAccent),
        _buildMetricCard('수면', '7h 20m', Icons.bedtime, Colors.indigoAccent),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChatSummaryList(List<dynamic> history) {
    if (history.isEmpty) {
      return const Center(child: Text('상담 내역이 없습니다.', style: TextStyle(color: Colors.grey)));
    }
    return Column(
      children: history.take(3).map((msg) => _buildRecentConsultation(msg.content, msg.timestamp.toString())).toList(),
    );
  }

  Widget _buildRecentConsultation(String title, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
