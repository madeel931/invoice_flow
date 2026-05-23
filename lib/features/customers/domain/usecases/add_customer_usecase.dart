import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class AddCustomerUseCase implements UseCase<Customer, CustomerParams> {
  final CustomerRepository repository;

  AddCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Customer>> call(CustomerParams params) async {
    if (params.customer.name.trim().isEmpty) {
      return const Left(ValidationFailure('Customer name cannot be empty.'));
    }
    return await repository.addCustomer(params.customer);
  }
}

class CustomerParams extends Equatable {
  final Customer customer;

  const CustomerParams({required this.customer});

  @override
  List<Object> get props => [customer];
}
