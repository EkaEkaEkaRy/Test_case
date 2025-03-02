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

  // диалоговое окно добавления или редактирования пользователя
  void addUser(BuildContext context, User? user) {
    final TextEditingController _imageController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _surnameController = TextEditingController();

    if (user != null) {
      _imageController.text = user.image;
      _nameController.text = user.name;
      _surnameController.text = user.surname;
    }

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 225, 255, 235),
        // заголовок диалогового окна
        title: user != null
            ? Text('Изменение пользователя')
            : Text('Добавление пользователя'),
        // форма
        content: Column(
          children: [
            // ввод картинки
            TextField(
              controller: _imageController,
              decoration: InputDecoration(hintText: 'Ссылка на картинку'),
            ),
            // ввод имени
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: InputDecoration(hintText: 'Имя'),
            ),
            // ввод фамилии
            TextField(
              controller: _surnameController,
              maxLength: 20,
              decoration: InputDecoration(hintText: 'Фамилия'),
            )
          ],
        ),
        // кнопки подтверждения
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 255, 28)),
            child: const Text('Ок',
                style: TextStyle(color: Colors.black, fontSize: 14.0)),
            onPressed: () {
              // проверка заполненности полей
              if (_imageController.text.isNotEmpty &&
                  _nameController.text.isNotEmpty &&
                  _surnameController.text.isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text('Есть незаполненные поля')));
              }
            },
          ),
          TextButton(
            child: const Text('Отмена',
                style: TextStyle(color: Colors.black, fontSize: 14.0)),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    ).then((bool? isConfirm) {
      // если добавление или изменение подтверждено
      if (isConfirm != null && isConfirm) {
        final User person = User(
            id: user != null ? user.id : 0,
            name: _nameController.text,
            surname: _surnameController.text,
            image: _imageController.text);
        setState(() {
          if (user != null) {
            // обновление пользователя
            _apiService.updateUser(person);
          } else {
            // добавление пользователя
            _apiService.addProduct(person);
          }
          //Navigator.pop(context);
        });
        Navigator.pop(context);
        // сообщение о подтверждении действия
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                user != null ? 'Пользователь изменен' : 'Пользователь добавлен',
                style: TextStyle(color: Colors.black, fontSize: 16.0)),
            backgroundColor: const Color.fromARGB(255, 43, 255, 0),
          ),
        );
      }
    });
  }

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
            return UsersList(usersList, context, addUser);
          }),
      // Кнопка добавления
      floatingActionButton: FloatingActionButton(
          onPressed: () => addUser(context, null), child: Icon(Icons.add)),
    );
  }
}

// виджет списка пользователей
Widget UsersList(List<User> users, BuildContext context, Function addUser) {
  return users.length == 0
      // если список пустой
      ? Center(child: Text('Нет пользователей'))
      // вывод списка пользователей
      : ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return UserContainer(users[index], context, addUser);
          });
}

// контейнер пользователя
Widget UserContainer(User user, BuildContext context, Function addUser) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
      child: Column(
        children: [
          // информация о пользователе
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // изображение
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Image.network(
                        user.image,
                        fit: BoxFit.cover,
                        // загрузка картинки
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator();
                        },
                        // если картинки нет
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey),
                              child: Center(child: Text('нет')));
                        },
                      )),
                ),
                // Имя и фамилия
                Padding(
                    padding: const EdgeInsets.all(3.0), child: Text(user.name)),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(user.surname))
              ],
            ),
          ),
          // кнопки редактирования и удаления
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () => addUser(context, user),
                  icon: Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: Icon(Icons.delete))
            ],
          )
        ],
      ),
    ),
  );
}
