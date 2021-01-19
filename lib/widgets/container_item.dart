import 'package:flutter/material.dart';

class ContainerItem extends StatelessWidget {
  const ContainerItem({Key key, this.name, this.value}) : super(key: key);

  final String name;

  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name),
                  Text(
                    value,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
