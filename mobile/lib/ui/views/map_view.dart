import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/map_provider.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
        ),
      );
    
    _loadMap();
  }

  void _loadMap() {
    final mapState = ref.read(mapProvider);
    final searchQuery = mapState.hospitalName;
    String url;
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (mapState.provider == MapProviderType.kakao) {
        url = 'https://map.kakao.com/link/search/${Uri.encodeComponent(searchQuery)}';
      } else {
        url = 'https://m.map.naver.com/search2/search.naver?query=${Uri.encodeComponent(searchQuery)}';
      }
    } else {
      url = "https://m.map.naver.com/search2/search.naver?query=주변병원";
    }
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mapProvider, (previous, next) {
      if (next.hospitalName != null && previous?.hospitalName != next.hospitalName) {
        _loadMap();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 병원 찾기'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMap,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
