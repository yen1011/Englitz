import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/user_service.dart';

class StatsCard extends StatefulWidget {
  const StatsCard({Key? key}) : super(key: key);

  @override
  State<StatsCard> createState() => StatsCardState();
}

class StatsCardState extends State<StatsCard> {

  @override
  Widget build(BuildContext context) {
    // 디버그 로그
    print('StatsCard: Building with data - Wins: ${UserService.totalWins}, Losses: ${UserService.totalLosses}');
    print('StatsCard: Word: ${UserService.wordCorrect}, Grammar: ${UserService.grammarCorrect}, Dialog: ${UserService.dialogCorrect}');
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 승률 원형 차트
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    // 배경 원
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // 승률 원형 차트
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: CircularProgressPainter(
                        percentage: UserService.winRate,
                        strokeWidth: 8,
                        progressColor: const Color(0xFF4A90E2),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // 중앙 텍스트
                    Center(
                      child: Text(
                        '${(UserService.winRate * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // 승부 기록
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${UserService.totalWins}승 ${UserService.totalLosses}패',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Word', '${UserService.wordCorrect}', const Color(0xFF2D3748)),
                        _buildStatItem('Grammar', '${UserService.grammarCorrect}', const Color(0xFF2D3748)),
                        _buildStatItem('Dialog', '${UserService.dialogCorrect}', const Color(0xFF2D3748)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF4A5568),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행률 호
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 시작 각도 (12시 방향)
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
