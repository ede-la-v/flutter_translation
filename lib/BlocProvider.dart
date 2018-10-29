import 'package:flutter/widgets.dart';
import 'package:flutter_tensoring/bloc.dart';

/// This is an InheritedWidget that wraps around [CartBloc]. Think about this
/// as Scoped Model for that specific class.
///
/// This merely solves the "passing reference down the tree" problem for us.
/// You can solve this in other ways, like through dependency injection.
///
/// Also note that this does not call [CartBloc.dispose]. If your app
/// ever doesn't need to access the cart, you should make sure it's
/// disposed of properly.
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