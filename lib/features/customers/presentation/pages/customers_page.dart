import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/global_card.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_list_cubit.dart';
import '../cubit/customer_list_state.dart';
import '../widgets/customer_form_sheet.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CustomerListCubit>()..loadCustomers(),
      child: const _CustomersListView(),
    );
  }
}

class _CustomersListView extends StatefulWidget {
  const _CustomersListView();

  @override
  State<_CustomersListView> createState() => _CustomersListViewState();
}

class _CustomersListViewState extends State<_CustomersListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // FIX: Properly await the result from your static show() method
  Future<void> _openCustomerForm(BuildContext context,
      {Customer? customer}) async {
    final result = await CustomerFormSheet.show(context, customer: customer);

    // If the user saved the form, the sheet returns a Customer object.
    // We send it to your existing saveCustomer method!
    if (result != null && context.mounted) {
      context.read<CustomerListCubit>().saveCustomer(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<CustomerListCubit>().search(val),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CustomerListCubit>().search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CustomerListCubit, CustomerListState>(
        builder: (context, state) {
          if (state.status == CustomerListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredCustomers.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No customers yet',
              message: 'Add customers to create invoices faster.',
              buttonText: 'Add Customer',
              onButtonPressed: () => _openCustomerForm(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.filteredCustomers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final customer = state.filteredCustomers[index];

              return GlobalCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                  title: Text(customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      customer.email ?? customer.phone ?? 'No contact info'),
                  trailing: const Icon(Icons.chevron_right_rounded),

                  // --- INTERACTION LOGIC ---
                  onTap: () async {
                    // Push to detail page and await the result
                    final intent = await context.push('${AppRoutes.customerDetail}/${customer.id}');

                    if (!context.mounted) return;

                    if (intent == 'delete') {
                      // FIX: Using your exact Cubit method `removeCustomer(int id)`
                      context
                          .read<CustomerListCubit>()
                          .removeCustomer(customer.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Customer deleted successfully.')),
                      );
                    } else if (intent == 'edit') {
                      // Call the form opening method
                      _openCustomerForm(context, customer: customer);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customer_add_fab',
        onPressed: () => _openCustomerForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
