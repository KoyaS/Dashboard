import 'dart:html';
import 'dart:convert';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    // print('prof data string');
    // print(widget.profileDataString);
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
        return (Text('please log in'));
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
      if (widget.client != null) {
        print('Setting ' +
            taskObjects[index].taskName.toString() +
            ' to ' +
            newValue.toString());
        taskObjects[index].completed = newValue;
        updateFieldState(
            'fguacamole@gmail.com', taskObjects[index].taskName, newValue);
      } else {
        print('client is null and this was called somehow, to do module');
      }
    });
  }

  void getProfileData(
      String email, auth.AutoRefreshingAuthClient authClient) async {
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

  void updateFieldState(String email, String field, bool newValue) {
    print('saving profile data with field: ' + field);

    String userPath =
        'projects/${DotEnv().env['GOOGLE_PROJECT_ID']}/databases/(default)/${DotEnv().env['FIRESTORE_USER_PROFILE_PATH']}/${email}';

    Map testBody = {
      "name":
          "projects/flutter-dashboard-280203/databases/(default)/documents/Root/userData/Profiles/fguacamole@gmail.com",
      // "fields": {
      //   field: {"booleanValue": newValue}
      // }
    };

    // widget.client.send(http.Request('PATCH', Uri.parse('https://firestore.googleapis.com/v1beta1/${userPath}?updateMask.fieldPaths=${field}',)));
    // print(createFieldBody(field, newValue, userPath));
    // widget.client.patch(
    //   'http://firestore.googleapis.com/v1beta1/${userPath}?updateMask.fieldPaths=${field}',
    //   body: createFieldBody(field, newValue, userPath),
    //   // body: testBody,
    //   headers: {
    //     'Access-Control-Allow-Origin': '*',
    //     // 'Access-Control-Allow-Credentials': 'true',
    //     // 'credentials': 'include',
    //     // 'mode': 'cors',
    //     'Accept': 'application/json',
    //     'Content-Type': 'application/json',
    //   }
    // );

    widget.client.patch(
      'http://firestore.googleapis.com/v1beta1/${userPath}?updateMask.fieldPaths=${field}',
      body: '{"name":"projects/flutter-dashboard-280203/databases/(default)/documents/Root/userData/Profiles/fguacamole@gmail.com","fields":{"tes":{"booleanValue":false}}}'
    );
  }

  String createFieldBody(String field, var value, String userPath) {
    String fieldString = '"${field}":' + createValueHolder(value);
    return ('''{
      "name": ${userPath},
      "fields": {${fieldString}}
    }''');
  }

  String createValueHolder(var value) {
    String valueHolder = '';
    if (value is int) {
      valueHolder = '"integerValue":' + value.toString();
    } else if (value is bool) {
      valueHolder = '"booleanValue":';
      if (value == true) {
        valueHolder += 'true';
      } else {
        valueHolder += 'false';
      }
    } else if (value is String) {
      valueHolder = '"stringValue":"${value.toString()}"';
    } else if (value is List) {
      int count = 1;
      String listHolder = '';
      for (var v in value) {
        //valueHolder = createValueHolder(v);
        listHolder += createValueHolder(v);
        if (count != value.length) {
          listHolder += ',';
        }
        count++;
        if (v is List) {
          print('Database no like nested arrays');
          return (null);
        }
      }
      valueHolder = '"arrayValue":{"values":[${listHolder}]}';
    }
    return ('{${valueHolder}}');
  }
}

class TaskList extends StatelessWidget {
  final List<Task> taskObjects;
  final Function taskCheckboxChanged;
  TaskList({@required this.taskObjects, @required this.taskCheckboxChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
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
        color: Colors.white,
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
