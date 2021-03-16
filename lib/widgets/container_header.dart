import 'package:flutter/material.dart';

class ContainerHeader extends StatelessWidget {
  const ContainerHeader({Key key, this.name}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.33),
      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).cardColor, width: 0.5)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
