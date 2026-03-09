/// Domain entity representing a financial account/source.
class AccountEntity {
  final String id;
  final String profileId;
  final String name;
  final String type; // e.g., 'cash', 'bank', 'credit'
  final String icon;
  final bool isDefault;
  final double currentBalance;

  AccountEntity({
    required this.id,
    required this.profileId,
    required this.name,
    required this.type,
    required this.icon,
    this.isDefault = false,
    this.currentBalance = 0.0,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Account name cannot be empty');
    }
    if (name.length > 30) {
      throw ArgumentError('Account name must be 30 characters or less');
    }
  }

  AccountEntity copyWith({
    String? id,
    String? profileId,
    String? name,
    String? type,
    String? icon,
    bool? isDefault,
    double? currentBalance,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AccountEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
