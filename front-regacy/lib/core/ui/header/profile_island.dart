import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifeand_care_app/core/ui/overlay/settings_view_model.dart';
import 'package:lifeand_care_app/core/ui/overlay/components.dart';

/**
 * [LifeCareProfileIsland] - Modularized Premium Profile Widget
 * Mapping Legacy premium avatar design with glassmorphism and pulsing border.
 */
class LifeCareProfileIsland extends StatelessWidget {
  const LifeCareProfileIsland({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSettingsModal(context),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    width: 2.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 18, // header 크기에 맞게 리사이징
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: const SettingsModalView(),
      ),
    );
  }
}
