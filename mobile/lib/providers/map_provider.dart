enum MapProviderType { naver, kakao }

class MapState {
  final String? hospitalName;
  final MapProviderType provider;

  MapState({this.hospitalName, this.provider = MapProviderType.naver});

  MapState copyWith({String? hospitalName, MapProviderType? provider}) {
    return MapState(
      hospitalName: hospitalName ?? this.hospitalName,
      provider: provider ?? this.provider,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  void setHospitalSearch(String name) {
    state = state.copyWith(hospitalName: name);
  }

  void setProvider(MapProviderType type) {
    state = state.copyWith(provider: type);
  }

  void clearSearch() {
    state = state.copyWith(hospitalName: null);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
