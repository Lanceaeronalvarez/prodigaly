import 'package:flutter/material.dart';
import 'package:flutter_mvvm_riverpod/extensions/date_time_extension.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '/theme/app_colors.dart';
import '/theme/app_theme.dart';

class TrackItemWidget extends StatelessWidget {
  final String type;
  final int amount;
  final String description;
  final DateTime? date;
  final VoidCallback onClick;

  const TrackItemWidget(
      {super.key,
      required this.type,
      required this.amount,
      required this.description,
      required this.date,
      required this.onClick});

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
    } else if (type == "Withdrawal" || type == "Withrawal") {
      return Colors.brown;
    } else {
      return Colors.green;
    }
  }

  Widget cardFactory(Widget children, String type) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        side: BorderSide(
          color: colorFactory(type), // Border color
          width: 2, // Border thickness
        ),
      ),
      child: Container(margin: EdgeInsets.all(10.0), child: children),
    );
  }

  Widget iconFactory(String type) {
    Icon icon = Icon(Icons.money, color: Colors.green, size: 50);
    if (type == "Expense") {
      icon =
          Icon(MingCuteIcons.mgc_bank_card_fill, color: Colors.red, size: 50);
    }
    if (type == "Tithes") {
      icon = Icon(MingCuteIcons.mgc_church_fill, color: Colors.grey, size: 50);
    }
    if (type == "Savings") {
      icon =
          Icon(MingCuteIcons.mgc_pig_money_fill, color: Colors.blue, size: 50);
    }
    if (type == "Gala") {
      icon = Icon(
        MingCuteIcons.mgc_love_fill,
        color: Colors.pink,
        size: 50,
      );
    }
    if (type == "Offering") {
      icon = Icon(
        MingCuteIcons.mgc_church_line,
        color: Colors.orange,
        size: 50,
      );
    }
    if (type == "Withdrawal" || type == "Withrawal") {
      icon = Icon(
        MingCuteIcons.mgc_pig_money_line,
        color: Colors.brown,
        size: 50,
      );
    }
    return Container(
      margin: EdgeInsets.all(10),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: cardFactory(Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              date!.toEEEddMMYYYY(),
              softWrap: true,
            ),
            Text(
              format12Hour(date!),
              softWrap: true,
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconFactory(type),
            Column(
              children: [
                Text(type),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 15,
                      child: Text('₱'),
                    ),
                    Text(
                      amount.toString(),
                      softWrap: true,
                    )
                  ],
                ),
              ],
            )
          ],
        )
      ],
    ), type));
  }

  String format12Hour(DateTime dateTime) {
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
