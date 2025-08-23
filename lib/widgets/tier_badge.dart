import 'package:flutter/material.dart';

class TierBadge extends StatelessWidget {
  final String tier;
  final String tierColor;
  final double size;

  const TierBadge({
    Key? key,
    required this.tier,
    required this.tierColor,
    this.size = 24,
  }) : super(key: key);

  Color _getTierColor() {
    switch (tierColor) {
      case 'G':
        return const Color(0xFFF4C135); // 골드
      case 'S':
        return const Color(0xFFC6C6C6); // 실버
      case 'B':
        return const Color(0xFFAC865F); // 브론즈
      case 'C':
        return const Color(0xFF66CC66); // 커먼
      case 'P':
        return const Color(0xFF5CDAC0); // 플래티넘
      case 'M':
        return const Color(0xFFFF4949); // 마스터 (그라데이션 대신 단색)
      default:
        return const Color(0xFFAC865F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getTierColor(),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          tier,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
