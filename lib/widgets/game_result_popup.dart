import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../models/game_question.dart';

class GameResultPopup extends StatefulWidget {
  final GamePlayer player;
  final GamePlayer opponent;
  final int playerScore;
  final int opponentScore;
  final int totalQuestions;
  final bool isRankGame;
  final VoidCallback onClose;

  const GameResultPopup({
    Key? key,
    required this.player,
    required this.opponent,
    required this.playerScore,
    required this.opponentScore,
    required this.totalQuestions,
    required this.isRankGame,
    required this.onClose,
  }) : super(key: key);

  @override
  State<GameResultPopup> createState() => _GameResultPopupState();
}

class _GameResultPopupState extends State<GameResultPopup>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPlayerWon = false;

  @override
  void initState() {
    super.initState();
    _isPlayerWon = widget.playerScore > widget.opponentScore;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 팝업 등장 애니메이션
    _fadeController.forward();
    _scaleController.forward();

    // 3.5초 후 자동으로 사라지기
    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      if (mounted) {
        _hidePopup();
      }
    });
  }

  void _hidePopup() async {
    await _fadeController.reverse();
    await _scaleController.reverse();
    if (mounted) {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _scaleController]),
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildNewPopupDesign(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(
    GamePlayer user,
    int score,
    bool isWinner,
    bool isPlayer,
  ) {
    return Column(
      children: [
        // 아바타 (왕관 포함)
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: isWinner ? 64 : 48,
              height: isWinner ? 64 : 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPlayer
                      ? [const Color(0xFF788CC3), const Color(0xFF6A7BB8)]
                      : [const Color(0xFFFF6B6B), const Color(0xFFFF5252)],
                ),
                borderRadius: BorderRadius.circular(isWinner ? 32 : 24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: isWinner ? 32 : 24,
              ),
            ),
            // 승리한 사람에게만 왕관 표시
            if (isWinner)
              Positioned(
                top: -12,
                child: Image.asset(
                  'assets/icons/crown.png',
                  width: 32,
                  height: 32,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 이름
        Text(
          user.name,
          style: TextStyle(
            fontSize: isWinner ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),

        // 티어
        Text(
          user.tier,
          style: TextStyle(
            fontSize: isWinner ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: _getTierColor(user.tier),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getResultText() {
    if (widget.playerScore > widget.opponentScore) {
      return 'WIN';
    } else if (widget.playerScore < widget.opponentScore) {
      return 'LOSE';
    } else {
      return 'DRAW';
    }
  }

  Color _getResultColor() {
    if (widget.playerScore > widget.opponentScore) {
      return const Color(0xFFFFD700); // 노란색 (승리)
    } else if (widget.playerScore < widget.opponentScore) {
      return const Color(0xFFF44336); // 빨간색 (패배)
    } else {
      return const Color(0xFF666666); // 무채색 (무승부)
    }
  }

  Color _getTierColor(String tier) {
    if (tier.contains('BRONZE') || tier.contains('브론즈')) {
      return const Color(0xFFCD7F32);
    } else if (tier.contains('SILVER') || tier.contains('실버')) {
      return const Color(0xFFC0C0C0);
    } else if (tier.contains('GOLD') || tier.contains('골드')) {
      return const Color(0xFFDAA520);
    } else if (tier.contains('PLATINUM') || tier.contains('플래티넘')) {
      return const Color(0xFFE5E4E2);
    } else if (tier.contains('DIAMOND') || tier.contains('다이아몬드')) {
      return const Color(0xFFB9F2FF);
    } else if (tier.contains('MASTER') || tier.contains('마스터')) {
      return const Color(0xFFFF6B6B);
    } else {
      return const Color(0xFF999999);
    }
  }

  Widget _buildNewPopupDesign() {
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Pretendard',
        color: Color(0xFF333333),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 결과 텍스트
          Text(
            _getResultText(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _getResultColor(),
            ),
          ),
          const SizedBox(height: 16),

          // 플레이어 대결 정보
          Row(
            children: [
              // 플레이어 (왼쪽)
              Expanded(
                child: _buildPlayerSection(
                  widget.player,
                  widget.playerScore,
                  _isPlayerWon,
                  true,
                ),
              ),
              const SizedBox(width: 12),

              // VS 표시
              Text(
                'VS',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 12),

              // 상대방 (오른쪽)
              Expanded(
                child: _buildPlayerSection(
                  widget.opponent,
                  widget.opponentScore,
                  !_isPlayerWon,
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 스코어 표시 (일반 대결일 때만)
          if (!widget.isRankGame) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.playerScore}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 20,
                    color: const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.opponentScore}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '일반대전',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999),
              ),
            ),
          ],
          // 랭크게임 표시
          if (widget.isRankGame) ...[
            const SizedBox(height: 6),
            const Text(
              '랭크게임',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerSection(
    GamePlayer player,
    int score,
    bool isWinner,
    bool isPlayer,
  ) {
    return Column(
      children: [
        // 아바타와 왕관
        Container(
          width: isWinner ? 88 : 64,
          height: isWinner ? 88 : 64,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isWinner ? 88 : 64,
                height: isWinner ? 88 : 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPlayer
                        ? [const Color(0xFF788CC3), const Color(0xFF6A7BB8)]
                        : [const Color(0xFFFF6B6B), const Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(isWinner ? 44 : 32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: isWinner ? 44 : 32,
                ),
              ),
              // 승리자에게만 왕관 표시 (맨 앞으로)
              if (isWinner && widget.playerScore != widget.opponentScore)
                Positioned(
                  top: -20,
                  child: Image.asset(
                    'assets/icons/crown.png',
                    width: 36,
                    height: 36,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 이름
        Text(
          player.name,
          style: TextStyle(
            fontSize: isWinner ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),

        // 티어
        Text(
          player.tier,
          style: TextStyle(
            fontSize: isWinner ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: _getTierColor(player.tier),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNormalGamePlayerInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 플레이어 정보
          Expanded(
            child: Row(
              children: [
                // 플레이어 아바타
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: _isPlayerWon ? 56 : 48,
                      height: _isPlayerWon ? 56 : 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF788CC3), Color(0xFF6A7BB8)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF788CC3).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: _isPlayerWon ? 28 : 24,
                      ),
                    ),
                    // 승리한 사람에게만 왕관 표시
                    if (_isPlayerWon)
                      Positioned(
                        top: -10,
                        child: Image.asset(
                          'assets/icons/crown.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // 플레이어 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.player.name,
                        style: TextStyle(
                          fontSize: _isPlayerWon ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Text(
                        widget.player.tier,
                        style: TextStyle(
                          fontSize: _isPlayerWon ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: _getTierColor(widget.player.tier),
                        ),
                      ),
                    ],
                  ),
                ),
                // 플레이어 스코어
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF788CC3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${widget.playerScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 구분선
          Container(width: 1, height: 40, color: Colors.grey[200]),
          const SizedBox(width: 16),
          // 상대방 정보
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 상대방 스코어
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${widget.opponentScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 상대방 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.opponent.name,
                        style: TextStyle(
                          fontSize: !_isPlayerWon ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Text(
                        widget.opponent.tier,
                        style: TextStyle(
                          fontSize: !_isPlayerWon ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: _getTierColor(widget.opponent.tier),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 상대방 아바타
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: !_isPlayerWon ? 56 : 48,
                      height: !_isPlayerWon ? 56 : 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: !_isPlayerWon ? 28 : 24,
                      ),
                    ),
                    // 승리한 사람에게만 왕관 표시
                    if (!_isPlayerWon)
                      Positioned(
                        top: -10,
                        child: Image.asset(
                          'assets/icons/crown.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
