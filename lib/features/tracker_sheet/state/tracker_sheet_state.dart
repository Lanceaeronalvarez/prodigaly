import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracker_sheet_state.freezed.dart';

part 'tracker_sheet_state.g.dart';

@freezed
abstract class TrackerSheetState with _$TrackerSheetState {
  const factory TrackerSheetState({
    @Default([]) List<TrackerItem> item,
    DateTime? selectedDate,
    Map<String, int>? totalsByType,
    int? totalIncome,
    int? totalAllowance,
    int? totalExpenses,
    int? totalWithdrawal,
    int? totalSavings,
    @Default(-1) int touchedIndex,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _TrackerSheetState;

  factory TrackerSheetState.fromJson(Map<String, Object?> json) =>
      _$TrackerSheetStateFromJson(json);
}