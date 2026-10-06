import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracker_list_state.freezed.dart';

part 'tracker_list_state.g.dart';

@freezed
abstract class TrackerListState with _$TrackerListState {
  const factory TrackerListState({
    @Default([]) List<TrackerItem> item,
    DateTime? selectedDate,
    DateTime? trackListSlectedDate,
    Map<String, int>? totalsByType,
    int? totalIncome,
    int? totalAllowance,
    int? totalExpenses,
    int? totalWithdrawal,
        int? totalSavings,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _TrackerListState;

  factory TrackerListState.fromJson(Map<String, Object?> json) =>
      _$TrackerListStateFromJson(json);
}