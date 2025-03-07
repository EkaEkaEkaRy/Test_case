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
  Future<List<User>>? _futureUsers;

  @override
  void initState() {
    super.initState();
    // Загружаем список пользователей при старте
    _fetchUsers();
  }

  // обновление списка
  void _fetchUsers() {
    setState(() {
      _futureUsers = _apiService.getUsers();
    });
  }

  // диалоговое окно добавления или редактирования пользователя
  void _addUser(BuildContext context, User? user) {
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
    ).then((bool? isConfirm) async {
      // если добавление или изменение подтверждено
      if (isConfirm != null && isConfirm) {
        final User person = User(
            id: user != null ? user.id : 0,
            name: _nameController.text,
            surname: _surnameController.text,
            image: _imageController.text);
        try {
          if (user != null) {
            // обновление пользователя
            await _apiService.updateUser(person);
          } else {
            // добавление пользователя
            await _apiService.addProduct(person);
          }
          // обновляем список после изменения
          _fetchUsers();
          setState(() {});
          // сообщение о подтверждении действия
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  user != null
                      ? 'Пользователь изменен'
                      : 'Пользователь добавлен',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
              backgroundColor: const Color.fromARGB(255, 43, 255, 0),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  user != null
                      ? 'Не удалось изменить пользователя'
                      : 'Не удалось добавить пользователя',
                  style: TextStyle(color: Colors.white, fontSize: 16.0)),
              backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            ),
          );
        }
      }
    });
  }

  void _deleteUser(BuildContext context, int id) async {
    try {
      await _apiService.deleteUser(id);
      // обновляем список после удаления
      _fetchUsers();
      setState(() {});
      // сообщение о подтверждении действия
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пользователь удален',
              style: TextStyle(color: Colors.black, fontSize: 16.0)),
          backgroundColor: const Color.fromARGB(255, 43, 255, 0),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось удалить пользователя',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        ),
      );
    }
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
          future: _futureUsers,
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
            return UsersList(usersList, context, _addUser, _deleteUser);
          }),
      // Кнопка добавления
      floatingActionButton: FloatingActionButton(
          onPressed: () => _addUser(context, null), child: Icon(Icons.add)),
    );
  }
}

// виджет списка пользователей
Widget UsersList(List<User> users, BuildContext context, Function _addUser,
    Function _deleteUser) {
  return users.length == 0
      // если список пустой
      ? Center(child: Text('Нет пользователей'))
      // вывод списка пользователей
      : ListView.builder(
          itemCount: users.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return index == users.length
                ? SizedBox(height: 60)
                : UserContainer(users[index], context, _addUser, _deleteUser);
          });
}

// контейнер пользователя
Widget UserContainer(
    User user, BuildContext context, Function _addUser, Function _deleteUser) {
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
                  onPressed: () => _addUser(context, user),
                  icon: Icon(Icons.edit)),
              IconButton(
                  onPressed: () => _deleteUser(context, user.id),
                  icon: Icon(Icons.delete))
            ],
          )
        ],
      ),
    ),
  );
}
