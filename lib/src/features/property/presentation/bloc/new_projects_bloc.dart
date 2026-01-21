import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../data/models/project_model.dart'; // Adjust if path is different

part 'new_projects_event.dart';
part 'new_projects_state.dart';

class NewProjectsBloc extends Bloc<NewProjectsEvent, NewProjectsState> {
  NewProjectsBloc() : super(const NewProjectsState.initial()) {
    on<LoadNewProjects>(_onLoadNewProjects);
    on<LoadMoreNewProjects>(_onLoadMoreNewProjects);
  }

  Future<void> _onLoadNewProjects(
    LoadNewProjects event,
    Emitter<NewProjectsState> emit,
  ) async {
    emit(state.copyWith(status: NewProjectsStatus.loading));

    try {
      final uri = ApiService.buildUri('new-projects', query: {'page': '1'});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = ProjectResponseModel.fromJson(jsonData);
        final fetchedData = responseModel.data!;

        final projects = fetchedData.data ?? [];
        final hasMore = (fetchedData.meta?.currentPage ?? 1) <
            (fetchedData.meta?.lastPage ?? 1);

        emit(state.copyWith(
          status: NewProjectsStatus.loaded,
          projects: projects,
          currentPage: 2,
          hasMore: hasMore,
        ));
      } else {
        emit(state.copyWith(
          status: NewProjectsStatus.error,
          errorMessage: 'Failed to load projects',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NewProjectsStatus.error,
        errorMessage: 'Connection failed',
      ));
    }
  }

  Future<void> _onLoadMoreNewProjects(
    LoadMoreNewProjects event,
    Emitter<NewProjectsState> emit,
  ) async {
    if (!state.hasMore || state.status == NewProjectsStatus.loadingMore) return;

    emit(state.copyWith(status: NewProjectsStatus.loadingMore));

    try {
      final uri = ApiService.buildUri('new-projects',
          query: {'page': '${state.currentPage}'});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = ProjectResponseModel.fromJson(jsonData);
        final fetchedData = responseModel.data!;

        final newProjects = fetchedData.data ?? [];
        final hasMore = (fetchedData.meta?.currentPage ?? 1) <
            (fetchedData.meta?.lastPage ?? 1);

        emit(state.copyWith(
          projects: [...state.projects, ...newProjects],
          currentPage: state.currentPage + 1,
          hasMore: hasMore,
          status: NewProjectsStatus.loaded,
        ));
      } else {
        emit(state.copyWith(status: NewProjectsStatus.loaded));
      }
    } catch (e) {
      emit(state.copyWith(status: NewProjectsStatus.loaded));
    }
  }
}
