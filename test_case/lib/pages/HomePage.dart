import 'package:flutter/material.dart';
import 'package:test_case/apiService.dart';
import 'package:test_case/models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiService = Apiservice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      // Хедер страницы
      appBar: AppBar(
        title: Text(
          'Список пользователей',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      // Получение списка пользователей пользователей
      body: FutureBuilder(
          future: _apiService.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // ожидание списка
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // ошибка получения
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Пользователи не найдены'));
            }
            final usersList = snapshot.data!;
            return UsersList(usersList, context);
          }),
      // Кнопка добавления
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
    );
  }
}

// виджет списка пользователей
Widget UsersList(List<User> users, BuildContext context) {
  return users.length == 0
      // если список пустой
      ? Center(child: Text('Нет пользователей'))
      // вывод списка пользователей
      : ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return UserContainer(users[index]);
          });
}

// контейнер пользователя
Widget UserContainer(User user) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
      child: Column(
        children: [
          // информация о пользователе
          Row(
            children: [
              // изображение
              Container(
                  height: 20,
                  width: 20,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                  child: Image.network(user.image)),
              // Имя и фамилия
              Text(user.name),
              Text(user.surname)
            ],
          ),
          // кнопки редактирования и удаления
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: Icon(Icons.delete))
            ],
          )
        ],
      ),
    ),
  );
}
