import 'package:flutter/foundation.dart';

class Todo {
  int id;
  String title;
  String description;
  int done;

  Todo({
      @required this.title,
      @required this.description,
      @required this.done,
      });

      Map<String, dynamic> toMap() {
        return {
          'id': id,
          'title': title,
          'description': description,
          'done': done,
        };
      }

      	Todo.fromMapObject(Map<String, dynamic> map) {
        this.id = map['id'];
        this.title = map['title'];
        this.description = map['description'];
        this.done = map['done'];
	}

      @override
      String toString() {
        return 'Todo{id: $id, name: $title, description: $description}, done: $done}';
      }
}
