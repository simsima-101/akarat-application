// // lib/src/features/find_agent/presentation/bloc/find_agent_state.dart
//
// part of 'find_agent_bloc.dart';
//
// import 'package:equatable/equatable.dart';
//
// import '../../../agency/data/models/agency_model.dart';
// import '../../../agency/data/models/agents_model.dart';
//
// class FindAgentState extends Equatable {
//   final List<AgentsModel> agents;
//   final List<Agency> agencies;
//
//   final bool isLoadingAgents;
//   final bool isLoadingMoreAgents;
//   final bool hasMoreAgents;
//
//   final bool isLoadingAgencies;
//   final bool isLoadingMoreAgencies;
//   final bool hasMoreAgencies;
//
//   final String agentSearchQuery;
//   final String agencySearchQuery;
//
//   final String? selectedAgentService;
//   final String? selectedAgencyService;
//   final String? selectedLanguage;
//   final String? selectedNationality;
//
//   const FindAgentState({
//     this.agents = const [],
//     this.agencies = const [],
//     this.isLoadingAgents = false,
//     this.isLoadingMoreAgents = false,
//     this.hasMoreAgents = true,
//     this.isLoadingAgencies = false,
//     this.isLoadingMoreAgencies = false,
//     this.hasMoreAgencies = true,
//     this.agentSearchQuery = '',
//     this.agencySearchQuery = '',
//     this.selectedAgentService,
//     this.selectedAgencyService,
//     this.selectedLanguage,
//     this.selectedNationality,
//   });
//
//   FindAgentState copyWith({
//     List<AgentsModel>? agents,
//     List<Agency>? agencies,
//     bool? isLoadingAgents,
//     bool? isLoadingMoreAgents,
//     bool? hasMoreAgents,
//     bool? isLoadingAgencies,
//     bool? isLoadingMoreAgencies,
//     bool? hasMoreAgencies,
//     String? agentSearchQuery,
//     String? agencySearchQuery,
//     String? selectedAgentService,
//     String? selectedAgencyService,
//     String? selectedLanguage,
//     String? selectedNationality,
//   }) {
//     return FindAgentState(
//       agents: agents ?? this.agents,
//       agencies: agencies ?? this.agencies,
//       isLoadingAgents: isLoadingAgents ?? this.isLoadingAgents,
//       isLoadingMoreAgents: isLoadingMoreAgents ?? this.isLoadingMoreAgents,
//       hasMoreAgents: hasMoreAgents ?? this.hasMoreAgents,
//       isLoadingAgencies: isLoadingAgencies ?? this.isLoadingAgencies,
//       isLoadingMoreAgencies: isLoadingMoreAgencies ?? this.isLoadingMoreAgencies,
//       hasMoreAgencies: hasMoreAgencies ?? this.hasMoreAgencies,
//       agentSearchQuery: agentSearchQuery ?? this.agentSearchQuery,
//       agencySearchQuery: agencySearchQuery ?? this.agencySearchQuery,
//       selectedAgentService: selectedAgentService ?? this.selectedAgentService,
//       selectedAgencyService: selectedAgencyService ?? this.selectedAgencyService,
//       selectedLanguage: selectedLanguage ?? this.selectedLanguage,
//       selectedNationality: selectedNationality ?? this.selectedNationality,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     agents,
//     agencies,
//     isLoadingAgents,
//     isLoadingMoreAgents,
//     hasMoreAgents,
//     isLoadingAgencies,
//     isLoadingMoreAgencies,
//     hasMoreAgencies,
//     agentSearchQuery,
//     agencySearchQuery,
//     selectedAgentService,
//     selectedAgencyService,
//     selectedLanguage,
//     selectedNationality,
//   ];
// }