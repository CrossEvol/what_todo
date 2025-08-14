// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Flutter code sample for [Dismissible].

class DismissibleExample extends StatefulWidget {
  const DismissibleExample({super.key});

  @override
  State<DismissibleExample> createState() => _DismissibleExampleState();
}

class _DismissibleExampleState extends State<DismissibleExample> {
  List<int> items = List<int>.generate(100, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          background: Container(
            color: Colors.green,
          ),
          key: ValueKey<int>(items[index]),
          onDismissed: (DismissDirection direction) {
            setState(() {
              items.removeAt(index);
            });
          },
          child: ListTile(
            title: Text(
              'Item ${items[index]}',
            ),
          ),
        );
      },
    );
  }
}
