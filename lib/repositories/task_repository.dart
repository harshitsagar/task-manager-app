import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager_app/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRepository()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _tasksRef =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  Stream<List<Task>> getTasks() {
    return _tasksRef
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addTask(Task task) async {
    await _tasksRef.add(task.toFirestore());
  }

  Future<void> updateTask(Task task) async {
    await _tasksRef.doc(task.id!).update(task.toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksRef.doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}