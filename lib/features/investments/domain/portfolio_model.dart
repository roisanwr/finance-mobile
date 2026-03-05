class PortfolioModel {
  final String id;
  final String assetId;
  final String assetName;
  final String assetType;
  final String tickerSymbol;
  final double totalUnits;
  final double averageBuyPrice;

  PortfolioModel({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.tickerSymbol,
    required this.totalUnits,
    required this.averageBuyPrice,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    // Karena kita akan melakukan JOIN dengan tabel 'assets', kita mapping data relasinya
    final assetData = json['assets'] as Map<String, dynamic>? ?? {};

    return PortfolioModel(
      id: json['id'].toString(),
      assetId: json['asset_id'].toString(),
      assetName: assetData['name']?.toString() ?? 'Unknown Asset',
      assetType: assetData['asset_type']?.toString() ?? 'LAINNYA',
      tickerSymbol: assetData['ticker_symbol']?.toString() ?? '-',
      totalUnits: double.parse(json['total_units'].toString()),
      averageBuyPrice: double.parse(json['average_buy_price'].toString()),
    );
  }
}
