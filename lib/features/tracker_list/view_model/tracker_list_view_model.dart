import 'package:collection/collection.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/repository/tracker_list_repository.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/uistate/tracker_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tracker_list_view_model.g.dart';

@Riverpod(keepAlive: true)
class TrackerListViewModel extends _$TrackerListViewModel {
  late TrackerListRepository _repository;

  @override
  FutureOr<TrackerListState> build() async {
    _repository = await ref.watch(trackerListRepositoryProvider.future);

    final trackers = await _repository.getTrackeres();
    final totalsMap = await _repository.getTotalAmountGroupedByType();

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

    return TrackerListState(
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
      currentState.copyWith(trackListSlectedDate: newDate),
    );
  }

  Future<bool> addTracker({
    required String type,
    required int amount,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final tracker = TrackerItem(
          id: const Uuid().v4(),
          type: type,
          amount: amount,
          description: description,
          date: state.value?.selectedDate ?? DateTime.now());
      state = const AsyncValue.loading();
      await _repository.insertTracker(tracker);
      await refreshTrackeres();

      return true;
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
      return state.hasError;
    }
  }

  Future<void> updateTracker(TrackerItem Tracker) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTracker(Tracker);
      await refreshTrackeres();
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> deleteTracker(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTracker(id);
      await refreshTrackeres();
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> refreshTrackeres() async {
    state = const AsyncValue.loading();
    try {
      final Trackeres = await _repository.getTrackeres();
      state = AsyncData(TrackerListState(item: Trackeres));
      await getTrackersTotalByType();
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> getTrackersFromDate(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final Trackeres = await _repository.getTrackersByDate(date);
      state = AsyncData(
          TrackerListState(item: Trackeres, trackListSlectedDate: date));
      await getTrackersTotalByType();
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> getTrackersTotalByType() async {
    int totalIncome = 0;
    int totalExpense = 0;
    int totalWithdrawal = 0;
    int totalSavings = 0;

    try {
      final totalsMap = await _repository.getTotalAmountGroupedByType();
      for (final entry in totalsMap.entries) {
        if (entry.key == "Income") {
          totalIncome += entry.value;
        } else if (entry.key == "Withdrawal" || entry.key == "Withrawal") {
          totalWithdrawal += entry.value;
        } else if (entry.key == "Savings") {
          totalSavings += entry.value;
        } else {
          if (entry.key == "Savings") {
          totalSavings += entry.value;
        }
          totalExpense += entry.value;
        }
      }

      final totalAllowance = totalIncome - totalExpense - totalSavings;

      final currentState = state.value;
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
}
