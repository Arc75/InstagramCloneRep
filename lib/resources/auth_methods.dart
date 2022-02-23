import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String url = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        await _fireStore.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
          'photoUrl' : url,
        });

        res = "success";
      } 
    } on FirebaseAuthException catch(ex){
      if (ex.code == 'invalid-email'){
        res = 'The email is badly formatted';
      }
      if (ex.code == 'weak-password'){
        res = 'The password should be at least 6 characters';
      }
    }
    
    catch (error) {
      res = error.toString();
    }

    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password
  }) async {
    String res = 'Some error occured';

    try {
        if (email.isNotEmpty || password.isNotEmpty){
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          res = 'success';
        }
        else{
          res = 'Please enter all the fields';
        }
    }
    on FirebaseAuthException catch (ex){
      if (ex.code == 'user-not-found'){
        res = 'Please register first';
      }
      if (ex.code == 'wrong-password'){
        res = 'The password is incorrect';
      }
    }
    catch (ex){
      res = ex.toString();
    }

    return res;
  }
}
