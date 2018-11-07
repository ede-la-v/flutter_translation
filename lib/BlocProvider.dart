import 'package:flutter/widgets.dart';
import 'package:flutter_tensoring/blocDict.dart';
import 'package:flutter_tensoring/pages/conjugation/blocConj.dart';

class BlocProvider extends InheritedWidget {
  final BlocDict blocDict;
  final BlocConj blocConj;

  BlocProvider({
    Key key,
    BlocDict blocDict,
    BlocConj blocConj,
    Widget child,
  })  : blocDict = blocDict ?? BlocDict(),
        blocConj = blocConj ?? BlocConj(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static BlocDict of1(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider).blocDict;

  static BlocConj of2(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider).blocConj;
}