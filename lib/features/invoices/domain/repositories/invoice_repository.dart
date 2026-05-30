import 'package:dartz/dartz.dart' show Either, Unit;
import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, List<Invoice>>> getInvoices();
  Future<Either<Failure, String>> generateNextInvoiceNumber();
  Future<Either<Failure, Invoice?>> getInvoiceByNumber(String number);
  Future<Either<Failure, Invoice>> saveInvoice(Invoice invoice);
  Future<Either<Failure, Unit>> deleteInvoice(int id);
}
