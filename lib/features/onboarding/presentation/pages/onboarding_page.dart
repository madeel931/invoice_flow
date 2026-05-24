import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../config/routes/route_constants.dart';
import '../../../../core/widgets/global_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Cubit cleanly at the route level
    return BlocProvider(
      create: (_) => GetIt.instance<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Hardcoded for setup; in production, this could be a localized list
  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'INR',
    'AUD',
    'CAD'
  ];
  String? _selectedCurrency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard
      context.read<OnboardingCubit>().submitSetup(
            businessName: _nameController.text,
            currencyCode: _selectedCurrency!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingCubit, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state is OnboardingSuccess) {
              context.go(AppRoutes
                  .dashboard); // Let GoRouter handle the navigation transition
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.business_center_rounded,
                          size: 64, color: Color(0xFF2563EB)),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to InvoiceFlow Pro',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set up your business profile to start generating professional invoices.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          prefixIcon: Icon(Icons.storefront_rounded),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your business name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Base Currency',
                          prefixIcon: Icon(Icons.payments_rounded),
                        ),
                        items: _currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      GlobalButton(
                        text: 'Complete Setup',
                        isLoading: state is OnboardingLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
