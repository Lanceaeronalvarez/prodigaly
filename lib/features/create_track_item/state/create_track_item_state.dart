import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


part 'create_track_item_state.freezed.dart';

part 'create_track_item_state.g.dart';

@freezed
abstract class CreateTrackItemState with _$CreateTrackItemState {
  const factory CreateTrackItemState({
    @Default(null) DateTime? date,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _CreateTrackItemState;

  factory CreateTrackItemState.fromJson(Map<String, Object?> json) =>
      _$CreateTrackItemStateFromJson(json);
}