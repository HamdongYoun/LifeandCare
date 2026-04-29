import 'package:flutter/material.dart';

class StatusPulseIndicator extends StatefulWidget {
  final Color color;
  const StatusPulseIndicator({super.key, this.color = const Color(0xFF10B981)});

  @override
  State<StatusPulseIndicator> createState() => _StatusPulseIndicatorState();
}

class _StatusPulseIndicatorState extends State<StatusPulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _animation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background (Recovered from components.css ::after)
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: (1.0 - (_controller.value)).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _animation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                ),
              ),
            );
          },
        ),
        // Static Dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 8)],
          ),
        ),
      ],
    );
  }
}
