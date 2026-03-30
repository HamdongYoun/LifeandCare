import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'map_view_model.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer
          Positioned.fill(
            child: _buildMapLayer(vm),
          ),

          // 2. Search & Category UI
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) => vm.searchHospitals(value),
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: '병원 또는 진료 과목 검색...',
                            hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _buildFilterChip(context, vm, '전체', Icons.all_inclusive_rounded),
                      _buildFilterChip(context, vm, '병원', Icons.local_hospital_rounded),
                      _buildFilterChip(context, vm, '약국', Icons.local_pharmacy_rounded),
                      _buildFilterChip(context, vm, '응급실', Icons.emergency_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Current Location Button & Map Links
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => vm.launchNaverMap(),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.near_me_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '네이버 지도로 열기',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: () => vm.startLocationTracking(),
                  backgroundColor: Colors.white,
                  elevation: 6,
                  highlightElevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.my_location_rounded, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayer(MapViewModel vm) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: vm.isLoading 
          ? const CircularProgressIndicator(color: Color(0xFF2563EB))
          : Text(
              "지도를 불러오는 중입니다...", 
              style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)
            ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, MapViewModel vm, String label, IconData icon) {
    final isSelected = vm.selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF2563EB)),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13, 
            fontWeight: FontWeight.w600, 
            color: isSelected ? Colors.white : const Color(0xFF374151)
          ),
        ),
        backgroundColor: isSelected ? const Color(0xFF2563EB) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: isSelected ? BorderSide.none : BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        onPressed: () => vm.setCategoryFilter(label),
      ),
    );
  }
}
