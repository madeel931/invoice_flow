import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/add_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import 'customer_list_state.dart';

class CustomerListCubit extends Cubit<CustomerListState> {
  final GetCustomersUseCase getCustomers;
  final AddCustomerUseCase addCustomer;
  final UpdateCustomerUseCase updateCustomer;
  final DeleteCustomerUseCase deleteCustomer;

  CustomerListCubit({
    required this.getCustomers,
    required this.addCustomer,
    required this.updateCustomer,
    required this.deleteCustomer,
  }) : super(const CustomerListState());

  Future<void> loadCustomers() async {
    emit(state.copyWith(status: CustomerListStatus.loading));

    final result = await getCustomers(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerListStatus.error,
        errorMessage: failure.message,
      )),
      (customers) => emit(state.copyWith(
        status: CustomerListStatus.loaded,
        allCustomers: customers,
        filteredCustomers: _filter(customers, state.searchQuery),
      )),
    );
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredCustomers: _filter(state.allCustomers, query),
    ));
  }

  List<Customer> _filter(List<Customer> list, String query) {
    if (query.trim().isEmpty) return list;
    final lowerQuery = query.toLowerCase();
    return list.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          (c.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<void> saveCustomer(Customer customer) async {
    // If it has an ID, it's an update. Otherwise, it's a new customer.
    final isUpdate = customer.id != null;

    final result = isUpdate
        ? await updateCustomer(CustomerParams(customer: customer))
        : await addCustomer(CustomerParams(customer: customer));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerListStatus.error,
        errorMessage: failure.message,
      )),
      (savedCustomer) {
        // Optimistically update the in-memory list to avoid a full DB re-fetch
        final updatedList = List<Customer>.from(state.allCustomers);
        if (isUpdate) {
          final index = updatedList.indexWhere((c) => c.id == savedCustomer.id);
          if (index != -1) updatedList[index] = savedCustomer;
        } else {
          updatedList.add(savedCustomer);
          // Keep it alphabetically sorted
          updatedList.sort((a, b) => a.name.compareTo(b.name));
        }

        emit(state.copyWith(
          status: CustomerListStatus.loaded,
          allCustomers: updatedList,
          filteredCustomers: _filter(updatedList, state.searchQuery),
        ));
      },
    );
  }

  Future<void> removeCustomer(int id) async {
    final result = await deleteCustomer(DeleteCustomerParams(id: id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerListStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedList =
            state.allCustomers.where((c) => c.id != id).toList();
        emit(state.copyWith(
          status: CustomerListStatus.loaded,
          allCustomers: updatedList,
          filteredCustomers: _filter(updatedList, state.searchQuery),
        ));
      },
    );
  }
}
