import 'package:flutter/material.dart';

class AddTranslation extends StatefulWidget {
  final onSubmit;

  const AddTranslation({
    Key key,
    @required this.onSubmit,
  })  : assert(onSubmit != null),
        super(key: key);

  @override
  AddState createState() => new AddState();
}

class AddState extends State<AddTranslation> {
  bool verb = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.5),
      body: Container(
        margin: EdgeInsets.only(
            left: 15.0, 
            right: 15.0,
            bottom: 15.0,
            top: 60.0
        ),
        color: Colors.blueGrey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                  Container(
                    width: 45.0,
                    height: 45.0,
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                        "Ajouter une traduction",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[700]
                        ),
                    ),
                  )
                ),
                Container(
                    child: CloseButton(),
                  ),
              ],
            ),
            NonVerb(onSubmit: widget.onSubmit,)
          ],
        ),
      ),
    );
  }
}

class NonVerb extends StatefulWidget {
  final onSubmit;
  final verb;

  const NonVerb({
    Key key,
    @required this.onSubmit,
  })  : assert(onSubmit != null),
        super(key: key);

  @override
  NonVerbState createState() => new NonVerbState();
}

class NonVerbState extends State<NonVerb> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController frenchController = new TextEditingController();
  TextEditingController spanishController = new TextEditingController();
  FocusNode _focusSpanish = FocusNode();
  FocusNode _focusFrench = FocusNode();
  bool formWasSubmitted = false;
  bool verb = false;

  @override
  void initState() {
    super.initState();
    _focusSpanish.addListener(_onFocusSpanish);
    _focusFrench.addListener(_onFocusFrench);
  }

  void _onFocusSpanish(){
    _formKey.currentState.validate();
  }

  void _onFocusFrench(){
    _formKey.currentState.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CheckboxListTile(
                title: Text("Est-ce que c'est un verbe?"),
                value: verb,
                onChanged: (bool) {
                  print(verb);
                  setState(() {
                    verb = !verb;
                  });
                  print(verb);
                }
            ),
            TextFormField(
              focusNode: _focusSpanish,
              controller: spanishController,
              validator: (value) {
                if (value.isEmpty && !_focusSpanish.hasFocus && formWasSubmitted) {
                  return 'Please enter some text';
                }
              },
              decoration: InputDecoration(
                  labelText: "Espagnol"
              ),
            ),
            TextFormField(
              focusNode: _focusFrench,
              controller: frenchController,
              validator: (value) {
                if (value.isEmpty && !_focusFrench.hasFocus && formWasSubmitted) {
                  return 'Please enter some text';
                }
              },
              decoration: InputDecoration(
                  labelText: "Français"
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 20.0),
              child: RaisedButton(
                onPressed: () {
                  formWasSubmitted = true;
                  _focusFrench.unfocus();
                  _focusSpanish.unfocus();
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('Processing Data')));

                  }
                  print('widget.onsubm,it'+widget.onSubmit.toString());
                  var spanish = spanishController.text[0].toUpperCase() +
                      spanishController.text.substring(1);
                  var french = frenchController.text[0].toUpperCase() +
                                frenchController.text.substring(1);
                  print("verb");
                  print(verb);
                  widget.onSubmit(
                      spanish,
                      french,
                      verb
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}