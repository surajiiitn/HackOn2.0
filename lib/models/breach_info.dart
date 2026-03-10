enum BreachSeverity { critical, high, medium, low }

class BreachInfo {
  final String id;
  final String title;
  final String description;
  final BreachSeverity severity;
  final String iconName;
  final DateTime? detectedAt;
  final bool isActionRequired;
  final List<String> actions;

  const BreachInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.iconName = 'warning',
    this.detectedAt,
    this.isActionRequired = false,
    this.actions = const [],
  });

  factory BreachInfo.fromJson(Map<String, dynamic> json) {
    return BreachInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: BreachSeverity.values.byName(json['severity'] as String),
      iconName: json['icon_name'] as String? ?? 'warning',
      isActionRequired: json['is_action_required'] as bool? ?? false,
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.name,
      'icon_name': iconName,
      'is_action_required': isActionRequired,
      'actions': actions,
    };
  }
}
