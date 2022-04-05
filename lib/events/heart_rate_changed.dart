class HeartRateChangedEvent {
  final double heartRate;
  final DateTime timestamp;

  HeartRateChangedEvent(this.heartRate, this.timestamp);

  factory HeartRateChangedEvent.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('heartRate') || !json.containsKey('timestamp')) {
      return HeartRateChangedEvent(0, DateTime.fromMicrosecondsSinceEpoch(0));
    }
    return HeartRateChangedEvent(json['heartRate'], json['timestamp']);
  }

  Map<String, dynamic> toJson() => {
        'heartRate': heartRate,
        'timestamp': timestamp,
      };

  String toJsonString() => '{"heartRate": $heartRate, "timestamp": "$timestamp"}';
}
