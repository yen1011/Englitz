class RankUser {
  final int rank;
  final String name;
  final String affiliation;
  final String tier;
  final String tierColor;
  final String avatarUrl;
  final bool isCurrentUser;

  RankUser({
    required this.rank,
    required this.name,
    required this.affiliation,
    required this.tier,
    required this.tierColor,
    required this.avatarUrl,
    this.isCurrentUser = false,
  });
}
