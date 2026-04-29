import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifeand_care_app/features/tab3_health/health_view_model.dart';
import 'package:lifeand_care_app/core/ui/header/profile_island.dart';


class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLogoTap;

  const MainAppBar({super.key, this.onLogoTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GestureDetector(
        onTap: onLogoTap,
        child: Text(
          'Life & Care',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF2563EB),
            letterSpacing: -0.8,
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          icon: const Icon(Icons.sort_rounded, color: Color(0xFF2563EB), size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Consumer<HealthViewModel>(
            builder: (context, vm, child) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  const SizedBox(width: 6),
                  Text(
                    vm.healthStatus,
                    style: GoogleFonts.inter(
                      color: vm.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const LifeCareProfileIsland(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

