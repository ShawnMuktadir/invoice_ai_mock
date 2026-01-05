// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 10,
      usedTokens: (json['usedTokens'] as num?)?.toInt() ?? 0,
      isGuest: json['isGuest'] as bool? ?? false,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'totalTokens': instance.totalTokens,
      'usedTokens': instance.usedTokens,
      'isGuest': instance.isGuest,
    };
