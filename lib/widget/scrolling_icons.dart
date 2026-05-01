import 'package:flutter/material.dart';

class ScrollingIcons extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool reverse;

  const ScrollingIcons({super.key, required this.data, this.reverse = false});

  @override
  State<ScrollingIcons> createState() => _ScrollingIconsState();
}

class _ScrollingIconsState extends State<ScrollingIcons> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.reverse ? 5000.0 : 0.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;

    double target = widget.reverse
        ? _scrollController.offset - 100
        : _scrollController.offset + 100;

    _scrollController
        .animateTo(
          target,
          duration: const Duration(seconds: 5),
          curve: Curves.linear,
        )
        .then((_) => _startScrolling());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45, // Set a specific height for the row
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = widget.data[index % widget.data.length];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3FF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                // Changed from Column to Row for side-by-side layout
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], color: const Color(0xFF00885d), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    item['label'],
                    style: const TextStyle(
                      color: Color(0xFF00885d),
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Slightly increased for readability
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
