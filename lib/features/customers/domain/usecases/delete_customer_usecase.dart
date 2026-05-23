import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase implements UseCase<Unit, DeleteCustomerParams> {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteCustomerParams params) async {
    return await repository.deleteCustomer(params.id);
  }
}

class DeleteCustomerParams extends Equatable {
  final int id;

  const DeleteCustomerParams({required this.id});

  @override
  List<Object> get props => [id];
}
