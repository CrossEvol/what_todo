import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/search/search_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:go_router/go_router.dart';

import 'models/task.dart';

class TaskGrid extends StatefulWidget {
  const TaskGrid({super.key});

  @override
  State<TaskGrid> createState() => _TaskGridState();
}

class _TaskGridState extends State<TaskGrid> {
  // Helper for custom PopupMenuItem with width, hover, and selected color
  PopupMenuItem<FilteredField> _buildMenuItem(
    BuildContext context,
    FilteredField value,
    String text,
    FilteredField? selectedValue,
  ) {
    final isSelected = value == selectedValue;
    final theme = Theme.of(context);
    return PopupMenuItem<FilteredField>(
      value: value,
      height: 36.0,
      // Set a minimum width and custom background color for selected/hovered states
      child: Container(
        width: 128, // Set your desired width here
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        Widget bodyContent;
        bool hasResult = false;
        if (state is SearchInitial) {
          bodyContent = const Expanded(
            child: Center(
              child: Text('empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ),
          );
        } else if (state is SearchLoadingState) {
          bodyContent = Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is SearchErrorState) {
          bodyContent = Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('An error occurred:',
                      style: TextStyle(fontSize: 16, color: Colors.red)),
                  const SizedBox(height: 8),
                  Text(state.error,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          );
        } else if (state is SearchResultsState) {
          bodyContent = _buildTaskList(context, state.tasks);
          hasResult = true;
        } else {
          bodyContent = const Expanded(
            child: Center(
              child: Text('Unknown state'),
            ),
          );
        }
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hasResult ? _buildStatistics(context, state) : Container(),
                bodyContent,
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search',
            child: const Icon(Icons.search),
          ),
          bottomNavigationBar:
              hasResult ? _buildBottomNavigationBar(context, state) : null,
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, SearchState state) {
    // Determine the title based on search state
    String title = 'Task Grid';
    if (state is SearchResultsState) {
      title = state.keyword;
    }

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        title,
        style: GoogleFonts.interTight(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Sort field selection
        PopupMenuButton<FilteredField>(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.surface,
            size: 36,
          ),
          padding: const EdgeInsets.only(top: -8, right: 24),
          position: PopupMenuPosition.under,
          onSelected: (FilteredField field) {
            context.read<SearchBloc>().add(UpdateSortFieldEvent(field));
          },
          itemBuilder: (BuildContext context) {
            // Get the currently selected field from state, if available
            FilteredField? selectedField;
            if (state is SearchResultsState) {
              selectedField = state.filteredField;
            }
            return <PopupMenuEntry<FilteredField>>[
              _buildMenuItem(context, FilteredField.id, 'ID', selectedField),
              _buildMenuItem(
                  context, FilteredField.title, 'Title', selectedField),
              _buildMenuItem(
                  context, FilteredField.project, 'Project', selectedField),
              _buildMenuItem(
                  context, FilteredField.dueDate, 'Due Date', selectedField),
              _buildMenuItem(
                  context, FilteredField.status, 'Status', selectedField),
              _buildMenuItem(
                  context, FilteredField.priority, 'Priority', selectedField),
              _buildMenuItem(
                  context, FilteredField.order, 'Order', selectedField),
            ];
          },
        ),
        // Sort order toggle
        InkWell(
          onTap: () {
            if (state is SearchResultsState) {
              // Toggle between ascending and descending
              final currentOrder = state.order ?? SearchResultsOrder.asc;
              final newOrder = currentOrder == SearchResultsOrder.asc
                  ? SearchResultsOrder.desc
                  : SearchResultsOrder.asc;
              context.read<SearchBloc>().add(UpdateSortOrderEvent(newOrder));
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(
              state is SearchResultsState &&
                      state.order == SearchResultsOrder.desc
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: Theme.of(context).colorScheme.surface,
              size: 36,
            ),
          ),
        ),
      ],
      centerTitle: false,
      elevation: 2,
    );
  }

  Widget _buildStatistics(BuildContext context, SearchState state) {
    if (state is SearchResultsState) {
      return StatisticsRow(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        totalItems: state.totalItems,
      );
    } else {
      return const StatisticsRow();
    }
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No tasks found'),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final status = task.tasksStatus == TaskStatus.COMPLETE
              ? TaskStatus.COMPLETE
              : TaskStatus.PENDING;

          return Column(
            children: [
              status == TaskStatus.COMPLETE
                  ? DoneTaskCard(task: task)
                  : UndoneTaskCard(task: task),
              const SizedBox(height: 1),
            ],
          );
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
      BuildContext context, SearchState state) {
    // Determine the current page index and handle pagination
    int currentIndex = 0;
    bool canNavigatePrev = false;
    bool canNavigateNext = false;

    if (state is SearchResultsState) {
      currentIndex = 1; // Home icon selected by default in search results
      canNavigatePrev = state.currentPage > 1;
      canNavigateNext = state.currentPage < state.totalPages;
    }

    return BottomNavigationBar(
      backgroundColor: Colors.grey[200],
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.keyboard_double_arrow_left),
          label: 'Previous',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.circle_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.keyboard_double_arrow_right),
          label: 'Next',
        ),
      ],
      currentIndex: currentIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (state is SearchResultsState) {
          if (index == 0 && canNavigatePrev) {
            // Navigate to previous page
            context
                .read<SearchBloc>()
                .add(NavigateToPageEvent(state.currentPage - 1));
          } else if (index == 2 && canNavigateNext) {
            // Navigate to next page
            context
                .read<SearchBloc>()
                .add(NavigateToPageEvent(state.currentPage + 1));
          } else if (index == 1) {
            // Reset to first page if not already there
            if (state.currentPage != 1) {
              context.read<SearchBloc>().add(const NavigateToPageEvent(1));
            }
          }
        }
      },
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final result = await showDialog<SearchDialogResult>(
      context: context,
      builder: (context) => const SearchDialog(),
    );

    if (result != null) {
      context.read<SearchBloc>().add(SearchTasksEvent(
            keyword: result.keyword,
            searchInTitle: result.searchInTitle,
            searchInComment: result.searchInComment,
            filteredField: FilteredField.order,
            order: SearchResultsOrder.asc,
          ));
    }
  }

