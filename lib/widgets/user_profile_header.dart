import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/question_service.dart';
import '../services/user_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class UserProfileHeader extends StatefulWidget {
  const UserProfileHeader({Key? key}) : super(key: key);

  @override
  State<UserProfileHeader> createState() => UserProfileHeaderState();
}

class UserProfileHeaderState extends State<UserProfileHeader> with TickerProviderStateMixin {
  double _progressValue = 0.0; // 현재 진행도 (0.0 ~ 1.0)
  String _currentTier = 'GOLD1'; // 현재 티어
  String _userName = '김명수'; // 사용자 이름
  String _userOrganization = '서울대학교 영어영문학과'; // 사용자 소속
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _progressValue,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // UserService의 진행률과 동기화
    _progressValue = UserService.tierProgress;
    _setProgress(_progressValue);
    
    // QuestionService와 UserService에 현재 티어 설정
    QuestionService.setCurrentTier(_currentTier);
    UserService.updateTier(_currentTier);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _setProgress(double value) {
    setState(() {
      _progressValue = value.clamp(0.0, 1.0);
      
      // 100% 도달 시 다음 티어로 업그레이드
      if (_progressValue >= 1.0) {
        _upgradeTier();
        _progressValue = 0.0; // 진행도 초기화
      }
    });
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _progressValue,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.forward(from: 0.0);
  }

