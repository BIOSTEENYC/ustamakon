import 'package:hive/hive.dart';
import 'package:ustamakon/models/category.dart';
import 'package:ustamakon/models/guide.dart';

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Category(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? 'Nomaʼlum kategoriya',
      iconEmoji: fields[2] as String? ?? '',
      guides: (fields[3] as List?)?.cast<Guide>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1) // <-- BU YO‘Q EDI, TUZATILDI
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconEmoji)
      ..writeByte(3)
      ..write(obj.guides);
  }
}