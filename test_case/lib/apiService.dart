import 'package:dio/dio.dart';
import 'package:test_case/backend_link.dart';
import 'package:test_case/models/user.dart';

class Apiservice {
  // инициализация библиотек
  final Dio _dio = Dio();

  // получение всех пользователей
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('${backend_link}users');
      if (response.statusCode == 200) {
        List<User> users = (response.data as List)
            .map((users) => User.parseJson(users))
            .toList();

        return users;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // получение одного пользователя по id
  Future<User> getUserByID(int id) async {
    try {
      final response = await _dio.get('${backend_link}users/$id');
      if (response.statusCode == 200) {
        User user = User.parseJson(response.data);
        return user;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('e');
    }
  }

  // добавление нового пользователя
  Future<void> addProduct(User person) async {
    final link = '${backend_link}users/create';
    try {
      final response = await _dio.post(link, data: {
        'Name': person.name,
        'Surname': person.surname,
        'Image': person.image,
      });
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // одновление пользователя по id
  Future<void> updateUser(User person) async {
    final link = '${backend_link}users/update/${person.id}';
    try {
      final response = await _dio.put(link, data: {
        'Name': person.name,
        'Surname': person.surname,
        'Image': person.image,
      });
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // удаление пользователя по id
  Future<void> deleteUser(int id) async {
    final link = '${backend_link}users/delete/$id';
    try {
      final response = await _dio.delete(link);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
