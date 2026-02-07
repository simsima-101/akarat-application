import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/services/api_service.dart';

import '../../../localization/presentation/bloc/localization_cubit.dart';
import '../../data/models/project_model.dart'; // Adjust if path is different

part 'new_projects_event.dart';
part 'new_projects_state.dart';

// lib/src/features/property/presentation/bloc/new_projects_bloc.dart

// ... (imports and part declarations remain the same)

class NewProjectsBloc extends Bloc<NewProjectsEvent, NewProjectsState> {
  final LocalizationCubit localizationCubit;

  NewProjectsBloc({
    required this.localizationCubit,
  }) : super(const NewProjectsState.initial()) {
    on<LoadNewProjects>(_onLoadNewProjects);
    on<LoadMoreNewProjects>(_onLoadMoreNewProjects);
  }

  String get _acceptLanguage {
    final lang = localizationCubit.state.language.toLowerCase();
    return switch (lang) {
      'ar' => 'ar',
      'tr' => 'tr',
      _ => 'en',
    };
  }

  Future<void> _onLoadNewProjects(
      LoadNewProjects event,
      Emitter<NewProjectsState> emit,
      ) async {
    emit(state.copyWith(status: NewProjectsStatus.loading));

    try {
      final acceptLanguage = _acceptLanguage;
      debugPrint('→ NewProjects list (page 1) → Accept-Language: $acceptLanguage');

      final uri = ApiService.buildUri('new-projects', query: {'page': '1'});
      final response = await http.get(
        uri,
        headers: {'Accept-Language': acceptLanguage},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = ProjectResponseModel.fromJson(jsonData);
        final fetchedData = responseModel.data!;

        final projects = fetchedData.data ?? [];
        final hasMore = (fetchedData.meta?.currentPage ?? 1) < (fetchedData.meta?.lastPage ?? 1);

        emit(state.copyWith(
          status: NewProjectsStatus.loaded,
          projects: projects,
          currentPage: 2,
          hasMore: hasMore,
        ));
      } else {
        emit(state.copyWith(status: NewProjectsStatus.error));
        // Removed errorMessage → handle in UI with AppLocalizations
      }
    } catch (e) {
      debugPrint('NewProjects load error: $e');
      emit(state.copyWith(status: NewProjectsStatus.error));
    }
  }

  Future<void> _onLoadMoreNewProjects(
      LoadMoreNewProjects event,
      Emitter<NewProjectsState> emit,
      ) async {
    if (!state.hasMore || state.status == NewProjectsStatus.loadingMore) return;

    emit(state.copyWith(status: NewProjectsStatus.loadingMore));

    try {
      final acceptLanguage = _acceptLanguage;
      debugPrint('→ NewProjects load more (page ${state.currentPage}) → Accept-Language: $acceptLanguage');

      final uri = ApiService.buildUri('new-projects', query: {'page': '${state.currentPage}'});
      final response = await http.get(
        uri,
        headers: {'Accept-Language': acceptLanguage},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responseModel = ProjectResponseModel.fromJson(jsonData);
        final fetchedData = responseModel.data!;

        final newProjects = fetchedData.data ?? [];
        final hasMore = (fetchedData.meta?.currentPage ?? 1) < (fetchedData.meta?.lastPage ?? 1);

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
      debugPrint('NewProjects load more error: $e');
      emit(state.copyWith(status: NewProjectsStatus.loaded));
    }
  }
}