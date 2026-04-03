import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifeand_care_app/core/app_theme.dart';
import 'package:lifeand_care_app/core/api_config.dart';
import 'map_view_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // 1. Map Layer (Bottom)
          Positioned.fill(
            child: _buildMapLayer(vm),
          ),

          // 2. Premium Overlays UI (Search & Categories)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 52,
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
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) => vm.searchHospitals(value),
                          decoration: const InputDecoration(
                            hintText: "병원 또는 약국 검색...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Category Chips
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildMapChip(vm, '소아과', Icons.child_care_rounded),
                      _buildMapChip(vm, '내과', Icons.medication_rounded),
                      _buildMapChip(vm, '응급실', Icons.emergency_rounded),
                      _buildMapChip(vm, '약국', Icons.local_pharmacy_rounded),
                      _buildMapChip(vm, '이비인후과', Icons.hearing_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Center-on-me Button (Now BELOW sheet in Z-index)
          Positioned(
            bottom: 300, 
            right: 20,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.4),
              child: InkWell(
                onTap: () => vm.startLocationTracking(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Color(0xFF2563EB), size: 24),
                ),
              ),
            ),
          ),

          // 4. Draggable Sheet (Hospital List - ABSOLUTE TOP PRIORITY)
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.32,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            snap: true,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12), 
                      blurRadius: 30, 
                      offset: const Offset(0, -5)
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (_) {}, 
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(top: 14, bottom: 10),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        itemCount: vm.allModels.isEmpty ? 1 : vm.allModels.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20, top: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("내 주변 의료시설", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 19, color: const Color(0xFF111827))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.08), borderRadius: BorderRadius.circular(100)),
                                    child: Text(vm.selectedCategory, style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 11)),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (vm.allModels.isEmpty) {
                            return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("주변에 병원이 없습니다.")));
                          }
                          return _buildPremiumHospitalCard(context, vm, vm.allModels[index - 1]);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayer(MapViewModel vm) {
    if (vm.isLoading) {
      return Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 3)),
      );
    }
    
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: vm.userPosition,
          zoom: 14,
        ),
        locationButtonEnable: false,
        consumeSymbolTapEvents: false,
      ),
      onMapReady: (controller) => vm.onMapReady(controller),
    );
  }

  Widget _buildMapChip(MapViewModel vm, String label, IconData icon) {
    final isSelected = vm.selectedCategory == label;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => vm.setCategoryFilter(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.2 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHospitalCard(BuildContext context, MapViewModel vm, HospitalModel hospital) {
    final isEr = hospital.category == '응급실';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // [DEBUG] Prove touch event is firing
            debugPrint("🚀 Hospital Card Tapped: ${hospital.name}");
            
            // 🚀 Final Bridge: Move Map + Expand Sheet
            vm.animateTo(NLatLng(hospital.lat, hospital.lng));
            _sheetController.animateTo(
              0.85, 
              duration: const Duration(milliseconds: 400), 
              curve: Curves.fastOutSlowIn,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF000000), width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (isEr ? Colors.red : const Color(0xFF2563EB)).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEr ? Icons.emergency_rounded : Icons.local_hospital_rounded,
                    color: isEr ? Colors.redAccent : const Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital.name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF1F2937))),
                      Text(hospital.addr, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Material(
                  color: const Color(0xFF2563EB).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => vm.launchNaverMap(hospital.name),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.near_me_rounded, color: Color(0xFF2563EB), size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

