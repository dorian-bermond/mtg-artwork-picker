import 'package:flutter/material.dart';

class FrameFullscreenPage extends StatefulWidget {
  final String frameName;
  final Map<String, String> layouts;
  final String initialKey;

  const FrameFullscreenPage({
    super.key,
    required this.frameName,
    required this.layouts,
    required this.initialKey,
  });

  @override
  State<FrameFullscreenPage> createState() => _FrameFullscreenPageState();
}

class _FrameFullscreenPageState extends State<FrameFullscreenPage> {
  late List<String> _keys;
  late PageController _pageController;
  late String _currentKey;
  late List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _keys = widget.layouts.keys.toList();
    _currentKey = widget.layouts.containsKey(widget.initialKey)
        ? widget.initialKey
        : _keys.first;
    _chipKeys = List.generate(_keys.length, (_) => GlobalKey());
    _pageController = PageController(initialPage: _keys.indexOf(_currentKey));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _currentKey = _keys[i]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _chipKeys[i].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  String _label(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.frameName),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _keys
                  .map(
                    (k) => Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4,
                        child: Image.asset(widget.layouts[k]!),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_keys.length > 1)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _keys.map((k) {
                    final active = k == _currentKey;
                    final idx = _keys.indexOf(k);
                    return GestureDetector(
                      key: _chipKeys[idx],
                      onTap: () => _pageController.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: active ? Colors.white : Colors.white24,
                        ),
                        child: Text(
                          _label(k),
                          style: TextStyle(
                            color: active ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
