import 'package:flutter/material.dart';

// REQUIRED: Examples must be able to run as standalone apps,
// and "Flutter Showcase" will also use it to determine the primary app class
void main() => runApp(new OffsetDelayApp());

class OffsetDelayApp extends StatelessWidget {
  // REQUIRED: This is supplied by "Flutter Showcase" so that it can launch the example
  // and have the back button work properly
  final GlobalKey<NavigatorState> navkey;

  // REQUIRED: See explanation above
  OffsetDelayApp([this.navkey]);

  @override
  Widget build(BuildContext context) => new MaterialApp(
    title: 'Login Slide-in Example',
    debugShowCheckedModeBanner: false,
    home: new HomePage(),

    // REQUIRED: See explanation above
    navigatorKey: navkey,
  );
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // The overall controller for the animations. It's used to play, stop, and generally manage animations.
  AnimationController animationController;

  // This example uses 3 animations, each corresponding to a different section and each has a different delay.
  // The header section slides in first from the right,
  // then the form section slides in from the right slightly behind it,
  // then lastely footer section slides in from the bottom.
  Animation headerAnimation;
  Animation formAnimation;
  Animation footerAnimation;

  @override
  void initState() {
    super.initState();

    // Set-up the controller to show the animation over the duration of 2 seconds,
    // and set the TickerProvider to this.
    // A TickerProvider notifies objects every frame, which is of course useful for animations.
    animationController = new AnimationController(duration: const Duration(seconds: 2), vsync: this);
 
    // Tweens are very useful objects for animations.
    // They're used for interpolating from one number to another, based on the current frame. (Provided by the AnimationController)
    // In the first 2 animations below it interpolates from -1.0 to 0.0, and in the last one 1.0 to 0.0

    // The below animations are CurvedAnimations, specifically set-up as Curves.fastOutSlowIn.
    // This will dictate how values are interpolated, and hence how the animation will play out.
    // Curves.fastOutSlowIn is described as, A curve that starts quickly and eases into its final position.

    headerAnimation = new Tween(begin: -1.0, end: 0.0)
    .animate(new CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn));

    // These 2 animations are delayed by passing an Interval to curve.
    // With a begin of 0.5, it effectively becomes a 1 second animation that starts 1 second in
    // (based on the animation controller having a duration of 2 seconds)
 
    formAnimation = new Tween(begin: -1.0, end: 0.0)
    .animate(new CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));
 
    footerAnimation = new Tween(begin: 1.0, end: 0.0)
    .animate(new CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn)));
  }

  // Build the header section, which is just some header text.
  Widget _buildHeader(BuildContext context) {
    // This is the width of the screen.
    final double width = MediaQuery.of(context).size.width;

    // The transform changes the location (in this example the X location) of the section.
    // Because the headerAnimation is a tween from -1.0 to 0.0, and because we're multipling by screen width,
    // it starts off-screen to the left and moves to the right and into place.

    return new Transform(
      transform: new Matrix4.translationValues(headerAnimation.value * width, 0.0, 0.0),
      child: new Center(
        child: const Text(
          'Login',
          style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        )
      ),
    );
  }

  // Build the login form section, consisting of the username & password fields
  Widget _buildLoginForm(BuildContext context) {
    // This is the width of the screen.
    final double width = MediaQuery.of(context).size.width;

    final usernameField = new TextField(
      decoration: const InputDecoration(hintText: 'Username'),
    );

    final passwordField = new TextField(
      decoration: const InputDecoration(hintText: 'Password'),
      obscureText: true,
    );

    // The transform changes the location (in this example the X location) of the section.
    // Because the headerAnimation is a tween from -1.0 to 0.0, and because we're multipling by screen width,
    // it starts off-screen to the left and moves to the right and into place.

    return new Transform(
      transform: new Matrix4.translationValues(formAnimation.value * width, 0.0, 0.0),
      child: new Padding(
        padding: const EdgeInsets.all(25.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            usernameField,
            const SizedBox(height: 10.0),

            passwordField,
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  // Build the footer section, which has the Login/Signup buttons
  Widget _buildFooter(BuildContext context) {
    // This is the height of the screen
    final double height = MediaQuery.of(context).size.height;

    final loginButton = new RaisedButton(
      child: const Text('Login'),
      onPressed: () {},
      color: Colors.lightBlue,
      elevation: 7.0,
      textColor: Colors.white,
    );

    final signupButton = new OutlineButton(
      child: const Text('Signup'),
      onPressed: () {},
      color: Colors.lightGreen,
      textColor: Colors.green,
      highlightColor: Colors.green,
      borderSide: const BorderSide(
        color: Colors.green,
        style: BorderStyle.solid,
        width: 2.0),
    );
    
    // The transform changes the location (in this example the Y location) of the section.
    // Because the headerAnimation is a tween from 1.0 to 0.0, and because we're multipling by screen height,
    // it starts off-screen to the bottom and moves up into place.

    return new Transform(
      transform: new Matrix4.translationValues(0.0, footerAnimation.value * height, 0.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          loginButton,
          const SizedBox(height: 20.0),

          const Text('Don\'t have an account?'),
          const SizedBox(height: 20.0),

          signupButton,
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    // AnimationController.forward starts the animations it manages.
    animationController.forward();

    // AnimatedBuilder is a widget that will rebuild (i.e. call builder()) every time the animation changes.
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return Scaffold(
          body: new Align(
            alignment: Alignment.center,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                _buildHeader(context),
                _buildLoginForm(context),
                _buildFooter(context),
              ],
            ),
          ),
          // This button will replay the animation
          persistentFooterButtons: <Widget>[
            new FlatButton(
              child: new Row(
                children: <Widget>[
                  const Icon(Icons.refresh),
                  const SizedBox(width: 6.0),
                  const Text('Replay')
                ],
              ),
              onPressed: () {
                animationController.reset();
                setState(() {});
              },
            )
          ],
        );
      },
    );
  }
}