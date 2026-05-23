import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import 'add_customer_usecase.dart';

class UpdateCustomerUseCase implements UseCase<Customer, CustomerParams> {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Customer>> call(CustomerParams params) async {
    if (params.customer.id == null) {
      return const Left(ValidationFailure('Invalid customer ID.'));
    }
    if (params.customer.name.trim().isEmpty) {
      return const Left(ValidationFailure('Customer name cannot be empty.'));
    }
    return await repository.updateCustomer(params.customer);
  }
}