  void _upgradeTier() {
    setState(() {
      switch (_currentTier) {
        case 'GOLD1':
          _currentTier = 'GOLD2';
          break;
        case 'GOLD2':
          _currentTier = 'GOLD3';
          break;
        case 'GOLD3':
          _currentTier = 'GOLD4';
          break;
        case 'GOLD4':
          _currentTier = 'PLATINUM1';
          break;
        // 더 많은 티어 추가 가능
        default:
          _currentTier = 'GOLD1';
      }
    });
    
    // QuestionService와 UserService에 현재 티어 업데이트
    QuestionService.setCurrentTier(_currentTier);
    UserService.updateTier(_currentTier);
    
    // 티어 업그레이드 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '축하합니다! ${UserService.formatTier(_currentTier)}로 승급했습니다! 🎉',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFD700),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 이름과 소속 수정 메서드
  void updateUserInfo(String name, String organization) {
    setState(() {
      _userName = name;
      _userOrganization = organization;
    });
    // UserService에도 업데이트
    UserService.updateUserInfo(name, organization);
  }

  // 현재 사용자 정보 getter
  String get userName => _userName;
  String get userOrganization => _userOrganization;

  // 티어 하락 (패배 시)
  void decreaseTierProgress() {
    // 현재 진행률에서 10% 감소
    final newProgress = (_progressValue - 0.1).clamp(0.0, 1.0);
    _setProgress(newProgress);
    
    // 진행률이 0이 되면 이전 티어로 하락
    if (newProgress == 0.0) {
      _downgradeTier();
    }
  }

  // 티어 상승 (승리 시) - UserService의 진행률 사용
  void increaseTierProgress() {
    // UserService의 진행률을 가져와서 설정
    final newProgress = UserService.tierProgress;
    _setProgress(newProgress);
    
    // 진행률이 100%가 되면 다음 티어로 승급
    if (newProgress >= 1.0) {
      _upgradeTier();
    }
  }

  void _downgradeTier() {
    // 티어 하락 로직
    switch (_currentTier) {
      case 'GOLD1':
        _currentTier = 'SILVER3';
        break;
      case 'GOLD2':
        _currentTier = 'GOLD1';
        break;
      case 'GOLD3':
        _currentTier = 'GOLD2';
        break;
      case 'PLATINUM1':
        _currentTier = 'GOLD3';
        break;
      case 'PLATINUM2':
        _currentTier = 'PLATINUM1';
        break;
      case 'PLATINUM3':
        _currentTier = 'PLATINUM2';
        break;
      case 'DIAMOND1':
        _currentTier = 'PLATINUM3';
        break;
      case 'DIAMOND2':
        _currentTier = 'DIAMOND1';
        break;
      case 'DIAMOND3':
        _currentTier = 'DIAMOND2';
        break;
      case 'MASTER1':
        _currentTier = 'DIAMOND3';
        break;
      default:
        // SILVER 이하 티어는 하락하지 않음
        break;
    }
    
    // UserService와 QuestionService 업데이트
    UserService.updateTier(_currentTier);
    QuestionService.setCurrentTier(_currentTier);
    
    setState(() {});
  }



  // 티어에 따른 휘장 이미지 경로 반환
  String _getTierBadgePath() {
    String tierName;
    
    // 티어 이름에서 숫자 제거하고 소문자로 변환
    if (_currentTier.startsWith('GOLD')) {
      tierName = 'gold';
    } else if (_currentTier.startsWith('SILVER')) {
      tierName = 'silver';
    } else if (_currentTier.startsWith('BRONZE')) {
      tierName = 'bronze';
    } else if (_currentTier.startsWith('PLATINUM')) {
      tierName = 'platinum';
    } else if (_currentTier.startsWith('DIAMOND')) {
      tierName = 'diamond';
    } else if (_currentTier.startsWith('MASTER')) {
      tierName = 'master';
    } else {
      tierName = 'bronze'; // 기본값
    }
    
    return 'assets/tiers/$tierName.png';
  }

  // 티어에 따른 텍스트 색상 반환
  Color _getTierTextColor() {
    if (_currentTier.startsWith('GOLD')) {
      return const Color(0xFFD6B534); // 골드
    } else if (_currentTier.startsWith('SILVER')) {
      return const Color(0xFFC0C0C0); // 실버
    } else if (_currentTier.startsWith('BRONZE')) {
      return const Color(0xFFCD7F32); // 브론즈
    } else if (_currentTier.startsWith('PLATINUM')) {
      return const Color(0xFF00CED1); // 민트색 (플래티넘)
    } else if (_currentTier.startsWith('DIAMOND')) {
      return const Color(0xFFB9F2FF); // 다이아몬드
    } else if (_currentTier.startsWith('MASTER')) {
      return const Color(0xFF9B59B6); // 마스터
    } else {
      return const Color(0xFFCD7F32); // 기본값 (브론즈)
    }
  }

  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  
  // 기본 프로필 이미지 경로
  static const String _defaultImagePath = 'assets/images/default.png';

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('프로필 사진 변경'),
          content: const Text('이미지를 선택하세요'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Text('갤러리'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: const Text('카메라'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 사진이 변경되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 사진이 변경되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카메라 사용 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 휘장과 프로필 이미지를 독립적으로 겹쳐서 배치
        SizedBox(
          height: 200, // 전체 높이 확보
          child: Stack(
            clipBehavior: Clip.none, // 자식들이 부모 영역을 벗어날 수 있도록
            children: [
              // 사용자 아바타 (중앙에 배치)
              Positioned(
                top: 60, // 중앙에 배치
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _showImagePickerDialog,
                    child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // 흰색 배경으로 변경
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
                      child: ClipOval(
                        child: _selectedImagePath != null
                            ? Image.file(
                                File(_selectedImagePath!),
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                _defaultImagePath,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              // 휘장 (티어에 따라 동적으로 변경)
              Positioned(
                top: 125,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    _getTierBadgePath(),
                    width: 150,
                    height: 120,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 55), // 16에서 30으로 증가

        // 사용자 닉네임과 소속
        Column(
          children: [
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 32, // 24에서 32로 증가
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
            ),
            const SizedBox(height: 6), // 4에서 6으로 증가
            Text(
              _userOrganization,
              style: const TextStyle(
                fontSize: 18, // 14에서 18로 증가
                fontWeight: FontWeight.w500,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15), // 8에서 15로 증가

        // 랭크 정보 (가로 배치)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 현재 티어 텍스트
            Text(
              UserService.formatTier(_currentTier),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getTierTextColor(), // 티어별 색상 적용
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            // 진행도 프로그레스 바
            Container(
              width: 80,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD6B534), // 골드 색상으로 변경
                  ),
                    );
                  },
                ),
              ),
            ),

          ],
        ),

        const SizedBox(height: 15), // 8에서 15로 증가

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
