import 'package:dio/dio.dart';
import 'package:test_case/models/user.dart';

class Apiservice {
  final Dio _dio = Dio();
  final ip = '';

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('http://$ip:8080/users');
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

  Future<User> getUserByID(int id) async {
    try {
      final response = await _dio.get('http://$ip:8080/users/$id');
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

  Future<void> addProduct(User person) async {
    final link = 'http://$ip:8080/users/create';
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

  Future<void> updateUser(User person) async {
    final link = 'http://$ip:8080/users/update/${person.id}';
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

  Future<void> deleteUser(int id) async {
    final link = 'http://$ip:8080/users/delete/$id';
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
