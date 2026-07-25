import '../../../../core/models/paged_result.dart';
import '../entities/payment_method.dart';
import '../entities/work_order_detail.dart';
import '../entities/work_order_header_input.dart';
import '../entities/work_order_input.dart';
import '../entities/work_order_status.dart';
import '../entities/work_order_summary.dart';

abstract class WorkOrdersRepository {
  /// `GET /work-order-statuses` — catalog for filters/steppers.
  Future<List<WorkOrderStatus>> getStatuses();

  /// `GET /workshops/{ws}/work-orders` — paginated
  /// (`page`/`page-size`, server-side filters).
  Future<PagedResult<WorkOrderSummary>> getAll({
    String? statusCode,
    String? search,
    int page = 1,
  });

  /// `POST /workshops/{ws}/work-orders` → code of the created order.
  Future<String> create(WorkOrderInput input);

  /// `GET /work-orders/{code}`
  Future<WorkOrderDetail> getByCode(String code);

  /// `PUT /work-orders/{code}`
  Future<WorkOrderDetail> updateHeader(String code, WorkOrderHeaderInput input);

  /// `PUT /work-orders/{code}/status`.
  Future<WorkOrderDetail> changeStatus(
    String code, {
    required String statusCode,
    String? comment,
  });

  /// `POST /work-orders/{code}/products`
  Future<WorkOrderDetail> addProductLine(
    String code, {
    required String productCode,
    required double quantity,
  });

  /// `DELETE /work-orders/{code}/products/{lineId}`
  Future<WorkOrderDetail> removeProductLine(String code, int lineId);

  /// `POST /work-orders/{code}/labors` — catalog service OR free text.
  Future<WorkOrderDetail> addLaborLine(
    String code, {
    String? serviceCode,
    String? description,
    double? hours,
    double quantity = 1,
    double? unitPrice,
  });

  /// `DELETE /work-orders/{code}/labors/{lineId}`
  Future<WorkOrderDetail> removeLaborLine(String code, int lineId);

  /// `POST /work-orders/{code}/payments` — balance/status auto-update.
  Future<WorkOrderDetail> addPayment(
    String code, {
    required double amount,
    required PaymentMethod method,
    String? reference,
    String? notes,
  });
}
