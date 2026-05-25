import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String name;

  UserModel({required this.id, required this.email, required this.name});
}

// Placeholder for the generated adapter
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.read(),
      email: reader.read(),
      name: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.id);
    writer.write(obj.email);
    writer.write(obj.name);
  }
}
