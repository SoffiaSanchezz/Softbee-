import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/apiary.dart';
import '../../core/entities/user.dart';
import '../../core/usecase/register_usecase.dart';
import 'auth_providers.dart';
import '../../../../core/services/geocoding_service.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

class ApiaryFormState {
  final String name;
  final String address;
  final bool appliesTreatments;

  const ApiaryFormState({
    this.name = '',
    this.address = '',
    this.appliesTreatments = false,
  });

  ApiaryFormState copyWith({
    String? name,
    String? address,
    bool? appliesTreatments,
  }) {
    return ApiaryFormState(
      name: name ?? this.name,
      address: address ?? this.address,
      appliesTreatments: appliesTreatments ?? this.appliesTreatments,
    );
  }
}

class RegisterState {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final List<ApiaryFormState> apiaries;
  final int currentStep;
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final bool showValidation;

  // Validation errors
  final String? nameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? confirmPasswordError;
  final List<String?> apiaryAddressErrors;

  // Password validation criteria
  final bool passwordHasMinLength;
  final bool passwordHasLetter;
  final bool passwordHasNumber;
  final bool passwordHasSymbol;

  const RegisterState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.apiaries = const [ApiaryFormState()],
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.showValidation = false,
    this.nameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.confirmPasswordError,
    this.apiaryAddressErrors = const [null],
    this.passwordHasMinLength = false,
    this.passwordHasLetter = false,
    this.passwordHasNumber = false,
    this.passwordHasSymbol = false,
  });

  RegisterState copyWith({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    List<ApiaryFormState>? apiaries,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool? showValidation,
    String? nameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? confirmPasswordError,
    List<String?>? apiaryAddressErrors,
    bool? passwordHasMinLength,
    bool? passwordHasLetter,
    bool? passwordHasNumber,
    bool? passwordHasSymbol,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      apiaries: apiaries ?? this.apiaries,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      showValidation: showValidation ?? this.showValidation,
      nameError: nameError,
      emailError: emailError,
      phoneError: phoneError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      apiaryAddressErrors: apiaryAddressErrors ?? this.apiaryAddressErrors,
      passwordHasMinLength: passwordHasMinLength ?? this.passwordHasMinLength,
      passwordHasLetter: passwordHasLetter ?? this.passwordHasLetter,
      passwordHasNumber: passwordHasNumber ?? this.passwordHasNumber,
      passwordHasSymbol: passwordHasSymbol ?? this.passwordHasSymbol,
    );
  }
}

class RegisterController extends StateNotifier<RegisterState> {
  final RegisterUseCase _registerUseCase;
  final GeocodingService _geocodingService;

  RegisterController(this._registerUseCase, this._geocodingService)
      : super(const RegisterState());

  void onNameChanged(String value) {
    state = state.copyWith(name: value);
    _validateName(value);
  }

  void onEmailChanged(String value) {
    state = state.copyWith(email: value);
    _validateEmail(value);
  }

