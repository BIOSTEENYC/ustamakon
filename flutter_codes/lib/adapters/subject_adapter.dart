import 'package:hive/hive.dart';
import 'package:ustamakon/models/category.dart';
import 'package:ustamakon/models/subject.dart';

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Subject(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? 'Noma\'lum Fan',
      iconUrl: fields[2] as String? ?? '',
      topicListUrl: fields[3] as String? ?? '',
      categories: (fields[4] as List?)?.cast<Category>() ?? [],
      emoji: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconUrl)
      ..writeByte(3)
      ..write(obj.topicListUrl)
      ..writeByte(4)
      ..write(obj.categories)
      ..writeByte(5)
      ..write(obj.emoji);
  }
}