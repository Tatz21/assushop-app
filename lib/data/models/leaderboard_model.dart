class LeaderboardItemModel {
  final int rank;
  final String name;
  final double collectionAmount;
  final bool isCurrentUser;
  final String? avatarUrl;

  const LeaderboardItemModel({
    required this.rank,
    required this.name,
    required this.collectionAmount,
    this.isCurrentUser = false,
    this.avatarUrl,
  });
}
