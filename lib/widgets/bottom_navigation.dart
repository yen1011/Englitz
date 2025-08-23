import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 홈 버튼을 정확히 중앙에 배치
          Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: _buildNavItemWithSvg(1, 'assets/icons/home.svg', '홈'),
            ),
          ),

          // 리더보드와 리뷰 버튼을 양쪽에 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: _buildNavItemWithSvg(0, 'assets/icons/cup.svg', '리더보드'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50),
                child: _buildNavItemWithSvg(2, 'assets/icons/edit.svg', '리뷰'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? const Color(0xFF788CC3)
                  : const Color(0xFFD1D1D1),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF788CC3)
                    : const Color(0xFFD1D1D1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SVG 아이콘을 사용하는 메서드 (예시)
  Widget _buildNavItemWithSvg(int index, String svgPath, String label) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF788CC3) : const Color(0xFFD1D1D1),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF788CC3)
                    : const Color(0xFFD1D1D1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
