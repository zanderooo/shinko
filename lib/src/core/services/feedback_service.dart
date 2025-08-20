import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedbackService {
  static Future<void> celebrate(BuildContext context, {String? message}) async {
    HapticFeedback.lightImpact();
    if (message != null && (context as Element).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    _showConfettiOverlay(context);
  }

  static void _showConfettiOverlay(BuildContext context) {
    if (!(context as Element).mounted) return;
    final overlay = Overlay.of(context);
    final rng = Random();
    final entry = OverlayEntry(
      builder: (ctx) {
        final items = List.generate(20, (i) => _ConfettiPiece(left: rng.nextDouble()));
        return IgnorePointer(
          child: Stack(children: items),
        );
      },
    );
    overlay.insert(entry);
    Timer(const Duration(milliseconds: 900), () => entry.remove());
  }
}

class _ConfettiPiece extends StatefulWidget {
  final double left; // 0..1 (screen width fraction)
  const _ConfettiPiece({required this.left});
  @override
  State<_ConfettiPiece> createState() => _ConfettiPieceState();
}

class _ConfettiPieceState extends State<_ConfettiPiece> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _a = CurvedAnimation(parent: _c, curve: Curves.easeIn);
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Positioned(
        top: _a.value * MediaQuery.of(context).size.height * 0.6,
        left: widget.left * width,
        child: Transform.rotate(
          angle: _a.value * 6.28,
          child: Text('✨', style: TextStyle(fontSize: 14 + (1 - _a.value) * 8)),
        ),
      ),
    );
  }
}


