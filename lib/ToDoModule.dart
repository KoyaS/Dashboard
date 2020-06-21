import 'dart:html';

import 'package:flutter/material.dart';

class ToDoModule extends StatefulWidget {
  @override
  _ToDoModuleState createState() => _ToDoModuleState();
}

class _ToDoModuleState extends State<ToDoModule> {
  final List<String> tasks = [
    'Eat pork',
    'Swim upstream',
    'Load the car',
    'Bonfire in the suburbs',
    'Wedding preperation long task name'
  ];
  List<Task> taskObjects = [];

  @override
  Widget build(BuildContext context) {
    tasks.forEach((String task) {
      taskObjects.add(new Task(taskName: task, completed: false));
    });
    return Container(
      width: 400,
      height: 400,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10),
          children: taskObjects
              .map((taskObject) => Container(
                margin: EdgeInsets.only(bottom:10),
                      child: TaskCard(
                    task: taskObject,
                  )))
              .toList()),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 6),
              color: Colors.grey,
              spreadRadius: 2)
        ],
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  Task task;

  TaskCard({this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 400,
        height: 50,
        child: Container(
          child: Row(children: [
            Checkbox(
                value: false,
                onChanged: (newValue) {
                  widget.task.completed = newValue;
                  // setState(() {
                  //   widget.task.completed = newValue;
                  // });
                }),
            Spacer(),
            Container(
                padding: EdgeInsets.only(right: 15),
                child: Text(widget.task.taskName)),
          ]),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                  blurRadius: 6,
                  offset: Offset(0, 6),
                  color: Colors.grey,
                  spreadRadius: 2)
            ],
          ),
        ));
  }
}

class Task {
  String taskName;
  bool completed;
  Task({this.taskName, this.completed});
}
