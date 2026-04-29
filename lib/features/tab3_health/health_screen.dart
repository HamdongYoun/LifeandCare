import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'health_view_model.dart';
import 'package:lifeand_care_app/data/services/history_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthViewModel>().fetchHealthReport();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 3));
        }
        
        return FadeTransition(
          opacity: _animation,
          child: Container(
            color: const Color(0xFFF9FAFB),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              child: Column(
                children: [
                  // 🚀 Layer 1: Legacy Health Header (Pulse Icon + Title)
                  const HealthHeader(),
                  const SizedBox(height: 24), // Reduced from 48 to optimize space

                  // 4. Professional Health Report Card (Mapping .report-card: 2px solid #000000, 600px min-height)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 600),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF000000), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              '심층 분석 리포트',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const Spacer(),
                            RotationTransition(
                              turns: _animController,
                              child: IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9CA3AF), size: 22),
                                onPressed: () {
                                  _animController.repeat();
                                  context.read<HealthViewModel>().fetchHealthReport().then((_) {
                                    _animController.stop();
                                    _animController.forward(from: 0);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          vm.report.content,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            height: 1.9, // Exact 1.9 line-height mapping
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        if (vm.report.suggestions.isNotEmpty) ...[
                          const SizedBox(height: 40),
                          Container(height: 1, color: const Color(0xFFF1F5F9)),
                          const SizedBox(height: 30),
                          Text(
                            'AI 가이드 제언',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...vm.report.suggestions.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Icon(Icons.circle, size: 6, color: Color(0xFF000000)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 5. Recovered Note List (Mapping legacy .note-list)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '기록된 상담 요약',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '총 ${context.watch<HistoryViewModel>().history.length}건',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Consumer<HistoryViewModel>(
                    builder: (context, historyVM, child) {
                      if (historyVM.history.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 1, style: BorderStyle.solid),
                          ),
                          child: Center(
                            child: Text(
                              '저장된 건강 기록이 없습니다.',
                              style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: historyVM.history.map((note) => _buildLegacyNoteItem(context, historyVM, note)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegacyNoteItem(BuildContext context, HistoryViewModel vm, HistoryItem note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000), width: 2.0), // Mapping .note-item border
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 10),
              Text(
                '${note.date.year}.${note.date.month}.${note.date.day} ${note.date.hour}:${note.date.minute}',
                style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => vm.deleteNote(note.id),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9CA3AF), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.summary,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SymmetricBox extends StatelessWidget {
  final double width;
  const SymmetricBox({super.key, required this.width});
  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

// 🚀 Layer 1: Legacy Health Header (Core Implementation)
class HealthHeader extends StatelessWidget {
  const HealthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // [상단 공간 최적화] 텍스트가 삭제된 만큼 여백을 하단으로 20px만 주어 위로 끌어올림
      padding: const EdgeInsets.only(top: 24.0, bottom: 20.0), 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🏆 1. Pulse Icon (Legacy Styling)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.12),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const Icon(
              FontAwesomeIcons.heartPulse,
              size: 48.0, // 3rem (레거시 규격)
              color: Color(0xFF2563EB),
            ),
          ),
          
          const SizedBox(height: 14.0),
          
          // 🏆 2. Title Text (Legacy styling copy)
          Text(
            '종합 분석 리포트',
            style: GoogleFonts.outfit(
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2563EB),
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

