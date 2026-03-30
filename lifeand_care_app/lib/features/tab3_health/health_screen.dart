import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'health_view_model.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  // 1. Refresh Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                  
                  // 2. Health Score Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '나의 건강 점수',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${vm.report.score}', 
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: (vm.report.score / 100).clamp(0.1, 1.0),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 3. Status Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: vm.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, color: vm.statusColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          vm.statusLabel.isEmpty ? '분석 완료' : vm.statusLabel,
                          style: GoogleFonts.inter(
                            color: vm.statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Professional Health Report Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_rounded, color: Color(0xFF2563EB), size: 22),
                            const SizedBox(width: 12),
                            Text(
                              '심층 분석 리포트',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: Color(0xFFF3F4F6), thickness: 1),
                        ),
                        
                        Text(
                          vm.report.content,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.7,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        
                        if (vm.report.suggestions.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text(
                            '권장 조치 사항',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...vm.report.suggestions.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF10B981)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SymmetricBox extends StatelessWidget {
  final double width;
  const SymmetricBox({super.key, required this.width});
  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

