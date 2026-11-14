import '../domain/history_record.dart';

abstract class HistoryRepository {
  Future<List<HistoryRecord>> getHistory();
}
