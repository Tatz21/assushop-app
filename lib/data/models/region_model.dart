class StateItem {
  final String id;
  final String name;
  final int outletCount;

  const StateItem({
    required this.id,
    required this.name,
    required this.outletCount,
  });
}

class DistrictItem {
  final String id;
  final String stateId;
  final String name;
  final int outletCount;

  const DistrictItem({
    required this.id,
    required this.stateId,
    required this.name,
    required this.outletCount,
  });
}

class MarketItem {
  final String id;
  final String districtId;
  final String name;
  final int outletCount;

  const MarketItem({
    required this.id,
    required this.districtId,
    required this.name,
    required this.outletCount,
  });
}
