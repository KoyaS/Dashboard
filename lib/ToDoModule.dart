import 'dart:html';
import 'dart:convert';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ToDoModule extends StatefulWidget {
  String profileDataString;
  final auth.AutoRefreshingAuthClient client;
  ToDoModule({@required this.client});

  @override
  _ToDoModuleState createState() => _ToDoModuleState();
}

class _ToDoModuleState extends State<ToDoModule> {
  static final List<String> tasks = [
    'Eat pork',
    'Swim upstream',
    'Load the car',
    'Bonfire in the suburbs',
    'Wedding preperation long task name longlonglonglonglonglonglonglonglonglonglong'
  ];
  List<Task> taskObjects;

  @override
  Widget build(BuildContext context) {
    print('prof data string');
    print(widget.profileDataString);
    // if (widget.profileDataString != null) {
    //   decodeTasksFromJSON(widget.profileDataString);
    // }
    // taskObjects = createTaskObjects(tasks);
    // taskObjects = decodeTasksFromJSON(widget.profileDataString);
    if (widget.profileDataString != null) {
      if (taskObjects == null) {
        // this is a clunky ass way of doing this
        taskObjects = decodeTasksFromJSON(widget.profileDataString);
      }
      return TaskList(
        taskObjects: taskObjects,
        taskCheckboxChanged: taskCheckboxChanged,
      );
    } else {
      if (widget.client == null) {
        return(Text('please log in'));
      } else {
        getProfileData('koyavsaito@gmail.com', widget.client);
        return (CircularProgressIndicator());
      }
    }
  }

  static List<Task> createTaskObjects(List<String> rawTasks) {
    List<Task> objectList = [];
    int index = 0;
    rawTasks.forEach((String task) {
      objectList.add(new Task(index: index, taskName: task, completed: false));
      index++;
    });
    return objectList;
  }

  void saveTasks() {
    // Sends current task list back to firebase
  }

  void getTasks() {
    // Retrieves current user's task list from firebase
    // projects/${DotEnv().env['GOOGLE_PROJECT_ID']}/databases/(default)/documents/${DotEnv().env['FIRESTORE_USER_PROFILE_PATH']}/koyavsaito@gmail.com
  }

  List<Task> decodeTasksFromJSON(String rawJSON) {
    print('decoding task string...');
    List<Task> taskObjectList = [];

    Map<String, dynamic> databaseOutput = json.decode(rawJSON);
    List<dynamic> taskList =
        databaseOutput['fields']['taskList']['arrayValue']['values'];

    int index = 0;
    taskList.forEach((task) {
      Map taskInfo = task['mapValue']['fields'];
      String taskName = taskInfo['task']['stringValue'];
      bool completed = taskInfo['completed']['booleanValue'];
      Task newTask =
          new Task(index: index, taskName: taskName, completed: completed);
      taskObjectList.add(newTask);
      index++;
    });

    return taskObjectList;
  }

  void taskCheckboxChanged(int index, bool newValue) {
    setState(() {
      taskObjects[index].completed = newValue;
    });
  }

  getProfileData(String email, auth.AutoRefreshingAuthClient authClient) async {
    print('getting saved profile data...');
    var profile = await authClient.get(
        'https://firestore.googleapis.com/v1beta1/projects/${DotEnv().env['GOOGLE_PROJECT_ID']}/databases/(default)/documents/${DotEnv().env['FIRESTORE_USER_PROFILE_PATH']}/' +
            email);
    // print('getProfileData:');
    // print(profile.body);
    // return (profile.body);
    setState(() {
      widget.profileDataString = profile.body;
    });
  }
}

class TaskList extends StatelessWidget {
  final List<Task> taskObjects;
  final Function taskCheckboxChanged;
  TaskList({@required this.taskObjects, @required this.taskCheckboxChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          children: taskObjects
              .map((taskObject) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TaskCard(
                    task: taskObject,
                    checkboxChanged: taskCheckboxChanged,
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

class TaskCard extends StatelessWidget {
  final Task task;
  final Function checkboxChanged;
  TaskCard({@required this.task, @required this.checkboxChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 400,
        height: 50,
        child: Container(
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Checkbox(
                  value: task.completed,
                  onChanged: (newValue) {
                    // task.completed = newValue;
                    checkboxChanged(task.index, newValue);
                  }),
            ),
            Expanded(
                flex: 9,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: EdgeInsets.only(right: 15),
                      child: Text(
                        task.taskName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                )),
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
  int index;
  String taskName;
  bool completed;
  Task(
      {@required this.index,
      @required this.taskName,
      @required this.completed});
}
