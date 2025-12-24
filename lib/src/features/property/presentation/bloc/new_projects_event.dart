part of 'new_projects_bloc.dart';

abstract class NewProjectsEvent extends Equatable {
  const NewProjectsEvent();

  @override
  List<Object> get props => [];
}

class LoadNewProjects extends NewProjectsEvent {}

class LoadMoreNewProjects extends NewProjectsEvent {}