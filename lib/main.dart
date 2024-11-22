import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touna/page/drawer.dart';
import 'package:touna/provider_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

enum AppState { done, loading, error }

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey.shade200,
        ),
        home: home(context, route));
  }

  home(BuildContext context, Function(BuildContext) route) {
    // if (Platform.isAndroid) {
    //   return const JadwalMobile();
    //   // return const HomeMobilePage(title: 'Jadwal Sidang KN Touna');
    // }
    return PageView(content: route(context));
    // return const JadwalSidang();
    // return const HomePage(title: 'Jadwal Sidang KN Touna');
  }
}

class PageView extends ConsumerWidget {
  const PageView({super.key, required this.content});
  final Widget content;

  // const PageView({super.key, required super.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    return Platform.isAndroid
        ? Material(child: content)
        : Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: size.height,
                  width: 200,
                  color: Colors.pink,
                  child: const DrawerWidget(),
                ),
                Expanded(
                  child: Container(
                    height: size.height,
                    color: Colors.green,
                    child: content,
                  ),
                ),
              ],
            ),
          );
  }
}

class PageContainer extends ConsumerWidget {
  const PageContainer({
    super.key,
    this.title,
    this.actions,
    this.body,
    this.floating,
  });
  final String? title;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? ''),
        backgroundColor: Colors.grey.shade200,
        actions: actions,
      ),
      drawer: Platform.isAndroid ? const DrawerWidget() : null,
      body: body,
      floatingActionButton: floating,
    );
  }
}
