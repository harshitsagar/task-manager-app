import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/bloc/auth/auth_bloc.dart';
import 'package:task_manager_app/bloc/task/task_bloc.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/widgets/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Priority? _selectedPriority;
  bool _showCompleted = true;
  bool _showIncomplete = true;

  @override
  void initState() {
    super.initState();
    // Load tasks when home screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(LoadTasks());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section similar to reference image
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 20.w, color: const Color(0xFF6C63FF)),
                SizedBox(width: 8.w),
                Text(
                  'My tracks',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Task Sections
          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded) {
                  final filteredTasks = _filterTasks(state.tasks);
                  final todayTasks = _getTodayTasks(filteredTasks);
                  final tomorrowTasks = _getTomorrowTasks(filteredTasks);
                  final weekTasks = _getWeekTasks(filteredTasks);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today Section
                        if (todayTasks.isNotEmpty) _buildTaskSection('Today', todayTasks),

                        // Tomorrow Section
                        if (tomorrowTasks.isNotEmpty) _buildTaskSection('Tomorrow', tomorrowTasks),

                        // This Week Section
                        if (weekTasks.isNotEmpty) _buildTaskSection('This Week', weekTasks),

                        // All Tasks Section
                        if (filteredTasks.isNotEmpty && todayTasks.isEmpty && tomorrowTasks.isEmpty && weekTasks.isEmpty)
                          _buildTaskSection('All Tasks', filteredTasks),

                        if (filteredTasks.isEmpty) _buildEmptyState(),
                      ],
                    ),
                  );
                } else if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64.w, color: Colors.red),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: TextStyle(fontSize: 16.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.read<TaskBloc>().add(LoadTasks()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Task> tasks) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          ...tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            context.read<TaskBloc>().add(
              ToggleTaskCompletion(taskId: task.id!, isCompleted: value!),
            );
          },
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
            ],
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority.name,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: task.priority.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.calendar_today, size: 12.w, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Edit', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  _showAddTaskDialog(context, task: task);
                });
              },
            ),
            PopupMenuItem(
              child: Text('Delete', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  context.read<TaskBloc>().add(DeleteTask(taskId: task.id!));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_outlined, size: 80.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to add your first task',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      final priorityMatch = _selectedPriority == null || task.priority == _selectedPriority;
      final statusMatch = (_showCompleted && task.isCompleted) ||
          (_showIncomplete && !task.isCompleted);
      return priorityMatch && statusMatch;
    }).toList();
  }

  List<Task> _getTodayTasks(List<Task> tasks) {
    final today = DateTime.now();
    return tasks.where((task) {
      return task.dueDate.year == today.year &&
          task.dueDate.month == today.month &&
          task.dueDate.day == today.day;
    }).toList();
  }

  List<Task> _getTomorrowTasks(List<Task> tasks) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tasks.where((task) {
      return task.dueDate.year == tomorrow.year &&
          task.dueDate.month == tomorrow.month &&
          task.dueDate.day == tomorrow.day;
    }).toList();
  }

  List<Task> _getWeekTasks(List<Task> tasks) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return tasks.where((task) {
      return task.dueDate.isAfter(now) &&
          task.dueDate.isBefore(weekEnd) &&
          !_isToday(task.dueDate) &&
          !_isTomorrow(task.dueDate);
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  String _formatDate(DateTime date) {
    if (_isToday(date)) {
      return 'Today';
    } else if (_isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  void _showAddTaskDialog(BuildContext context, {Task? task}) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(existingTask: task),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Tasks',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Text('Priority:', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedPriority == null,
                    onSelected: (_) {
                      setState(() => _selectedPriority = null);
                      Navigator.pop(context);
                    },
                  ),
                  ...Priority.values.map((priority) => FilterChip(
                    label: Text(priority.name),
                    selected: _selectedPriority == priority,
                    onSelected: (_) {
                      setState(() => _selectedPriority = priority);
                      Navigator.pop(context);
                    },
                  )),
                ],
              ),
              SizedBox(height: 16.h),
              Text('Status:', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 8.h),
              CheckboxListTile(
                title: Text('Show Completed', style: TextStyle(fontSize: 14.sp)),
                value: _showCompleted,
                onChanged: (value) => setState(() => _showCompleted = value!),
              ),
              CheckboxListTile(
                title: Text('Show Incomplete', style: TextStyle(fontSize: 14.sp)),
                value: _showIncomplete,
                onChanged: (value) => setState(() => _showIncomplete = value!),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out', style: TextStyle(fontSize: 18.sp)),
        content: Text('Are you sure you want to sign out?', style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOutRequested());
            },
            child: Text('Sign Out', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}