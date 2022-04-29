import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/Database/Database.dart';
import 'package:todo_app/Database/Models/Todo.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoListWidget extends StatefulWidget {
  @override
  _TodoListWidgetState createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Todo> todoList;
  int count = 0;

  DatabaseHelper helper = DatabaseHelper();

  final _form = GlobalKey<FormState>(); //for storing form state.
  final titleText = TextEditingController();
  final descriptionText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = [];
      updateListView();
    }

    return Scaffold(
      body: FractionallySizedBox(
        heightFactor: 0.9,
        child: ListView.builder(
          itemCount: count,
          itemBuilder: (BuildContext context, int position) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              key: Key(this.todoList[position].id.toString()),
              secondaryActions: [
                IconSlideAction(
                  color: Colors.red,
                  caption: 'Delete',
                  onTap: () => {delete(this.todoList[position].id)},
                  icon: Icons.delete,
                )
              ],
              child: Card(
                color: Colors.white,
                elevation: 2.0,
                child: CheckboxListTile(
                  title: Text(this.todoList[position].title),
                  subtitle: Text(this.todoList[position].description),
                  value: this.todoList[position].done > 0 ? true : false,
                  onChanged: (bool value) {
                    setState(() {
                      Todo temp = this.todoList[position];
                      temp.done = value ? 1 : 0;
                      update(temp);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add Todo'),
            content: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleText,
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Field can not be empty';
                      }
                    },
                  ),
                  TextFormField(
                    controller: descriptionText,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () {
                        final isValid = _form.currentState.validate();
                        if (!isValid) {
                          return;
                        }

                        insert(Todo(
                          title: titleText.text,
                          description: descriptionText.text.isEmpty
                              ? ''
                              : descriptionText.text,
                          done: 0,
                        ));
                        Navigator.pop(context);
                        titleText.clear();
                        descriptionText.clear();
                      },
                      child: Text('Add Todo')))
            ],
          ),
          barrierDismissible: true,
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  void insert(Todo todo) async {
    int result = await helper.insertTodo(todo);
    updateListView();
  }

  void update(Todo todo) async {
    int result = await helper.updateTodo(todo);
    updateListView();
  }

  void delete(int id) async {
    int result = await helper.deleteTodo(id);
    updateListView();
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          this.count = todoList.length;
        });
      });
    });
  }
}
