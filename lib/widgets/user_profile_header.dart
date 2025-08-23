import 'package:flutter/material.dart';

class RankWingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 날개 그라데이션 색상 설정
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFB347), // 라이트 오렌지
        const Color(0xFFFF8C00), // 다크 오렌지
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    // 검은 테두리 페인트
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2D3748)
      ..strokeWidth = 2.0;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // 날개 모양 그리기 (V자 형태)
    // 왼쪽 날개
    path.moveTo(center.dx, size.height * 0.8); // 하단 중앙
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.3, // 제어점
      size.width * 0.05,
      size.height * 0.1, // 왼쪽 끝
    );
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.4, // 제어점
      center.dx,
      size.height * 0.6, // 중앙으로
    );

    // 오른쪽 날개
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.4, // 제어점
      size.width * 0.95,
      size.height * 0.1, // 오른쪽 끝
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.3, // 제어점
      center.dx,
      size.height * 0.8, // 하단 중앙으로 돌아감
    );

    path.close();

    // 날개 채우기
    canvas.drawPath(path, paint);
    // 날개 테두리
    canvas.drawPath(path, borderPaint);

    // 중앙 다이아몬드 모양 추가
    final diamondPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final diamondPath = Path();
    final diamondSize = 8.0;
    diamondPath.moveTo(center.dx, center.dy - diamondSize); // 상단
    diamondPath.lineTo(center.dx + diamondSize, center.dy); // 우측
    diamondPath.lineTo(center.dx, center.dy + diamondSize); // 하단
    diamondPath.lineTo(center.dx - diamondSize, center.dy); // 좌측
    diamondPath.close();

    canvas.drawPath(diamondPath, diamondPaint);
    canvas.drawPath(diamondPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 사용자 아바타
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7B8BC4), Color(0xFFFF9500)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 캐릭터 몸체 (오렌지 부분)
              Positioned(
                bottom: 0,
                left: 20,
                right: 20,
                height: 80,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(70),
                      bottomRight: Radius.circular(70),
                    ),
                    color: Color(0xFFFF9500),
                  ),
                ),
              ),
              // 캐릭터 얼굴 (회색 부분)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                height: 70,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF718096),
                  ),
                  child: Stack(
                    children: [
                      // 눈
                      const Positioned(
                        top: 20,
                        left: 20,
                        child: Text('👀', style: TextStyle(fontSize: 24)),
                      ),
                      // 입
                      const Positioned(
                        bottom: 15,
                        left: 35,
                        child: Text('😺', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              // 상단 장식 (핑크 리본)
              Positioned(
                top: 10,
                right: 25,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF6B9D),
                  ),
                ),
              ),
              // 랭크 아이콘 (하단 중앙, 최상위 레이어)
              Positioned(
                bottom: -5,
                left: 50,
                right: 50,
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: RankWingsPainter(),
                    size: const Size(40, 35),
                  ),
                ),
              ),
            ],
          ),
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
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
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