  void onPhoneChanged(String value) {
    state = state.copyWith(phone: value);
    _validatePhone(value);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value);
    _validatePassword(value);
  }

  void onConfirmPasswordChanged(String value) {
    state = state.copyWith(confirmPassword: value);
    _validateConfirmPassword(value);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  bool _validateStep1() {
    _validateName(state.name);
    _validateEmail(state.email);
    _validatePhone(state.phone);
    _validatePassword(state.password);
    _validateConfirmPassword(state.confirmPassword);

    return state.nameError == null &&
        state.emailError == null &&
        state.phoneError == null &&
        state.passwordError == null &&
        state.confirmPasswordError == null;
  }

  Future<bool> _validateApiaries() async {
    final newErrors = List<String?>.filled(state.apiaries.length, null);
    bool allValid = true;
    
    for (int i = 0; i < state.apiaries.length; i++) {
      final address = state.apiaries[i].address;
      if (address.trim().isEmpty) {
        newErrors[i] = 'La dirección es requerida.';
        allValid = false;
        continue;
      }
      final isValid = await _geocodingService.validateAddress(address);
      if (!isValid) {
        newErrors[i] = 'La dirección no parece ser válida o no se encontró.';
        allValid = false;
      }
    }

    state = state.copyWith(apiaryAddressErrors: newErrors);
    return allValid;
  }

  void onStepContinue() async {
    state = state.copyWith(showValidation: true, errorMessage: null);
    if (state.currentStep == 0) {
      if (_validateStep1()) {
        state = state.copyWith(currentStep: 1);
      }
    } else if (state.currentStep == 1) {
      state = state.copyWith(isLoading: true);
      final apiariesAreValid = await _validateApiaries();
      if (apiariesAreValid) {
        await _submitRegistration();
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Por favor, corrige los errores en las direcciones de los apiarios.');
      }
    }
  }

  void onStepCancel() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void _validateName(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'El nombre es requerido';
    } else if (value.length < 2) {
      error = 'El nombre debe tener al menos 2 caracteres';
    } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      error = 'El nombre solo puede contener letras';
    }
    state = state.copyWith(nameError: error);
  }

  void _validateEmail(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'El correo es requerido';
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      error = 'Ingresa un correo válido (ej: usuario@dominio.com)';
    }
    state = state.copyWith(emailError: error);
  }

  void _validatePhone(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'El teléfono es requerido';
    } else {
      String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanPhone.length < 7) {
        error = 'Número demasiado corto';
      }
    }
    state = state.copyWith(phoneError: error);
  }

  void _validatePassword(String value) {
    final passHasMinLength = value.length >= 8;
    final passHasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final passHasNumber = RegExp(r'\d').hasMatch(value);
    final passHasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    String? error;
    if (value.isEmpty) {
      error = 'La contraseña es requerida';
    } else if (!passHasMinLength ||
        !passHasLetter ||
        !passHasNumber ||
        !passHasSymbol) {
      error = 'Debe contener al menos:';
    }

    state = state.copyWith(
      passwordError: error,
      passwordHasMinLength: passHasMinLength,
      passwordHasLetter: passHasLetter,
      passwordHasNumber: passHasNumber,
      passwordHasSymbol: passHasSymbol,
    );

    if (state.confirmPassword.isNotEmpty) {
      _validateConfirmPassword(state.confirmPassword);
    }
  }

  void _validateConfirmPassword(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Confirma tu contraseña';
    } else if (value != state.password) {
      error = 'Las contraseñas no coinciden';
    }
    state = state.copyWith(confirmPasswordError: error);
  }

  void addApiary() {
    final newApiaries = List<ApiaryFormState>.from(state.apiaries)
      ..add(const ApiaryFormState());
    final newErrors = List<String?>.from(state.apiaryAddressErrors)..add(null);
    state = state.copyWith(apiaries: newApiaries, apiaryAddressErrors: newErrors);
  }

  void removeApiary(int index) {
    if (state.apiaries.length > 1) {
      final newApiaries = List<ApiaryFormState>.from(state.apiaries)
        ..removeAt(index);
      final newErrors = List<String?>.from(state.apiaryAddressErrors)
        ..removeAt(index);
      state = state.copyWith(apiaries: newApiaries, apiaryAddressErrors: newErrors);
    }
  }

  void updateApiaryName(int index, String name) {
    final newApiaries = List<ApiaryFormState>.from(state.apiaries);
    newApiaries[index] = newApiaries[index].copyWith(name: name);
    state = state.copyWith(apiaries: newApiaries);
  }

  void updateApiaryAddress(int index, String address) {
    final newApiaries = List<ApiaryFormState>.from(state.apiaries);
    newApiaries[index] = newApiaries[index].copyWith(address: address);
    
    // Clear the error for this specific address field when the user types
    final newErrors = List<String?>.from(state.apiaryAddressErrors);
    if(newErrors.length > index) {
        newErrors[index] = null;
    }

    state = state.copyWith(apiaries: newApiaries, apiaryAddressErrors: newErrors, errorMessage: null);
  }

  void updateApiaryTreatment(int index, bool appliesTreatments) {
    final newApiaries = List<ApiaryFormState>.from(state.apiaries);
    newApiaries[index] =
        newApiaries[index].copyWith(appliesTreatments: appliesTreatments);
    state = state.copyWith(apiaries: newApiaries);
  }

  Future<void> _submitRegistration() async {
    final params = RegisterParams(
      name: state.name,
      email: state.email,
      phone: state.phone.replaceAll(RegExp(r'[^\d]'), ''),
      password: state.password,
      apiaries: state.apiaries
          .map((a) => Apiary(
                apiaryName: a.name,
                location: a.address,
                treatments: a.appliesTreatments,
              ))
          .toList(),
    );

    final result = await _registerUseCase(params);
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }
}

final registerControllerProvider = StateNotifierProvider.autoDispose<
    RegisterController, RegisterState>((ref) {
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final geocodingService = ref.watch(geocodingServiceProvider);
  return RegisterController(registerUseCase, geocodingService);
});
