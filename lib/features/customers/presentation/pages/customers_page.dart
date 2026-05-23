import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/presentation/widgets/surface_card.dart';
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
      child: const _CustomersView(),
    );
  }
}

class _CustomersView extends StatefulWidget {
  const _CustomersView();

  @override
  State<_CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<_CustomersView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCustomerForm([Customer? customer]) async {
    final result = await CustomerFormSheet.show(context, customer: customer);
    if (result != null && mounted) {
      context.read<CustomerListCubit>().saveCustomer(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      body: BlocConsumer<CustomerListCubit, CustomerListState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CustomerListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.allCustomers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No customers yet.',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Add your first client to start invoicing.'),
                ],
              ),
            );
          }

          if (state.filteredCustomers.isEmpty) {
            return const Center(child: Text('No matching customers found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.filteredCustomers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final customer = state.filteredCustomers[index];
              return SurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      customer.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      customer.email ?? customer.phone ?? 'No contact info'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showCustomerForm(customer),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () => context
                            .read<CustomerListCubit>()
                            .removeCustomer(customer.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
      ),
    );
  }
}
