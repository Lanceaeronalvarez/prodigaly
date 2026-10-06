import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_riverpod/extensions/date_time_extension.dart';
import 'package:flutter_mvvm_riverpod/features/common/ui/widgets/common_empty_data.dart';
import 'package:flutter_mvvm_riverpod/features/common/ui/widgets/common_error.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/view_model/profile_view_model.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/widgets/avatar.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/widgets/profile_item.dart';
import 'package:flutter_mvvm_riverpod/features/profile/ui/widgets/upgrade_premium_button.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/view_model/tracker_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../extensions/build_context_extension.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../theme/app_theme.dart';

import 'widgets/track_item.dart';
import 'widgets/shimmer_tracker_list.dart';

class TrackerListScreen extends ConsumerWidget {
  const TrackerListScreen({super.key});

  String _getGreeting() {
    final currentHour = DateTime.now().hour;
    if (currentHour >= 5 && currentHour < 12) return LocaleKeys.goodMorning;
    if (currentHour >= 12 && currentHour < 18) return LocaleKeys.goodAfternoon;
    return LocaleKeys.goodEvening;
  }

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
                      .read(trackerListViewModelProvider.notifier)
                      .getTrackersFromDate(value);
                });
              },
            ),
            Text(selectedDate != null
                ? selectedDate.toddMMYYYY()
                : "Select Date..."),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                ref
                    .read(trackerListViewModelProvider.notifier)
                    .refreshTrackeres();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget totalCardFactory(
    BuildContext context,
    String type,
    int amount,
    Icon icon,
  ) {
    return Card(
        child: Container(
          width: MediaQuery.of(context).size.width /2.2,
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon,
          Column(
            children: [
              Text(type),
              Text(
                '₱$amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    ));
  }

  Widget showTotals(BuildContext context, int? totalIncome, int? totalAllowance,
      int? totalExpenses, int? totalWithdrawal, int? totalSavings) {
    double iconSize = 30;
    return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          children: [
            Card(
                child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                Icon(Icons.money, color: Colors.green, size: iconSize),
                Text("Total Income:"),
                Text(
                  '₱${totalIncome ?? 0}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ]),
            )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                totalCardFactory(context, "Total Savings:", totalSavings ?? 0,
                    Icon(MingCuteIcons.mgc_pig_money_fill, color: Colors.blue, size: iconSize)),
                totalCardFactory(
                    context,
                    "Total Allowance:",
                    totalAllowance ?? 0,
                    Icon(MingCuteIcons.mgc_receive_money_line,
                        color: Colors.deepPurple, size: iconSize)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                totalCardFactory(
                  context,
                  "Total Withdrawal:",
                  totalWithdrawal ?? 0,
                  Icon(MingCuteIcons.mgc_pig_money_line,
                      color: Colors.brown, size: iconSize),
                ),
                totalCardFactory(
                  context,
                  "Total Expenses:",
                  totalExpenses ?? 0,
                  Icon(MingCuteIcons.mgc_bank_card_fill,
                      color: Colors.red, size: 40),
                ),
              ],
            )
          ],
        ));
  }

  Widget dateTotalWidget(
      BuildContext context,
      int? totalIncome,
      int? totalAllowance,
      int? totalExpenses,
      int? totalWithdrawal,
      int? totalSavings,
      DateTime? selectedDate,
      WidgetRef ref) {
    return Column(
      children: [
        showDate(context, selectedDate, ref),
        showTotals(context, totalIncome, totalAllowance, totalExpenses,
            totalWithdrawal, totalSavings),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerListState = ref.watch(trackerListViewModelProvider);
    final notifier = ref.read(trackerListViewModelProvider.notifier);
      final profile =
        ref.watch(profileViewModelProvider.select((it) => it.value?.profile));

    return Scaffold(
      backgroundColor: context.secondaryBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr(_getGreeting()),
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
      body: trackerListState.when(
        data: (state) {
          if (state.isLoading) {
            return const ShimmerTrackerList();
          }
          if (state.errorMessage != null) {
            return Column(
              children: [
                dateTotalWidget(
                    context,
                    state.totalIncome,
                    state.totalAllowance,
                    state.totalExpenses,
                    state.totalWithdrawal,
                    state.totalSavings,
                    state.trackListSlectedDate,
                    ref),
                CommonError()
              ],
            );
          }
          if (state.item.isEmpty) {
            return Column(
              children: [
                dateTotalWidget(
                    context,
                    state.totalIncome,
                    state.totalAllowance,
                    state.totalExpenses,
                    state.totalWithdrawal,
                    state.totalSavings,
                    state.trackListSlectedDate,
                    ref),
                CommonEmptyData()
              ],
            );
          }
          return Column(
            children: [
              dateTotalWidget(
                  context,
                  state.totalIncome,
                  state.totalAllowance,
                  state.totalExpenses,
                  state.totalWithdrawal,
                  state.totalSavings,
                  state.trackListSlectedDate,
                  ref),
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 128),
                itemCount: state.item.length,
                itemBuilder: (context, index) {
                  final item = state.item[index];
                  return TrackItemWidget(
                    type: item.type,
                    description: item.description,
                    amount: item.amount,
                    date: item.date,
                    onClick: () {},
                  );
                },
              ))
            ],
          );
        },
        loading: () => const ShimmerTrackerList(),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }
}
