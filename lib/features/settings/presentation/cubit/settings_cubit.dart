import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_directories.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/usecases/get_business_profile_usecase.dart';
import '../../domain/usecases/update_business_profile_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetBusinessProfileUseCase getProfile;
  final UpdateBusinessProfileUseCase updateProfile;

  SettingsCubit({
    required this.getProfile,
    required this.updateProfile,
  }) : super(const SettingsState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await getProfile(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        profile: profile,
      )),
    );
  }

  Future<void> pickAndSaveLogo(String tempPath) async {
    if (state.profile == null) return;

    try {
      // Create a unique filename
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(tempPath)}';
      final localPath = AppDirectories.constructImagePath(fileName);

      // Copy image from temp cache to persistent document directory
      await File(tempPath).copy(localPath);

      // Update in-memory state with JUST the filename (Update-safe for iOS)
      final updatedProfile = state.profile!.copyWith(logoPath: fileName);
      emit(state.copyWith(profile: updatedProfile));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Failed to process image: $e',
      ));
    }
  }

  Future<void> saveSettings(BusinessProfile updatedProfile) async {
    emit(state.copyWith(status: SettingsStatus.saving));

    final result = await updateProfile(
        UpdateBusinessProfileParams(profile: updatedProfile));

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: SettingsStatus.success,
        profile: profile,
      )),
    );
  }
}
