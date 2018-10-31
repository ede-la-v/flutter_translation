import 'package:flutter/widgets.dart';
import 'package:flutter_tensoring/bloc.dart';

class BlocProvider extends InheritedWidget {
  final Bloc bloc;

  BlocProvider({
    Key key,
    Bloc bloc,
    Widget child,
  })  : bloc = bloc ?? Bloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static Bloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider)
          .bloc;
}