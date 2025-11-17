import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mykrono/core/screens/space_screen.dart';
import 'package:mykrono/models/space.dart';
import 'package:mykrono/models/Task.dart';
import 'package:mykrono/repos/space_repository.dart';
import 'package:mykrono/widgets/add_button_card.dart';
import 'package:mykrono/widgets/custom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpaceRepository _repo = SpaceRepository();

  late Future<List<Space>> _spacesFuture;
  late Future<List<Task>> _recentTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _spacesFuture = _repo.getAllSpaces();
    _recentTasksFuture = _repo.getRecentTasksFromAllSpaces();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _showAddSpaceSheet() {
    showFSheet(
      context: context,
      side: FLayout.btt,
      builder: (context) => AddSpaceBottomSheetContent(
        side: FLayout.btt,
        spaceRepository: _repo,
        onSpaceAdded: _refresh,
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(msg),
      alignment: FToastAlignment.bottomCenter,
    );
  }

  Future<void> _deleteSpace(Space space) async {
    try {
      if (space.id == null) throw Exception("Invalid space id");
      await _repo.deleteSpace(space.id!);
      _showSnack("${space.name} deleted");
      _refresh();
    } catch (e) {
      _showSnack("Failed to delete space: $e", error: true);
    }
  }

  void _navigateToSpace(Space s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SpaceScreen(space: s)),
    );
    _showSnack("Opening ${s.name}");
  }

  void _showDeleteConfirmation(Space space) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Space"),
        content:
            Text('Delete "${space.name}"? This removes ${space.tasks.length} tasks.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSpace(space);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fcolors = context.theme.colors;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            children: [
              FHeader(
                title: const Text("Home"),
                style: context.theme.headerStyles.rootStyle
                    .copyWith(padding: EdgeInsets.zero)
                    .call,
              ),
              const SizedBox(height: 4),
              Text(
                "Choose your space!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fcolors.primary,
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<Space>>(
                future: _spacesFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return _loading();
                  if (snap.hasError) return _error("Failed to load spaces", snap.error.toString());
                  if (!snap.hasData || snap.data!.isEmpty) return _empty();
                  return _spacesGrid(snap.data!);
                },
              ),
              const SizedBox(height: 24),
              FDivider(axis: Axis.horizontal),
              const SizedBox(height: 16),
              _recentTasksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );

  Widget _error(String title, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(msg, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FButton(onPress: _refresh, child: const Text("Retry")),
            ],
          ),
        ),
      );

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.workspaces_outline, size: 64),
              const SizedBox(height: 12),
              const Text("No spaces yet",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              const Text("Create your first space to get started"),
              const SizedBox(height: 16),
              AddButtonCard(onTap: _showAddSpaceSheet),
            ],
          ),
        ),
      );

  Widget _spacesGrid(List<Space> spaces) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < spaces.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomCard(
                    title: spaces[i].name,
                    subtitle:
                        "${spaces[i].tasks.length} ${spaces[i].tasks.length == 1 ? 'task' : 'tasks'}",
                    color: _getSpaceColor(i),
                    onTap: () => _navigateToSpace(spaces[i]),
                    onLongPress: () => _showDeleteConfirmation(spaces[i]),
                  ),
                ),
              AddButtonCard(onTap: _showAddSpaceSheet),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text("${spaces.length} space${spaces.length == 1 ? '' : 's'}"),
        ),
      ],
    );
  }

  Widget _recentTasksSection() {
    return FutureBuilder<List<Task>>(
      future: _recentTasksFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loading();
        if (snap.hasError) return _error("Failed to load recent tasks", snap.error.toString());
        final tasks = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent added tasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              const Center(child: Text("No recent tasks"))
            else
              FTileGroup.builder(
                count: tasks.length,
                maxHeight: double.infinity,
                tileBuilder: (_, i) => FTile(title: Text(tasks[i].text)),
              ),
          ],
        );
      },
    );
  }

  Color _getSpaceColor(int i) {
    const colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[i % colors.length];
  }
}

class AddSpaceBottomSheetContent extends StatefulWidget {
  final FLayout side;
  final VoidCallback? onSpaceAdded;
  final SpaceRepository spaceRepository;

  const AddSpaceBottomSheetContent({
    super.key,
    required this.side,
    required this.spaceRepository,
    this.onSpaceAdded,
  });

  @override
  State<AddSpaceBottomSheetContent> createState() =>
      _AddSpaceBottomSheetContentState();
}

class _AddSpaceBottomSheetContentState
    extends State<AddSpaceBottomSheetContent> {
  late final TextEditingController _controller;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<void> _handleSubmit() async {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter a space name');
      return;
    }
    if (name.length < 2) {
      setState(() => _errorMessage = 'Space name must be at least 2 characters');
      return;
    }
    if (name.length > 50) {
      setState(() => _errorMessage = 'Space name must be less than 50 characters');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.spaceRepository.createSpace(name);
      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onSpaceAdded?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to create space: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: widget.side.vertical
            ? Border.symmetric(horizontal: BorderSide(color: colors.border))
            : Border.symmetric(vertical: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Space',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FTextField(
                controller: _controller,
                label: const Text('Space name'),
                hint: "e.g., Work, Personal, Study",
                description: const Text("Choose a meaningful name for your space"),
                maxLines: 1,
                enabled: !_isSubmitting,
                autofocus: true,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FButton(
                onPress: _isSubmitting ? null : _handleSubmit,
                prefix: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                child: Text(_isSubmitting ? 'Creating...' : 'Create Space'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
