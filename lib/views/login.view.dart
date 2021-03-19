// import 'package:fl_andro_x/components/login.loader.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/encryption/backup.dart';
import 'package:fl_andro_x/encryption/main.dart';
import 'package:fl_andro_x/hivedb/secureStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class LoginView extends StatelessWidget {
  static final routeName = '/login';
  Duration get loginTime => Duration(milliseconds: 2250);
  static const platform = const MethodChannel('crypto');

  Future<String> _registerUser(LoginData data) async {
    // await Future.delayed(this.loginTime);
    try {
      final auth = FirebaseAuth.instance;
      final encry = await platform.invokeMethod('generateKeyPair');
      await auth.createUserWithEmailAndPassword(
          email: data.name, password: data.password);
      final photoUrl = await firebase_storage.FirebaseStorage.instance.ref(Storage.defaultUserPhoto).getDownloadURL();
      await auth.currentUser.updateProfile(displayName: data.name.split('@')[0], photoURL: photoUrl);
      final userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser.uid);
      // final payloadForBackup = {'password': data.password.toString(), 'salt': data.name.toString(),'privateRsaKey': encry['privateKeyRsa']};
      // debugPrint(payloadForBackup.toString());
      // debugPrint(encry['privateKeyRsa'].length.toString());
      // final backupPrivateRsaKey = await platform.invokeMethod('saveBackupKey', payloadForBackup);
      // debugPrint('Backup keys encrypted');
      await userRef.set({
        'publicKeyRsa': encry['publicKeyRsa'],
        'username': data.name.split('@')[0],
        'avatar': photoUrl
        // 'backupPrivateRsaKey': {'encryptedBackup': backupPrivateRsaKey['encryptedBackup'], 'IV': backupPrivateRsaKey['IV']},
      });
      final store = new SecureStore();
      store.privateKeyRsa = encry['privateKeyRsa'];
      store.publicKeyRsa = encry['publicKeyRsa'];
      await Hive.box<SecureStore>('SecureStore').put('store', store);
      String fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await userRef.collection('tokens').doc(fcmToken).set({
          'createdAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
          'platformVersion': Platform.operatingSystemVersion
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Your password is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'This email is busy';
      }
    } catch (e) {
      print(e);
      return 'Unhandled error.';
    }

    return null;
  }

  Future<String> _loginUser(LoginData data) async {
    // await Future.delayed(this.loginTime);
    try {
      final auth = FirebaseAuth.instance;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: data.name, password: data.password);
      await auth.currentUser.updateProfile(displayName: data.name.split('@')[0]);
      // var userRef = (await FirebaseFirestore.instance
      //         .collection('Users')
      //         .doc(auth.currentUser.uid)
      //         .get())
      //     .data();

      // final privateRsaKey = await platform.invokeMethod('restoreBackupKey', {'password': data.password, 'salt': data.name, 'IV': userRef['backupPrivateRsaKey']['IV'], 'cipherText': userRef['backupPrivateRsaKey']['encryptedBackup']});

      // final store = new SecureStore();
      // store.privateKeyRsa = privateRsaKey;
      // store.publicKeyRsa = userRef['publicKeyRsa'];
      // await Hive.box<SecureStore>('SecureStore').put('store', store);
      
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else {
        return 'Firebase exception ${e.code}';
      }
    } catch (e) {
      print(e);
      return 'Unhandled error.';
    }
  }

  Future<String> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return 'Email has been sended';
    } on FirebaseAuthException catch (e) {
      return 'Firebase exception ${e.code}';
    } catch (e) {
      print(e);
      return 'Unhandled error.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'AndroX',
      logo: Assets.logo,
      onLogin: _loginUser,
      onSignup: _registerUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      },
      onRecoverPassword: _recoverPassword,
      theme: LoginTheme(
          titleStyle: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
          cardTheme: CardTheme(margin: EdgeInsets.only(top: 15)),
          inputTheme: InputDecorationTheme(filled: true)),
    );
  }
}
