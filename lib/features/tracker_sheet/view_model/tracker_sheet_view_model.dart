import 'package:collection/collection.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/repository/tracker_list_repository.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_sheet/state/tracker_sheet_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tracker_sheet_view_model.g.dart';

@Riverpod(keepAlive: true)
class TrackerSheetViewModel extends _$TrackerSheetViewModel {
  late TrackerListRepository _repository;

  @override
  FutureOr<TrackerSheetState> build() async {
    _repository = await ref.watch(trackerListRepositoryProvider.future);

    final trackers = await _repository.getTrackeres();
    final totalsMap =
        await _repository.getTotalAmountGroupedByTypeAndDate(null);

    int totalIncome = 0;
    int totalExpense = 0;
    int totalWithdrawal = 0;
    int totalSavings = 0;

   for (final entry in totalsMap.entries) {
      if (entry.key == "Income") {
        totalIncome += entry.value;
      } else if (entry.key == "Withdrawal" || entry.key == "Withrawal") {
        totalWithdrawal += entry.value;
      } else if (entry.key == "Savings") {
        totalSavings += entry.value;
      } else {
        totalExpense += entry.value;
      }
    }
    final totalAllowance = totalIncome - totalExpense - totalSavings;

    totalsMap.removeWhere((type, amount) => type.contains("Income"));

    return TrackerSheetState(
        item: trackers,
        totalsByType: totalsMap,
        totalAllowance: totalAllowance,
        totalExpenses: totalExpense,
        totalIncome: totalIncome,
        totalWithdrawal: totalWithdrawal, 
        totalSavings: totalSavings - totalWithdrawal);
  }

  void updateSelectedDate(DateTime newDate) {
    // Get current data value safely
    final currentState = state.value;
    if (currentState == null) return;

    // Emit new updated state
    state = AsyncData(
      currentState.copyWith(selectedDate: newDate),
    );
  }

  void updateTrackListSelectedDate(DateTime newDate) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(selectedDate: newDate),
    );
  }

  Future<void> refreshTrackeres() async {
    state = const AsyncValue.loading();
    try {
      final Trackeres = await _repository.getTrackeres();
      state = AsyncData(TrackerSheetState(item: Trackeres));
      await getTrackersTotalByType(null);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> getTrackersFromDate(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final Trackeres = await _repository.getTrackersByDate(date);
      state = AsyncData(TrackerSheetState(item: Trackeres, selectedDate: date));
      await getTrackersTotalByType(date);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> getTrackersTotalByType(DateTime? date) async {
    int totalIncome = 0;
    int totalExpense = 0;
    int totalWithdrawal = 0;
    int totalSavings = 0;

    try {
      final totalsMap =
          await _repository.getTotalAmountGroupedByTypeAndDate(date);
        for (final entry in totalsMap.entries) {
       if (entry.key == "Income") {
        totalIncome += entry.value;
      } else if (entry.key == "Withdrawal" || entry.key == "Withrawal") {
        totalWithdrawal += entry.value;
      } else if (entry.key == "Savings") {
        totalSavings += entry.value;
      } else {
        totalExpense += entry.value;
      }
      }

      final totalAllowance = totalIncome - totalExpense - totalSavings;

      final currentState = state.value;
      totalsMap.removeWhere((type, amount) => type.contains("Income"));

      if (currentState == null) return;

      state = AsyncData(
        currentState.copyWith(
            totalsByType: totalsMap,
            totalAllowance: totalAllowance,
            totalExpenses: totalExpense,
            totalIncome: totalIncome, 
            totalWithdrawal: totalWithdrawal,
            totalSavings: totalSavings - totalWithdrawal),
      );
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> setTouchIndex(int touch) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(touchedIndex: touch),
    );
  }
}
