import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

enum CustomerListStatus { initial, loading, loaded, error }

class CustomerListState extends Equatable {
  final CustomerListStatus status;
  final List<Customer> allCustomers;
  final List<Customer> filteredCustomers;
  final String? errorMessage;
  final String searchQuery;

  const CustomerListState({
    this.status = CustomerListStatus.initial,
    this.allCustomers = const [],
    this.filteredCustomers = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  CustomerListState copyWith({
    CustomerListStatus? status,
    List<Customer>? allCustomers,
    List<Customer>? filteredCustomers,
    String? errorMessage,
    String? searchQuery,
  }) {
    return CustomerListState(
      status: status ?? this.status,
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      errorMessage: errorMessage, // Intentionally nullable to clear past errors
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allCustomers,
        filteredCustomers,
        errorMessage,
        searchQuery,
      ];
}
