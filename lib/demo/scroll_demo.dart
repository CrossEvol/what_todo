import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Long List Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LongListPage(),
      restorationScopeId: 'app', // Enable restoration for the app
    );
  }
}

class LongListPage extends StatefulWidget {
  const LongListPage({super.key});

  @override
  State<LongListPage> createState() => _LongListPageState();
}

class _LongListPageState extends State<LongListPage> with RestorationMixin {
  final ScrollController _scrollController = ScrollController();
  final RestorableDouble _scrollOffset = RestorableDouble(0.0);

  @override
  String get restorationId => 'long_list_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_scrollOffset, 'scroll_offset');
    // Restore scroll position after state restoration
    if (_scrollOffset.value > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollOffset.value);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Update scroll offset whenever the user scrolls
    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Long List')),
      body: ListView.builder(
        // controller: _scrollController, // this is not necessary
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailPage()),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: const Center(child: Text('This is the detail page')),
    );
  }
}