// Method replaced with direct PopupMenuButton implementation

// Removed _showOrderDialog method as we're now toggling directly
}

class StatisticsRow extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const StatisticsRow({
    super.key,
    this.currentPage = 1,
    this.totalPages = 10,
    this.totalItems = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'current',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '$currentPage',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                'at',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '$totalPages',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                'pages',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 20,
          height: 20, // Adjust as needed
          child: VerticalDivider(
            width: 1,
            thickness: 1,
            // Thicker line
            indent: 6,
            // Less padding for more visible line
            endIndent: 0,
            color: Colors.grey, // More visible color
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 4),
              child: Text(
                'total',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '$totalItems',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                'items',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF606A85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DoneTaskCard extends StatelessWidget {
  final Task task;

  const DoneTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        boxShadow: [
          BoxShadow(
            blurRadius: 0,
            color: const Color(0xFFE5E7EB),
            offset: const Offset(
              0,
              1,
            ),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional(-1, -1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x4C878D8C),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5A847E),
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    customButton: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.roundabout_right_outlined,
                        color: const Color(0xFF678580),
                        size: 20,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'undone',
                        child: Row(
                          children: const [
                            Icon(Icons.replay_circle_filled,
                                color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text('Undo', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == 'edit') {
                        context.push('/task/edit', extra: task);
                      } else if (value == 'undone') {
                        context
                            .read<SearchBloc>()
                            .add(MarkTaskAsUndoneEvent(task));
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) =>
                              DeleteConfirmationDialog(task: task),
                        );
                        if (confirm == true) {
                          context.read<SearchBloc>().add(DeleteTaskEvent(task));
                        }
                      }
                    },
                    dropdownStyleData: DropdownStyleData(
                      width: 160,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      offset: const Offset(0, 8),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: task.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF15161E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF696B7F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  if (task.labelList.length > 1) ...[
                                    Icon(
                                      Icons.local_offer,
                                      color: const Color(0xFF5EBB64),
                                      size: 16,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        task.labelList[1].name,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (task.labelList.isNotEmpty) ...[
                                    Icon(
                                      Icons.local_offer,
                                      color: const Color(0xFF5EC8D3),
                                      size: 16,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        task.labelList[0].name,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, -1),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.circle_sharp,
                                      color: Color(
                                          task.projectColor ?? 0xFF3C2858),
                                      size: 16,
                                    ),
                                    Text(
                                      task.projectName ?? 'FlutterFlow CRM App',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF15161E),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 196.3,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: priorityColor[task.priority.index],
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                    color: const Color(0xFFE9D14A),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  task.comment,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF606A85),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        getFormattedDate(task.dueDate),
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF606A85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UndoneTaskCard extends StatelessWidget {
  final Task task;

  const UndoneTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 0,
            color: const Color(0xFFE5E7EB),
            offset: const Offset(
              0,
              1,
            ),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional(-1, -1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x4D9489F5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6F61EF),
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    customButton: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.document_scanner_rounded,
                        color: const Color(0xFF6F61EF),
                        size: 20,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'done',
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Done', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == 'edit') {
                        context.push('/task/edit', extra: task);
                      } else if (value == 'done') {
                        context
                            .read<SearchBloc>()
                            .add(MarkTaskAsDoneEvent(task));
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) =>
                              DeleteConfirmationDialog(task: task),
                        );
                        if (confirm == true) {
                          context.read<SearchBloc>().add(DeleteTaskEvent(task));
                        }
                      }
                    },
                    dropdownStyleData: DropdownStyleData(
                      width: 160,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      offset: const Offset(0, 8),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: task.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF6F61EF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF15161E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6F61EF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6F61EF),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                if (task.labelList.length > 1) ...[
                                  Icon(
                                    Icons.local_offer,
                                    color: const Color(0xFF5EBB64),
                                    size: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      task.labelList[1].name,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (task.labelList.isNotEmpty) ...[
                                  Icon(
                                    Icons.local_offer,
                                    color: const Color(0xFF5EC8D3),
                                    size: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      task.labelList[0].name,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional(0, -1),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                alignment: WrapAlignment.start,
                                children: [
                                  Icon(
                                    Icons.circle_sharp,
                                    color: Color(task.projectColor!),
                                    size: 16,
                                  ),
                                  Text(
                                    task.projectName!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF15161E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 196.3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: priorityColor[task.priority.index],
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: const Color(0xFFE9D14A),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                task.comment,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF606A85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        getFormattedDate(task.dueDate),
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF606A85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchDialogResult {
  final String keyword;
  final bool searchInTitle;
  final bool searchInComment;

  SearchDialogResult({
    required this.keyword,
    required this.searchInTitle,
    required this.searchInComment,
  });
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _keywordController = TextEditingController();
  bool _searchInTitle = true;
  bool _searchInComment = true;

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Search Tasks',
        style: GoogleFonts.interTight(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Search Keyword',
                hintText: 'Enter keyword to search',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Search in:',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                const Text('Title', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  value: _searchInTitle,
                  onChanged: (value) {
                    setState(() {
                      _searchInTitle = value;
                      // Ensure at least one option is selected
                      if (!_searchInTitle && !_searchInComment) {
                        _searchInComment = true;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Comment', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  value: _searchInComment,
                  onChanged: (value) {
                    setState(() {
                      _searchInComment = value;
                      // Ensure at least one option is selected
                      if (!_searchInTitle && !_searchInComment) {
                        _searchInTitle = true;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final keyword = _keywordController.text.trim();
            if (keyword.isNotEmpty) {
              Navigator.pop(
                context,
                SearchDialogResult(
                  keyword: keyword,
                  searchInTitle: _searchInTitle,
                  searchInComment: _searchInComment,
                ),
              );
            }
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final Task task;

  const DeleteConfirmationDialog({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Task',
        style: GoogleFonts.interTight(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
