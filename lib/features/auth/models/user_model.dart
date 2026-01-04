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

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.totalTokens = 10,
    this.usedTokens = 0,
  });

  int get remainingTokens => totalTokens - usedTokens;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    int? totalTokens,
    int? usedTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalTokens: totalTokens ?? this.totalTokens,
      usedTokens: usedTokens ?? this.usedTokens,
    );
  }

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}