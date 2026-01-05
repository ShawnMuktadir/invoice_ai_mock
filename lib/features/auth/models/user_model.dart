import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final int totalTokens;
  final int usedTokens;
  final bool isGuest;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.totalTokens = 10,
    this.usedTokens = 0,
    this.isGuest = false,
  });

  int get remainingTokens => totalTokens - usedTokens;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    int? totalTokens,
    int? usedTokens,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalTokens: totalTokens ?? this.totalTokens,
      usedTokens: usedTokens ?? this.usedTokens,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}