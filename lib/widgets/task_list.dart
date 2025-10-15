import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String, bool) onTaskToggle;
  final Function(String) onTaskDelete;
  final Function(Task) onTaskEdit;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onTaskEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64.w, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap + to add your first task',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(context, task);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Dismissible(
      key: Key(task.id!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: Colors.white, size: 24.w),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) => onTaskDelete(task.id!),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) => onTaskToggle(task.id!, value!),
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
                        fontSize: 12.sp,
                        color: task.priority.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.calendar_today, size: 12.w, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    DateFormat('MMM dd').format(task.dueDate),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, size: 20.w),
            onPressed: () => onTaskEdit(task),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}