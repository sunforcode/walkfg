class SearchHistory {
  final String id;
  final String keyword;
  final DateTime timestamp;
  final String type;

  SearchHistory({
    required this.id,
    required this.keyword,
    required this.timestamp,
    required this.type,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'],
      keyword: json['keyword'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}

class SearchHistoryResponse {
  final List<SearchHistory> searchHistories;

  SearchHistoryResponse({required this.searchHistories});

  factory SearchHistoryResponse.fromJson(Map<String, dynamic> json) {
    var historyList = json['searchHistories'] as List;
    List<SearchHistory> histories = historyList
        .map((historyJson) => SearchHistory.fromJson(historyJson))
        .toList();

    return SearchHistoryResponse(searchHistories: histories);
  }
}