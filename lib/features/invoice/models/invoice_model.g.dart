// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 2;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String?,
      uploadedAt: fields[3] as DateTime,
      type: fields[4] as InvoiceType,
      riskLevel: fields[5] as RiskLevel,
      vendor: fields[6] as String,
      invoiceDate: fields[7] as DateTime,
      amount: fields[8] as double,
      tax: fields[9] as double,
      isProcessed: fields[10] as bool,
      notes: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.uploadedAt)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.riskLevel)
      ..writeByte(6)
      ..write(obj.vendor)
      ..writeByte(7)
      ..write(obj.invoiceDate)
      ..writeByte(8)
      ..write(obj.amount)
      ..writeByte(9)
      ..write(obj.tax)
      ..writeByte(10)
      ..write(obj.isProcessed)
      ..writeByte(11)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceTypeAdapter extends TypeAdapter<InvoiceType> {
  @override
  final int typeId = 0;

  @override
  InvoiceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceType.medical;
      case 1:
        return InvoiceType.goods;
      case 2:
        return InvoiceType.service;
      case 3:
        return InvoiceType.other;
      default:
        return InvoiceType.medical;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceType obj) {
    switch (obj) {
      case InvoiceType.medical:
        writer.writeByte(0);
        break;
      case InvoiceType.goods:
        writer.writeByte(1);
        break;
      case InvoiceType.service:
        writer.writeByte(2);
        break;
      case InvoiceType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiskLevelAdapter extends TypeAdapter<RiskLevel> {
  @override
  final int typeId = 1;

  @override
  RiskLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RiskLevel.low;
      case 1:
        return RiskLevel.medium;
      case 2:
        return RiskLevel.high;
      default:
        return RiskLevel.low;
    }
  }

  @override
  void write(BinaryWriter writer, RiskLevel obj) {
    switch (obj) {
      case RiskLevel.low:
        writer.writeByte(0);
        break;
      case RiskLevel.medium:
        writer.writeByte(1);
        break;
      case RiskLevel.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
