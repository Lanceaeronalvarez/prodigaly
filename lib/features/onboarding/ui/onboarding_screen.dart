import 'package:flutter/material.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/state/profile_state.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/widgets/avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../extensions/build_context_extension.dart';
import '../../../features/common/ui/widgets/common_text_form_field.dart';
import '../../../features/common/ui/widgets/primary_button.dart';
import '../../../features/profile/ui/view_model/profile_view_model.dart';
import '../../../routing/routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final isEnabled = _nameController.text.trim().isNotEmpty;
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider); // Listens to state updates
final profileNotifier = ref.read(profileViewModelProvider.notifier);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  profileNotifier.selectImage(context);
                },
                child: Avatar(url: profileState.value?.imgUrl, isProfile: true,)
              ),
              const SizedBox(height: 24),
              CommonTextFormField(
                label: 'Your Name',
                controller: _nameController,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Continue',
                onPressed: () => _saveNameAndContinue(context, profileState.value?.imgUrl),
                isEnable: _isButtonEnabled,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNameAndContinue(BuildContext context, String? imgUrl) async {
    try {
      await ref.read(profileViewModelProvider.notifier).setWasShowOnboarding();
      await ref.read(profileViewModelProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            avatar: imgUrl
          );
      if (context.mounted) {
        context.pushReplacement(Routes.main);
      }
    } catch (error) {
      if (context.mounted) {
        context.showErrorSnackBar('Failed to save profile');
      }
    }
  }
}
