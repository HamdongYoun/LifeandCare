import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, vm, child) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 1. User Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: vm.isLoggedIn 
                  ? Column(
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF2563EB),
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('사용자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text('user@example.com', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => vm.logout(),
                            child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text('로그인이 필요합니다.'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => vm.login(),
                            child: const Text('로그인하기'),
                          ),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 32),

              const Text('시스템 권한 및 연동', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 12),

              // 2. Settings Cards
              _buildSettingCard(
                icon: Icons.location_on_outlined,
                title: '위치 권한',
                subtitle: vm.isLocationEnabled ? '정상 작동 중' : '권한이 필요합니다',
                isStatusOn: vm.isLocationEnabled,
                onTap: () => vm.requestLocationPermission(),
              ),
              const SizedBox(height: 12),

              _buildSettingCard(
                icon: Icons.lan_outlined,
                title: '백엔드 서버 연동',
                subtitle: vm.isBackendConnected ? '연결됨' : '연결 안 됨',
                isStatusOn: vm.isBackendConnected,
                onTap: () => vm.checkPermissions(),
              ),

              const SizedBox(height: 32),
              
              const Text('기타', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 12),
              
              _buildSimpleItem(icon: Icons.policy_outlined, title: '개인정보 처리방침'),
              const SizedBox(height: 12),
              _buildSimpleItem(icon: Icons.info_outline, title: '버전 정보 v1.0.0'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingCard({required IconData icon, required String title, required String subtitle, required bool isStatusOn, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isStatusOn ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleItem({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
