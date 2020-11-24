import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/todo.dart';

class TodoDetail extends StatefulWidget {
  final Todo todo;
  final int index;
  TodoDetail({Key key, @required this.todo, @required this.index}) : super(key: key);

  @override
  _TodoDetailState createState() => _TodoDetailState(todo, index);
}

class _TodoDetailState extends State<TodoDetail> {
  Todo _todo;
  int _index;
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final key = GlobalKey<ScaffoldState>();
  _TodoDetailState(Todo todo, int index) {
    this._todo = todo;
    this._index= index;
    if (_todo != null) {
      _tituloController.text = _todo.titulo;
      _descricaoController.text = _todo.descricao;
    }
  }

  _saveTodo() async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      key.currentState.showSnackBar(SnackBar(content: Text('Please write a title and a description.')));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Todo> list = [];
      var data = prefs.getString('todoList');
      if (data != null) {
        var objs = jsonDecode(data) as List;
        list = objs.map((obj) => Todo.fromJson(obj)).toList();
      }
      _todo = Todo.fromTituloDesc(
          _tituloController.text, _descricaoController.text);
      if (_index != -1) {
        list[_index] = _todo;
      } else {
        list.add(_todo);
      }
      prefs.setString('todoList', jsonEncode(list));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo Details'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder()
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                  hintText: 'Description',
                border: OutlineInputBorder()
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              minWidth: double.infinity,
              child: RaisedButton(
                child: Text('Save'),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  _saveTodo();
                },
              ),
            ),
          )
        ],
      )
    );
  }
}
