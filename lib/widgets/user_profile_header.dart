import 'package:flutter/material.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 사용자 아바타
        Stack(
          children: [
            // 메인 프로필 이미지
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF788CC3), // 단색 배경
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  // TODO: 여기에 사용자 프로필 이미지 경로를 설정하세요
                  // 예: 'assets/images/profile_photo.jpg'
                  'assets/images/default_avatar.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 랭크 아이콘 (하단 중앙)
            Positioned(
              bottom: -5,
              left: 50,
              right: 50,
              child: Container(
                height: 35,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    // TODO: 여기에 랭크 아이콘 이미지 경로를 설정하세요
                    // 예: 'assets/images/gold_rank.png'
                    'assets/icons/rank/gold.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 사용자 닉네임
        const Text(
          '김명수',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),

        const SizedBox(height: 8),

        // 랭크 정보
        Column(
          children: [
            // GOLD4 텍스트
            const Text(
              'GOLD4',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700), // 금색 텍스트
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Color(0x33000000), // 약간의 그림자로 가독성 향상
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Gold 진행도 프로그레스 바
            Container(
              width: 120,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3), // 외곽선 안쪽 반경
                child: LinearProgressIndicator(
                  value: 0.65, // Gold 65% 진행도 (예시)
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD700), // 금색 진행도
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 등수
        const Text(
          '135위',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}
