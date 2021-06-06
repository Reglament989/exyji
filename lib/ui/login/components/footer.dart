import 'package:exyji/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.login_signUpTooltip.tr(),
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
        ),
        Row(
          children: [
            Text(LocaleKeys.login_changeServerTooltip.tr(),
                style: TextStyle(
                    fontSize: 13, color: Colors.white.withOpacity(0.7))),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.info,
                  size: 18,
                  color: Colors.white.withOpacity(0.6),
                ))
          ],
        )
      ],
    );
  }
}
