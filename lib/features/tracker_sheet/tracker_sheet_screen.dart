import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_riverpod/extensions/date_time_extension.dart';

import 'package:flutter_mvvm_riverpod/features/common/ui/widgets/common_empty_data.dart';
import 'package:flutter_mvvm_riverpod/features/common/ui/widgets/common_error.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/view_model/profile_view_model.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/widgets/avatar.dart';

import 'package:flutter_mvvm_riverpod/features/profile/ui/widgets/upgrade_premium_button.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';

import 'package:flutter_mvvm_riverpod/features/tracker_list/view_model/tracker_list_view_model.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/widgets/shimmer_tracker_list.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_sheet/view_model/tracker_sheet_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../extensions/build_context_extension.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../theme/app_theme.dart';

class TrackerSheetScreen extends ConsumerWidget {
  const TrackerSheetScreen({super.key});

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime date) onChanged,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  Widget showDate(BuildContext context, DateTime? selectedDate, WidgetRef ref) {
    return Card(
      color: context.secondaryBackgroundColor,
      child: SizedBox(
        height: 60,
        width: MediaQuery.sizeOf(context).width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.calendar_month,
                size: 40,
              ),
              onPressed: () {
                _selectDate(context, (value) {
                  ref
                      .read(trackerSheetViewModelProvider.notifier)
                      .getTrackersFromDate(value);
                });
              },
            ),
            Text(
              (selectedDate != null
                  ? selectedDate.toddMMYYYY()
                  : DateFormat('MMMM').format(DateTime.now())),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                ref
                    .read(trackerSheetViewModelProvider.notifier)
                    .refreshTrackeres();
              },
            )
          ],
        ),
      ),
    );
  }

  Color setPieColor(String type) {
    if (type == "Income") {
      return Colors.green;
    } else if (type == "Tithes") {
      return Colors.grey;
    } else if (type == "Gala") {
      return Colors.pink;
    } else if (type == "Savings") {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  Widget iconFactory(String type) {
    Icon icon = Icon(Icons.money, color: Colors.green, size: 30);
    if (type == "Expense") {
      icon =
          Icon(MingCuteIcons.mgc_bank_card_fill, color: Colors.red, size: 30);
    }
    if (type == "Tithes") {
      icon = Icon(MingCuteIcons.mgc_church_fill, color: Colors.grey, size: 30);
    }
    if (type == "Savings") {
      icon =
          Icon(MingCuteIcons.mgc_pig_money_fill, color: Colors.blue, size: 30);
    }
    if (type == "Gala") {
      icon = Icon(
        MingCuteIcons.mgc_love_fill,
        color: Colors.pink,
        size: 30,
      );
    }
    if (type == "Offering") {
      icon = Icon(
        MingCuteIcons.mgc_church_line,
        color: Colors.orange,
        size: 30,
      );
    }
    return Container(
      margin: EdgeInsets.all(10),
      child: icon,
    );
  }

  Color colorFactory(String type) {
    if (type == "Expense") {
      return Colors.red;
    } else if (type == "Tithes") {
      return Colors.grey;
    } else if (type == "Savings") {
      return Colors.blue;
    } else if (type == "Gala") {
      return Colors.pink;
    } else if (type == "Offering") {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget trackItemListByType(
      BuildContext context, List<TrackerItem> item, String type) {
    final sortedItem = item.where((i) => i.type == type).toList();
    return Container(
        margin: EdgeInsets.all(10),
        width: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                width: 150,
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: colorFactory(type),
                    width: 2.0, // Border thickness
                  ),
                ),
                child: Row(
                  children: [
                    iconFactory(type),
                    Text(
                      type,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                )),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sortedItem.length,
              itemBuilder: (context, index) {
                final trackItem = sortedItem[index];
                return Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: colorFactory(type),
                      width: 2.0, // Border thickness
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0), // Optional rounded corners
                  ),
                  child: Column(
                    children: [
                      Text(
                        trackItem.date!.toddMMYYYY(),
                        softWrap: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "₱${trackItem.amount}",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorFactory(type)),
                          ),
                          Text(
                            format12Hour(trackItem.date!),
                            softWrap: true,
                          )
                        ],
                      ),
                      trackItem.description != "" ? Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                        "'${trackItem.description}'",
                        softWrap: true,
                      ),
                      ): SizedBox(height: 0,)
                      
                    ],
                  ),
                );
              },
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerSheetState = ref.watch(trackerSheetViewModelProvider);
    final notifier = ref.read(trackerSheetViewModelProvider.notifier);
final profile =
        ref.watch(profileViewModelProvider.select((it) => it.value?.profile));
        
    return Scaffold(
      backgroundColor: context.secondaryBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Sheet",
          style: AppTheme.title32,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Avatar(url: profile?.avatar),
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: context.secondaryBackgroundColor,
        foregroundColor: context.primaryTextColor,
      ),
      body: trackerSheetState.when(
        data: (state) {
          if (state.isLoading) {
            return const ShimmerTrackerList();
          }
          if (state.errorMessage != null) {
            return Column(
              children: [
                showDate(context, state.selectedDate, ref),
                CommonError()
              ],
            );
          }
          if (state.item.isEmpty) {
            return Column(
              children: [
                showDate(context, state.selectedDate, ref),
                CommonEmptyData()
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                showDate(context, state.selectedDate, ref),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 0),
                      child: Text(
                        "Spendings Chart:",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        textAlign: TextAlign.start,
                      ),
                    )),
                     Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(10, 0, 10, 10),
                      child: Text(
                        "Total Income: ₱${state.totalIncome}",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                        textAlign: TextAlign.start,
                      ),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  height: state.totalsByType != null
                      ? MediaQuery.heightOf(context) / 3
                      : 100,
                  child: state.totalsByType != null
                      ? PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  notifier.setTouchIndex(-1);
                                  return;
                                }
                                notifier.setTouchIndex(pieTouchResponse
                                    .touchedSection!.touchedSectionIndex);
                              },
                            ),

                            sectionsSpace: 5, // Space between slices
                            centerSpaceRadius: 70, // Space between slices
                            sections: state.totalsByType!.entries
                                .mapIndexed((i, entry) {
                              final isTouched = i == state.touchedIndex;
                              final fontSize = isTouched ? 25.0 : 16.0;
                              final radius = isTouched
                                  ? 70.0
                                  : 50.0; // Grows slightly when selected
                              const shadows = [
                                Shadow(color: Colors.white, blurRadius: 2)
                              ];
                              String title = isTouched
                                  ? "${entry.key} \n₱${entry.value}"
                                  : entry.key;
                              return PieChartSectionData(
                                value: entry.value / 10, // or 20
                                title: title,
                                color: setPieColor(entry.key),
                                radius: radius,
                                titleStyle: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    shadows: shadows), // optional label
                              );
                            }).toList(),
                          ),
                          duration: Duration(milliseconds: 150), // Optional
                          curve: Curves.linear,
                        )
                      : Text("No Chart To Show"),
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 2.5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          trackItemListByType(context, state.item, "Income"),
                          trackItemListByType(context, state.item, "Expense"),
                          trackItemListByType(context, state.item, "Tithes"),
                          trackItemListByType(context, state.item, "Offering"),
                          trackItemListByType(context, state.item, "Savings"),
                          trackItemListByType(context, state.item, "Gala"),
                        ],
                      ),
                    )),
                SizedBox(
                  height: 500,
                )
              ],
            ),
          );
        },
        loading: () => const ShimmerTrackerList(),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  String format12Hour(DateTime dateTime) {
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
