import 'package:flutter/material.dart';

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.emoji_events_outlined, '리더보드'),
          _buildNavItem(1, Icons.home_outlined, '홈'),
          _buildNavItem(2, Icons.edit_outlined, '리뷰'),
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
}
