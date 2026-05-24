import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/route_constants.dart';
import '../../domain/entities/invoice_status.dart';
import '../cubit/invoice_list_cubit.dart';
import '../cubit/invoice_list_state.dart';

class InvoicesListPage extends StatelessWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InvoicesListView();
  }
}

class _InvoicesListView extends StatefulWidget {
  const _InvoicesListView();

  @override
  State<_InvoicesListView> createState() => _InvoicesListViewState();
}

class _InvoicesListViewState extends State<_InvoicesListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.unpaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.cancelled:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(120), // Expanded to fit search + chips
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      context.read<InvoiceListCubit>().search(val),
                  decoration: InputDecoration(
                    hintText: 'Search invoice # or customer...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<InvoiceListCubit>().search('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: Row(
                  children: [null, ...InvoiceStatus.values].map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status?.name.toUpperCase() ?? 'ALL'),
                        selected: context.select(
                                (InvoiceListCubit c) => c.state.filterStatus) ==
                            status,
                        onSelected: (_) => context
                            .read<InvoiceListCubit>()
                            .filterByStatus(status),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<InvoiceListCubit, InvoiceListState>(
        builder: (context, state) {
          if (state.status == InvoiceListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredInvoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No invoices found.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.filteredInvoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final inv = state.filteredInvoices[index];
              return Card(
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _getStatusColor(inv.status).withOpacity(0.1),
                    child:
                        Icon(Icons.receipt, color: _getStatusColor(inv.status)),
                  ),
                  title: Text(inv.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${inv.customerName} • ${DateFormat('MMM dd').format(inv.issueDate)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(inv.totalAmount.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(inv.status.name.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(inv.status))),
                        ],
                      ),
                      // ADDED: Status Management Menu
                      // ADDED: Status Management Menu & View PDF
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'view_pdf') {
                            context.push(AppRoutes.invoiceDetail, extra: inv);
                          } else {
                            // Convert string back to InvoiceStatus
                            final newStatus = InvoiceStatus.values
                                .firstWhere((e) => e.name == value);
                            context
                                .read<InvoiceListCubit>()
                                .updateStatus(inv, newStatus);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'view_pdf',
                              child: Row(children: [
                                Icon(Icons.picture_as_pdf_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('View PDF')
                              ])),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                              value: 'paid', child: Text('Mark as Paid')),
                          const PopupMenuItem(
                              value: 'unpaid', child: Text('Mark as Unpaid')),
                          const PopupMenuItem(
                              value: 'overdue', child: Text('Mark as Overdue')),
                          const PopupMenuItem(
                              value: 'cancelled',
                              child: Text('Cancel Invoice')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
