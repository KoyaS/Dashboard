import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

class EmailModule extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  EmailModule({this.gmailApi});

  @override
  _EmailModuleState createState() => _EmailModuleState();
}

class _EmailModuleState extends State<EmailModule> {
  // Future _emailFuture;

  @override
  void initState() {
    // _emailFuture = getEmails(widget.gmailApi);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gmailApi == null) {
      return (Text('please log in'));
    } else {
      return (FutureBuilder(
          future: getEmails(widget.gmailApi),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return (Text('none'));
              case ConnectionState.waiting:
                return (EmailModuleContainer(
                    contents: CircularProgressIndicator()));
              case ConnectionState.active:
                return (Text('active'));
              case ConnectionState.done:
                if (snapshot.data != null) {
                  return (EmailModuleContainer(
                    contents: EmailList(
                      emailList: snapshot.data,
                    ),
                  ));
                } else {
                  return (Text('hi'));
                }
                return (Text('will never get here'));
              default:
                return (Text('default'));
            }
          }));
    }
  }
}

class EmailList extends StatelessWidget {
  final List<Email> emailList;

  EmailList({this.emailList});

  @override
  Widget build(BuildContext context) {
    var filteredEmails = filterEmails(emailList, ['CATEGORY_PERSONAL']);
    List<Widget> emailListCards = new List();

    filteredEmails.forEach((email) {
      emailListCards.add(EmailListCard(
        from: email.headers['From'],
        snippet: email.snippet,
        subject: email.headers['Subject'],
      ));
    });
    return Container(
        width: double.infinity,
        child: ListView(
          children: emailListCards,
        ));
  }
}

class EmailListCard extends StatelessWidget {
  final String from;
  final String snippet;
  final String subject;

  EmailListCard(
      {@required this.from, @required this.snippet, @required this.subject});

  @override
  Widget build(BuildContext context) {
    var croppedFrom = from.split('<')[0];
    return SizedBox(
      width: 400,
      height: 100,
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(croppedFrom, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,)),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(subject, style: Theme.of(context).textTheme.headline6,),
                      ),
                    ],
                  )),
              Flexible(
                flex: 4,
                child: Text(snippet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailModuleContainer extends StatelessWidget {
  final double borderRadius = 10;
  final Widget contents;

  EmailModuleContainer({@required this.contents});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      width: 400,
      height: 400,
      // padding: EdgeInsets.symmetric(horizontal:10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(padding: EdgeInsets.only(), child:Flexible(flex: 1, child: Text('Mail', style: TextStyle(color: Colors.black, fontSize: 40)))),
          Flexible(flex: 3, child:contents),
          ],
        ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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

Future<List<Email>> getEmails(gmail.GmailApi api) async {
  print('getting messages...');
  return (await api.users.messages
      .list('me')
      .then((gmail.ListMessagesResponse messagesResponse) async {
    List<Map> messageIDs = messagesResponse.toJson()[
        'messages']; // keys: messages, nextPageToken, resultSizeEstimate
    return (parseIDs(messageIDs, api));
  }));
}

Future<List<Email>> parseIDs(List<Map> messageIDs, gmail.GmailApi api) async {
  List<Email> emailList = [];

  for (var ids in messageIDs) {
    await api.users.threads
        .get('me', ids['threadId'])
        .then((gmail.Thread value) {
      value.messages.forEach((message) {
        var rawHeaders = message.payload.headers;
        Map messageHeaders = Map.fromIterable(rawHeaders,
            key: (item) => item.name, value: (item) => item.value);

        emailList.add(new Email(
            headers: messageHeaders,
            labelIDs: message.labelIds,
            snippet: message.snippet));
      });
    });
  }
  return (emailList);
}

List<Email> filterEmails(List<Email> emails, List categories) {
  print('filtering emails...');
  List<Email> filteredEmails = [];

  emails.forEach((email) {
    categories.forEach((category) {
      if (email.labelIDs.contains(category) &&
          !filteredEmails.contains(email)) {
        filteredEmails.add(email);
      }
    });
  });
  return (filteredEmails);
}

class Email {
  // Headers are:
  // Delivered-To, Received, X-Received, ARC-Seal, ARC-Message-Signature, ARC-Authentication-Results
  // Return-Path, Received, Received-SPF, Authentication-Results, DKIM-Signature, X-Google-DKIM-Signature,
  // X-Gm-Message-State, X-Google-Smtp-Source, MIME-Version, X-Received, Date, List-Unsubscribe, X-Google-Id
  // X-Feedback-Id, X-No-Auto-Attachment, Message-ID, Subject, From, To, Content-Type
  final Map headers;

  // labelID categories are:
  //  INBOX, SPAM, TRASH, UNREAD, STARRED, IMPORTANT, SENT,
  //  DRAFT, CATEGORY_PERSONAL, CATEGORY_SOCIAL, CATEGORY_PROMOTIONS,
  //  CATEGORY_UPDATES, CATEGORY_FORUMS
  final List labelIDs;

  // Summary of the messsage
  final String snippet;

  Email(
      {@required this.headers,
      @required this.labelIDs,
      @required this.snippet});
}
