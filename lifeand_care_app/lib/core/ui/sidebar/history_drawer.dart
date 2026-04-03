import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeand_care_app/data/services/history_view_model.dart';

class HistoryDrawer extends StatelessWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: Consumer<HistoryViewModel>(
              builder: (context, vm, child) {
                if (vm.history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 48, color: const Color(0xFFD1D5DB)),
                        const SizedBox(height: 16),
                        Text(
                          '저장된 상담 기록이 없습니다.',
                          style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.history.length,
                  itemBuilder: (context, index) {
                    final item = vm.history[index];
                    return _buildHistoryCard(context, vm, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Life & Care',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'AI 보건 관리 시스템',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            '최근 상담 히스토리',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryViewModel vm, HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 16),
              const SizedBox(width: 8),
              Text(
                '${item.date.month}월 ${item.date.day}일 상담',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => vm.deleteNote(item.id),
                child: const Icon(Icons.close_rounded, color: Color(0xFFD1D5DB), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.summary,
            style: GoogleFonts.inter(
              color: const Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
