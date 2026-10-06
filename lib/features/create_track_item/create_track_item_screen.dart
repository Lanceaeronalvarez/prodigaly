import 'package:flutter/material.dart';
import 'package:flutter_mvvm_riverpod/extensions/date_time_extension.dart';
import 'package:flutter_mvvm_riverpod/features/common/ui/widgets/common_header.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/uistate/tracker_list_state.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_list/view_model/tracker_list_view_model.dart';
import 'package:flutter_mvvm_riverpod/features/tracker_sheet/view_model/tracker_sheet_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../extensions/build_context_extension.dart';

class CreatetTrackItemScreen extends ConsumerWidget {
  const CreatetTrackItemScreen({super.key});

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

  Widget cardFactory(Widget children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        side: const BorderSide(
          color: Colors.blue, // Border color
          width: 2, // Border thickness
        ),
      ),
      child: Container(margin: EdgeInsets.all(10.0), child: children),
    );
  }

  Widget TextFieldFactory(
    TextEditingController _controller,
    String label,
    TextInputType? type,
  ) {
    return TextField(
      keyboardType: type,
      autofocus: true,
      controller: _controller,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final TextEditingController _controllerAmount = TextEditingController();
    final TextEditingController _controllerDescription =
        TextEditingController();
    final TextEditingController _controllerType = TextEditingController();

    final trackerListState = ref.watch(trackerListViewModelProvider);
    

    final TrackerListState? state = trackerListState.valueOrNull;

    const items = [
      DropdownMenuItem(value: 'Income', child: Text('Income')),
      DropdownMenuItem(value: 'Expense', child: Text('Expense')),
      DropdownMenuItem(value: 'Tithes', child: Text("Tithes")),
      DropdownMenuItem(value: 'Offering', child: Text("Offering")),
      DropdownMenuItem(value: 'Savings', child: Text("Savings")),
      DropdownMenuItem(value: 'Gala', child: Text("Gala")),
      DropdownMenuItem(value: 'Withdrawal', child: Text("Withdrawal")),
    ];

    return Scaffold(
      backgroundColor: context.secondaryBackgroundColor,
      body: Column(
        children: [
          CommonHeader(header: 'Add Cash Flow'),
          Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Column(
              children: [
                cardFactory(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state?.selectedDate == null
                          ? DateTime.now().toEEEddMMYYYY()
                          : '${state!.selectedDate?.toEEEddMMYYYY()}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, (date) {
                        ref
                            .read(trackerListViewModelProvider.notifier)
                            .updateSelectedDate(date);
                      }),
                      child: const Text('Select Date'),
                    ),
                  ],
                )),
                cardFactory(DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: InputBorder
                        .none, // Removes the default underline/border
                    enabledBorder:
                        InputBorder.none, // Removes the border when enabled
                    focusedBorder:
                        InputBorder.none, // Removes the border when focused
                  ),
                  hint: Text(
                    _controllerType.text != ""
                        ? _controllerType.text
                        : "Select Type",
                  ),
                  items: items,
                  onChanged: (value) {
                    _controllerType.setText(value!);
                  },
                )),
                cardFactory(
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 15,
                        margin: EdgeInsets.only(top: 13),
                        child: Text('₱'),
                      ),
                      Expanded(
                          child: TextFieldFactory(_controllerAmount,
                              'Enter Amount', TextInputType.number))
                    ],
                  ),
                ),
                cardFactory(
                  TextFieldFactory(_controllerDescription, 'Description',
                      TextInputType.text),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref
                        .read(trackerListViewModelProvider.notifier)
                        .addTracker(
                          type: _controllerType.text,
                          description: _controllerDescription.text,
                          amount: int.tryParse(_controllerAmount.text) ?? 0,
                        );
                    if (context.mounted) {
                      if (success) {
                        await ref
                            .read(trackerSheetViewModelProvider.notifier)
                            .refreshTrackeres();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Created successfully!')),
                        );
                        ref.invalidate(trackerListViewModelProvider);
                        ref.invalidate(trackerSheetViewModelProvider);
                        Navigator.of(context)
                            .pop(); // Go back after successful save
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to create.')),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
