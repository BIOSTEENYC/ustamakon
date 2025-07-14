import 'package:hive_flutter/hive_flutter.dart';
import '../models/guide.dart';

class GuideAdapter extends TypeAdapter<Guide> {
  @override
  final int typeId = 2;

  @override
  Guide read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Guide(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? 'Nomaʼlum',
      iconEmoji: fields[2] as String? ?? '',
      documentUrl: fields[3] as String? ?? '',
      isDownloaded: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Guide obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1) // <-- YO‘Q EDI, QO‘SHILDI
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.iconEmoji)
      ..writeByte(3)
      ..write(obj.documentUrl)
      ..writeByte(4)
      ..write(obj.isDownloaded);
  }
}