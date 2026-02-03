import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/core/usecase/usecase.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:Softbee/feature/apiaries/domain/usecases/get_apiaries.dart';
import 'package:Softbee/feature/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

// 1. ApiariesState: Represents the UI state
class ApiariesState extends Equatable {
  final bool isLoading;
  final List<Apiary> apiaries;
  final String? errorMessage;

  const ApiariesState({
    this.isLoading = false,
    this.apiaries = const [],
    this.errorMessage,
  });

  ApiariesState copyWith({
    bool? isLoading,
    List<Apiary>? apiaries,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApiariesState(
      isLoading: isLoading ?? this.isLoading,
      apiaries: apiaries ?? this.apiaries,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, apiaries, errorMessage];
}

// 2. ApiariesController: Manages the state and interacts with use cases
class ApiariesController extends StateNotifier<ApiariesState> {
  final GetApiariesUseCase getApiariesUseCase;
  final AuthController authController; // To get the current user ID

  ApiariesController({
    required this.getApiariesUseCase,
    required this.authController,
  }) : super(const ApiariesState());

  Future<void> fetchApiaries() async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (!authController.state.isAuthenticated ||
        authController.state.user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User not authenticated.',
      );
      return;
    }

    final String currentUserId = authController.state.user!.id;

    final result = await getApiariesUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (allApiaries) {
        final userApiaries =
            allApiaries.where((apiary) => apiary.userId == currentUserId).toList();
        state = state.copyWith(isLoading: false, apiaries: userApiaries);
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case AuthFailure: // Token expired, etc.
        return (failure as AuthFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      default:
        return 'An unexpected error occurred while fetching apiaries.';
    }
  }
}
