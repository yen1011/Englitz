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
      case 'B':
        return const Color(0xFFAC865F); // 브론즈
      case 'S':
        return const Color(0xFFC6C6C6); // 실버
      case 'G':
        return const Color(0xFFF4C135); // 골드
      case 'P':
        return const Color(0xFF5CDAC0); // 플래티넘
      case 'D':
        return const Color(0xFF66CCFF); // 다이아
      case 'M':
        return const Color(0xFFFF4949); // 마스터 (그라데이션으로 처리)
      default:
        return const Color(0xFFAC865F);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 마스터 티어인 경우 그라데이션 적용
    if (tierColor == 'M') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF4949), // 빨강
              Color(0xFFFF8C00), // 주황
              Color(0xFFFFD700), // 노랑
            ],
          ),
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

    // 일반 티어는 기존 방식
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
