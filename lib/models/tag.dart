import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  const Tag({
    required this.id,
    required this.userId,
    required this.label,
    required this.colorHex,
  });

  final String id;
  final String userId;
  final String label;
  final String colorHex;

  Tag copyWith({
    String? id,
    String? userId,
    String? label,
    String? colorHex,
  }) {
    return Tag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [id, userId, label, colorHex];
}
