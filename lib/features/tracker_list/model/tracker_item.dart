import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracker_item.freezed.dart';
part 'tracker_item.g.dart';


@freezed
abstract class TrackerItem with _$TrackerItem {
  const factory TrackerItem({
    required String id,
    required String type,
    required int amount,
    required String description,
     @JsonKey(
      fromJson: _dateTimeFromJson,
      toJson: _dateTimeToJson,
    )
    DateTime? date,
  }) = _TrackerItem;

  factory TrackerItem.fromJson(Map<String, dynamic> json) => _$TrackerItemFromJson(json);
}

DateTime? _dateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  return null;
}

int? _dateTimeToJson(DateTime? date) {
  return date?.millisecondsSinceEpoch;
}