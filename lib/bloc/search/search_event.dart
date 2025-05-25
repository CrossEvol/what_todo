part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  
  @override
  List<Object?> get props => [];
}

class SearchTasksEvent extends SearchEvent {
  final String keyword;
  final bool searchInTitle;
  final bool searchInComment;
  final FilteredField? filteredField;
  final SearchResultsOrder? order;
  final int page;

  const SearchTasksEvent({
    required this.keyword,
    this.searchInTitle = true,
    this.searchInComment = true,
    this.filteredField,
    this.order,
    this.page = 1,
  });
  
  @override
  List<Object?> get props => [keyword, searchInTitle, searchInComment, filteredField, order, page];
}

class ResetSearchEvent extends SearchEvent {}

class UpdateSortFieldEvent extends SearchEvent {
  final FilteredField filteredField;
  
  const UpdateSortFieldEvent(this.filteredField);
  
  @override
  List<Object> get props => [filteredField];
}

class UpdateSortOrderEvent extends SearchEvent {
  final SearchResultsOrder order;
  
  const UpdateSortOrderEvent(this.order);
  
  @override
  List<Object> get props => [order];
}

class NavigateToPageEvent extends SearchEvent {
  final int page;
  
  const NavigateToPageEvent(this.page);
  
  @override
  List<Object> get props => [page];
}

class MarkTaskAsDoneEvent extends SearchEvent {
  final Task task;
  
  const MarkTaskAsDoneEvent(this.task);
  
  @override
  List<Object> get props => [task];
}

class MarkTaskAsUndoneEvent extends SearchEvent {
  final Task task;
  
  const MarkTaskAsUndoneEvent(this.task);
  
  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends SearchEvent {
  final Task task;
  
  const DeleteTaskEvent(this.task);
  
  @override
  List<Object> get props => [task];
}
