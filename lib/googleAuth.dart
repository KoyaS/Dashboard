import 'dart:html';

import 'package:flutter/material.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List> showSignInPopup(BuildContext context) async {
  gmail.GmailApi api;
  auth.AutoRefreshingAuthClient client;

  await showDialog(
      context: context,
      builder: (BuildContext context) => Center(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                height: 150,
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign in',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SignInButton(
                      Buttons.Google,
                      onPressed: () async {
                        final List ref_client = await authorize();
                        // api = await authorize();
                        api = ref_client[0];
                        client = ref_client[1];
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )),
          ));
  // String profileDataString = await getProfileData('koyavsaito@gmail.com', client);
  return ([api, client]);
}

Future<List> authorize() async {
  print('authorizing...');
  var id = new auth.ClientId(DotEnv().env['GOOGLE_APP_ID'], null);

  var scopes = [
    gmail.GmailApi.GmailReadonlyScope,
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/datastore',
    // 'https://www.googleapis.com/auth/cloud-platform',
  ]; // gmail, profile photo

  List apiRef_authedClient = await auth
      .createImplicitBrowserFlow(id, scopes)
      .then((auth.BrowserOAuth2Flow flow) async {
    return (await flow
        .clientViaUserConsent()
        .then((auth.AutoRefreshingAuthClient client) {
      flow.close();
      return ([gmail.GmailApi(client), client]);
    }));
  });
  return (apiRef_authedClient);
}

// Future<String> getProfileData(String email, auth.AutoRefreshingAuthClient authClient) async {
//   print('getting saved profile data...');
//   var profile = await authClient.get(
//       'https://firestore.googleapis.com/v1beta1/projects/${DotEnv().env['GOOGLE_PROJECT_ID']}/databases/(default)/documents/${DotEnv().env['FIRESTORE_USER_PROFILE_PATH']}/' +
//           email);
//   // print('getProfileData:');
//   // print(profile.body);
//   return(profile.body);
// }
