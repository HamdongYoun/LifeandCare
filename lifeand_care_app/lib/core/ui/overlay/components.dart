import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lifeand_care_app/core/ui/overlay/settings_view_model.dart';
import 'package:lifeand_care_app/features/tab3_health/health_view_model.dart';

/**
 * [GlobalOverlays] 
 * 1. SettingsModalView (Settings Menu)
 * 2. FloatingChatBubble (FAB Chat)
 */

// --- 1. SettingsModalView ---
class SettingsModalView extends StatefulWidget {
  const SettingsModalView({super.key});

  @override
  State<SettingsModalView> createState() => _SettingsModalViewState();
}

class _SettingsModalViewState extends State<SettingsModalView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsViewModel, HealthViewModel>(
      builder: (context, vm, healthVm, child) {
        return Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                children: [
                  // 🚀 Layer 0: Legacy Health Badge (Centered at top)
                  _buildHealthBadge(healthVm),
                  const SizedBox(height: 20),
                  
                  // 🚀 Layer 1: Legacy Settings Header (Icon + Title)
                  _buildLegacySettingsHeader(),
                  const SizedBox(height: 24),
                  
                  // 🚀 Layer 2: Real-time Profile Info
                  _buildProfileSection(vm),
                  const SizedBox(height: 32),
                  
                  // 🚀 Layer 3: System Permissions
                  _buildSectionHeader("시스템 권한 및 연동"),
                  const SizedBox(height: 12),
                  _buildBaseTile(
                    icon: Icons.location_on_rounded,
                    title: "위치 서비스",
                    subtitle: vm.isLocationEnabled ? "정상 작동 중" : "권한 설정 필요",
                    trailing: Icon(Icons.check_circle_rounded, 
                      color: vm.isLocationEnabled ? Colors.green : const Color(0xFFD1D5DB), size: 20),
                    onTap: () => vm.requestLocationPermission(),
                  ),
                  const SizedBox(height: 12),
                  _buildBaseTile(
                    icon: Icons.cloud_done_rounded,
                    title: "백엔드 동기화",
                    subtitle: vm.isBackendConnected ? "서버와 연결됨" : "연결 확인 필요",
                    trailing: Icon(Icons.check_circle_rounded, 
                      color: vm.isBackendConnected ? Colors.green : const Color(0xFFD1D5DB), size: 20),
                    onTap: () => vm.checkPermissions(),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader("고객 지원"),
                  const SizedBox(height: 12),
                  _buildBaseTile(
                    icon: Icons.article_rounded,
                    title: "이용 약관 및 정책",
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
                  ),
                  const SizedBox(height: 12),
                  _buildBaseTile(
                    icon: Icons.info_rounded,
                    title: "앱 버전 정보 (v1.0.0)",
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- RECOVERED: Legacy Health Badge ---
  Widget _buildHealthBadge(HealthViewModel vm) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: vm.statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: vm.statusColor.withOpacity(0.6), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              vm.healthStatus == "정상" ? Icons.favorite : Icons.circle,
              size: vm.healthStatus == "정상" ? 14 : 8,
              color: vm.statusColor,
            ),
            const SizedBox(width: 8),
            Text(
              vm.healthStatus,
              style: GoogleFonts.inter(
                color: vm.statusColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacySettingsHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x142563EB), 
            shape: BoxShape.circle,
          ),
          child: const FaIcon(
            FontAwesomeIcons.userGear,
            size: 56,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "설정 및 권한",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2563EB),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(SettingsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: vm.isLoggedIn 
        ? Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("사용자 님", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17, color: const Color(0xFF1F2937))),
                        Text("Premium Member", style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => vm.logout(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0x0DFF0000),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("로그아웃", style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          )
        : _buildLoginPrompt(vm),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF), fontSize: 13, letterSpacing: 0.5));
  }

  Widget _buildLoginPrompt(SettingsViewModel vm) {
    return Column(
      children: [
        Text("로그인이 필요합니다", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4B5563))),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => vm.login(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text("간편 로그인", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseTile({required IconData icon, required String title, String? subtitle, required Widget trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0x142563EB), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1F2937))),
                  if (subtitle != null)
                    Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// --- 2. FloatingChatBubble ---
class FloatingChatBubble extends StatelessWidget {
  const FloatingChatBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.chat_bubble_rounded),
      ),
    );
  }
}
