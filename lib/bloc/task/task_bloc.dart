import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await emit.forEach(
        taskRepository.getTasks(),
        onData: (tasks) => TaskLoaded(tasks),
        onError: (error, stackTrace) => TaskError('Failed to load tasks: $error'),
      );
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.addTask(event.task);
      // The stream will automatically update the UI
    } catch (e) {
      // Show error but don't break the state
      emit(TaskError('Failed to add task: $e'));
      // Re-emit current state to maintain UI
      if (state is TaskLoaded) {
        emit(TaskLoaded((state as TaskLoaded).tasks));
      }
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      // The stream will automatically update the UI
    } catch (e) {
      // Show error but don't break the state
      emit(TaskError('Failed to update task: $e'));
      // Re-emit current state to maintain UI
      if (state is TaskLoaded) {
        emit(TaskLoaded((state as TaskLoaded).tasks));
      }
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      // The stream will automatically update the UI
    } catch (e) {
      // Show error but don't break the state
      emit(TaskError('Failed to delete task: $e'));
      // Re-emit current state to maintain UI
      if (state is TaskLoaded) {
        emit(TaskLoaded((state as TaskLoaded).tasks));
      }
    }
  }

  void _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.toggleTaskCompletion(event.taskId, event.isCompleted);
      // The stream will automatically update the UI
    } catch (e) {
      // Show error but don't break the state
      emit(TaskError('Failed to update task: $e'));
    }
  }
}