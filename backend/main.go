package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
)

type User struct {
	ID      int
	Name    string
	Surname string
	Image   string
}

var users = []User{
	{
		ID:      1,
		Name:    "Иван",
		Surname: "Иванов",
		Image:   "https://cdn-icons-png.flaticon.com/512/3177/3177440.png",
	},
	{
		ID:      2,
		Name:    "Петр",
		Surname: "Петров",
		Image:   "https://cdn-icons-png.flaticon.com/512/3177/3177440.png",
	},
	{
		ID:      3,
		Name:    "Елена",
		Surname: "Сидорова",
		Image:   "https://cdn-icons-png.flaticon.com/512/3177/3177440.png",
	},
	{
		ID:      4,
		Name:    "Ольга",
		Surname: "Смирнова",
		Image:   "https://cdn-icons-png.flaticon.com/512/3177/3177440.png",
	},
	{
		ID:      5,
		Name:    "Алексей",
		Surname: "Кузнецов",
		Image:   "https://cdn-icons-png.flaticon.com/512/3177/3177440.png",
	},
}

type Response struct {
	Message string `json:"message"`
}

// обработчик для GET-запроса
func getUsersHandler(w http.ResponseWriter, r *http.Request) {
	// Устанавливаем заголовки для правильного формата JSON
	w.Header().Set("Content-Type", "application/json")
	// Преобразуем список заметок в JSON
	json.NewEncoder(w).Encode(users)
}

// обработчик для POST-запроса
func createUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var newUser User
	err := json.NewDecoder(r.Body).Decode(&newUser)
	if err != nil {
		fmt.Println("Error decoding request body:", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Printf("Received new Product: %+v\n", newUser)

	newUser.ID = users[len(users)-1].ID + 1
	users = append(users, newUser)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(newUser)
}

func getUserByIDHandler(w http.ResponseWriter, r *http.Request) {
	// Получаем ID из URL
	idStr := r.URL.Path[len("/users/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}

	// Ищем пользователя с данным ID
	for _, Users := range users {
		if Users.ID == id {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(Users)
			return
		}
	}

	// Если пользователь не найден
	http.Error(w, "Product not found", http.StatusNotFound)
}

// удаление пользователя по id
func deleteUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Получаем ID из URL
	idStr := r.URL.Path[len("/users/delete/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}

	// Ищем и удаляем пользователя с данным ID
	for i, Product := range users {
		if Product.ID == id {
			users = append(users[:i], users[i+1:]...)
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			json.NewEncoder(w).Encode(Response{Message: "User deleted successfully"})
			return
		}
	}

	// Если пользователь не найден
	http.Error(w, "Product not found", http.StatusNotFound)
}

// Обновление пользователя по id
func updateUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}
	// Получаем ID из URL
	idStr := r.URL.Path[len("/users/update/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}

	// Декодируем обновлённые данные пользователя
	var updatedUser User
	err = json.NewDecoder(r.Body).Decode(&updatedUser)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Ищем пользователя для обновления
	for i, User := range users {
		if User.ID == id {
			users[i].Name = updatedUser.Name
			users[i].Surname = updatedUser.Surname
			users[i].Image = updatedUser.Image

			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(users[i])
			return
		}
	}

	// Если пользователь не найден
	http.Error(w, "Product not found", http.StatusNotFound)
}

func main() {
	http.HandleFunc("/users", getUsersHandler)           // Получить всех пользователей
	http.HandleFunc("/users/create", createUserHandler)  // Создать пользователя
	http.HandleFunc("/users/", getUserByIDHandler)       // Получить пользователя по ID
	http.HandleFunc("/users/update/", updateUserHandler) // Обновить пользователя
	http.HandleFunc("/users/delete/", deleteUserHandler) // Удалить пользователя

	fmt.Println("Server is running on port 8080!")
	http.ListenAndServe(":8080", nil)
}
