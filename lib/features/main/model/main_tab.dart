import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../generated/locale_keys.g.dart';

enum MainTab {
  home(MingCuteIcons.mgc_home_3_fill, "Home"),
  sheet(MingCuteIcons.mgc_document_2_fill, "Sheet"),
  setting(MingCuteIcons.mgc_settings_3_fill, LocaleKeys.menuSetting);

  const MainTab(this.iconData, this.labelKey);

  final IconData iconData;
  final String labelKey;
}
