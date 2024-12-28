import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/authentication/auth_page/login_page.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/widget/todo_item.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readItems();
  }

  void readItems() async {
    var doc = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).get();

    for (var item in doc.get("items")) {
      setState(
        () {
          todosList.add(
            ToDo(
              id: item["id"],
              todoText: item["text"],
              isDone: item["done"]
            ),
          );
        },
      );
    }
    setState(
      () {
        _foundToDo = todosList;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
      ),
      drawer: Drawer(
        width: 250,
        child: Container(
          color: tdBGColor,
          child: ListView(
            children: [
              DrawerHeader(
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: tdBGColor),
                  accountName: Text(
                    FirebaseAuth.instance.currentUser!.displayName.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  accountEmail: Text(
                    FirebaseAuth.instance.currentUser!.email.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.logout,
                    color: const Color.fromARGB(255, 10, 10, 10),
                  ),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                SearchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 30,
                          bottom: 20,
                        ),
                        child: Text(
                          'All ToDos',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      for (ToDo todo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    right: 20,
                    bottom: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _addTodoItem(_todoController.text);
                    },
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      minimumSize: Size(60, 60),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });

    List<Map> updatedList = [];

    for(var item in todosList) {
      updatedList.add({"id": item.id, "text": item.todoText, "done": item.isDone});
    }

    FirebaseFirestore.instance.collection("users").doc(
        FirebaseAuth.instance.currentUser?.uid).update({
      "items": updatedList
    });
  }

  void _deleteToDoItem(ToDo todo) {

    setState(() {
      todosList.removeWhere((item) => item.id == todo.id);
    });
    FirebaseFirestore.instance.collection("users").doc(
        FirebaseAuth.instance.currentUser?.uid).update({
      "items": FieldValue.arrayRemove([
        {"id": todo.id, "text": todo.todoText, "done": todo.isDone}
      ])
    });
  }

  void _addTodoItem(String toDo) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(
      {
        "items": FieldValue.arrayUnion(
          [
            {"id": id, "text": toDo, "done": false}
          ],
        )
      },
    );
    setState(() {
      todosList.add(
        ToDo(
          id: id,
          todoText: toDo,
        ),
      );
    });
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundToDo = results;
    });
  }

  Widget SearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          onChanged: (value) => _runFilter(value),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.search,
                color: tdBlack,
                size: 20,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              maxHeight: 20,
              minWidth: 35,
            ),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(
              color: tdGrey,
            ),
          ),
        ),
      ),
    );
  }
}
