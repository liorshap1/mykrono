import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mykrono/models/space.dart';
import 'package:mykrono/repos/space_repository.dart';
import 'package:mykrono/widgets/priority_button.dart';
import 'package:mykrono/widgets/task_item.dart';

enum Priority { low, medium, high }

const double spaceWidth = 10;

class SpaceScreen extends StatefulWidget {
  final Space space;
  const SpaceScreen({super.key, required this.space});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  final SpaceRepository spaceRepository = SpaceRepository();
  final ValueNotifier<bool> _isRefreshing = ValueNotifier(false);
  final ValueNotifier<int> _refreshTrigger = ValueNotifier(0);

  Future<void> _refreshTasks() async {
    _isRefreshing.value = true;
    _refreshTrigger.value++;
    await Future.delayed(const Duration(milliseconds: 300));
    _isRefreshing.value = false;
  }

  void _showBottomSheet() {
    showFSheet(
      context: context,
      useSafeArea: true,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.9,
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.55,
        minWidth: double.infinity,
      ),
      builder: (context) => SpaceScreenBottomSheet(
        spaceRepository: spaceRepository,
        space: widget.space,
        onTaskAdded: _refreshTasks,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(message),
      alignment: FToastAlignment.bottomCenter,
    );
  }

  Future<void> _removeTask(int taskId) async {
    final spaceId = widget.space.id;
    if (spaceId == null) {
      _showErrorSnackBar('Invalid space id');
      return;
    }
    try {
      await spaceRepository.removeTask(spaceId, taskId);
      await _refreshTasks();
      _showErrorSnackBar("Removed task successfully");
    } catch (e) {
      _showErrorSnackBar('Failed to remove task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FHeader.nested(
                    title: Text(widget.space.name),
                    prefixes: [
                      FHeaderAction.back(onPress: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _refreshTrigger,
                      builder: (context, _, __) => _buildTasksList(),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 24,
                child: GestureDetector(
                  onTap: _showBottomSheet,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspaces_outline,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FButton(
              onPress: _showBottomSheet,
              child: const Text("Create task"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load tasks',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FButton(onPress: _refreshTasks, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    final spaceId = widget.space.id;
    if (spaceId == null) {
      return _buildErrorState('Space id is null');
    }
    return FutureBuilder<Space?>(
      future: spaceRepository.getSpace(spaceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final space = snapshot.data;
        if (space == null || space.tasks.isEmpty) {
          return _buildEmptyState();
        }

        final tasks = space.tasks;

        return ListView.separated(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final t = tasks[index];

            return TaskItem(
              task: t.text,
              priority: t.priority,
              taskDueDate: t.dateTime,
              taskId: t.id,
              onRemoveTask: _removeTask,
              parentContext: context,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return FDivider(axis: Axis.horizontal);
          },
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SpaceScreenBottomSheet extends StatefulWidget {
  final VoidCallback? onTaskAdded;
  final SpaceRepository spaceRepository;
  final Space space;

  const SpaceScreenBottomSheet({
    super.key,
    this.onTaskAdded,
    required this.spaceRepository,
    required this.space,
  });

  @override
  State<SpaceScreenBottomSheet> createState() => _SpaceScreenBottomSheetState();
}

class _SpaceScreenBottomSheetState extends State<SpaceScreenBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final PriorityController _priorityController;
  late final FDateFieldController _dateController;
  final formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _priorityController = PriorityController();
    _dateController = FDateFieldController(
      vsync: this,
      initialDate: DateTime.now(),
    );
  }

  Future<void> _handleSubmit() async {
    final taskText = _controller.text.trim();
    final priority = _priorityController.value;
    final dueDate = _dateController.value;
    final spaceId = widget.space.id;

    final error = _validateTask(taskText, spaceId);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.spaceRepository.addTask(
        spaceId!,
        taskText,
        dueDate,
        priority,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onTaskAdded?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to create task: $e";
        _isSubmitting = false;
      });
    }
  }

  String? _validateTask(String text, int? spaceId) {
    if (spaceId == null) return "Invalid space id";
    if (text.isEmpty) return "Please enter task";
    if (text.length < 2) return "Task must be at least 2 characters";
    if (text.length > 200) return "Task name must be less than 200 characters";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: spaceWidth,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(text: "Create new task"),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              FTextField(
                controller: _controller,
                hint: "Make shopping list",
                description: const Text("Choose meaningful name"),
                maxLines: 1,
                enabled: !_isSubmitting,
                autofocus: true,
                error: _errorMessage != null ? Text(_errorMessage!) : null,
              ),
              BottomSheetDateSelect(controller: _dateController),
              BottomSheetPrioritySelect(controller: _priorityController),
              const SizedBox(height: 10),
              FButton(
                onPress: _isSubmitting ? null : _handleSubmit,
                prefix: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                child: Text(_isSubmitting ? 'Creating...' : 'Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

// Controller for priority
class PriorityController {
  Priority value;
  PriorityController({this.value = Priority.low});
}

class BottomSheetPrioritySelect extends StatefulWidget {
  final PriorityController controller;
  const BottomSheetPrioritySelect({super.key, required this.controller});

  @override
  State<BottomSheetPrioritySelect> createState() =>
      _BottomSheetPrioritySelectState();
}

class _BottomSheetPrioritySelectState extends State<BottomSheetPrioritySelect> {
  void _setPriority(Priority priority) {
    setState(() => widget.controller.value = priority);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spaceWidth,
      children: [
        const SectionTitle(text: "Priority"),
        Row(
          spacing: spaceWidth,
          children: Priority.values.map((priority) {
            final isSelected = widget.controller.value == priority;
            return Expanded(
              child: PriorityButton(
                isSelected: isSelected,
                onPress: () => _setPriority(priority),
                label: priority.name,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BottomSheetDateSelect extends StatelessWidget {
  final FDateFieldController controller;
  const BottomSheetDateSelect({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spaceWidth,
      children: [
        const SectionTitle(text: "Due date"),
        FDateField(
          controller: controller,
          description: const Text("Select due date"),
          clearable: true,
        ),
      ],
    );
  }
}
