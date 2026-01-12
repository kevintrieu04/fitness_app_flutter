import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

final firebaseAuthProvider =
Provider<FirebaseAuth>((_) => FirebaseAuth.instance);

// Add this stream provider
final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final firestoreProvider =
Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
