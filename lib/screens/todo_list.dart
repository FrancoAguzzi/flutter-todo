import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/screens/todo_detail.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> list = [];

  @override
  void initState() {
    _loadList();
    super.initState();
  }

  _loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('todoList');
    if (data != null) {
      setState(() {
        var objs = jsonDecode(data) as List;
        list = objs.map((obj) => Todo.fromJson(obj)).toList();
      });
    }
  }

  _removeItem(int index) {
    setState(() {
      list.removeAt(index);
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('todoList', jsonEncode(list));
    });
  }

  _doneItem(int index) {
    setState(() {
      list[index].status = 'F';
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('todoList', jsonEncode(list));
    });
  }

  _showAlertDialog(BuildContext context, String text, Function confirmationFct, int index) {
    showDialog(
        context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirme sua ação"),
          content: Text(text),
          actions: [
            FlatButton(onPressed: () => Navigator.pop(context), child: Text('Não')),
            FlatButton(
              onPressed: () {
                confirmationFct(index);
                Navigator.pop(context);
              },
              child: Text('Sim')
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo List App'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                list[index].titulo,
                style: list[index].status == 'F' ? TextStyle(color: Colors.green, decoration: TextDecoration.lineThrough) : null,
              ),
              subtitle: Text(list[index].descricao),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(icon: Icon(Icons.clear), onPressed: () => _showAlertDialog(context, 'Deseja excluir este item?', _removeItem, index)),
                  Visibility(
                      visible: list[index].status == 'A',
                      child: IconButton(icon: Icon(Icons.check), onPressed: () => _showAlertDialog(context, 'Deseja finalizar este item?', _doneItem, index))
                  )
                ],
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TodoDetail(todo: list[index], index: index),
                  )
              ).then((value) => _loadList()),
            );
          },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetail(todo: null, index: -1),
            )
        ).then((value) => _loadList()),
      ),
    );
  }
}
