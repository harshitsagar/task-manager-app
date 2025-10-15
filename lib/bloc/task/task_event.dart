part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;

  const AddTask({required this.task});

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask({required this.task});

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class ToggleTaskCompletion extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletion({required this.taskId, required this.isCompleted});

  @override
  List<Object> get props => [taskId, isCompleted];
}