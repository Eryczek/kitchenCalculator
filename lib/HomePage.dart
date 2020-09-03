import 'package:firstapp/app_localizations.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("home"),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,),
      body: body(orientation),

    );
  }

  Widget body(Orientation orientation){
    if(orientation == Orientation.portrait){
      return HomeBody(
        buttonMenuYAlign: 0.15,
        buttonDishesYAlign: 0.475,
        buttonIngredientsYAlign: 0.8,
        buttonMenuXAlign: 0,
        buttonDishesXAlign: 0,
        buttonIngredientsXAlign: 0,
        buttonWidth: 250,
      );
    } else{
      return HomeBody(
        buttonMenuYAlign: 0.4,
        buttonDishesYAlign: 0.4,
        buttonIngredientsYAlign: 0.4,
        buttonMenuXAlign: -0.8,
        buttonDishesXAlign: 0,
        buttonIngredientsXAlign: 0.8,
        buttonWidth: 160,
      );
    }
  }



}

class HomeBody extends StatelessWidget {

  HomeBody({this.buttonMenuYAlign,
    this.buttonDishesYAlign,
    this.buttonIngredientsYAlign,
    this.buttonMenuXAlign,
    this.buttonDishesXAlign,
    this.buttonIngredientsXAlign,
    this.buttonWidth});

  final double buttonMenuYAlign,
      buttonDishesYAlign,
      buttonIngredientsYAlign,
      buttonMenuXAlign,
      buttonDishesXAlign,
      buttonIngredientsXAlign,
      buttonWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fruits.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        HomeButton(
          text:AppLocalizations.of(context).translate("menus"),
          xAlign: buttonMenuXAlign,
          yAlign: buttonMenuYAlign,
          width: buttonWidth,
          onPressed: () => Navigator.pushNamed(context, '/ListLayouts/Menus'),
        ),
        HomeButton(
          text: AppLocalizations.of(context).translate("dishes"),
          xAlign: buttonDishesXAlign,
          yAlign: buttonDishesYAlign,
          width: buttonWidth,
          onPressed: () => Navigator.pushNamed(context, '/ListLayouts/Dishes'),
        ),
        HomeButton(
          text: AppLocalizations.of(context).translate("ingredients"),
          xAlign: buttonIngredientsXAlign,
          yAlign: buttonIngredientsYAlign,
          width: buttonWidth,
          onPressed: () => Navigator.pushNamed(context, '/ListLayouts/Ingredients'),
        ),
      ],);
  }
}



class HomeButton extends StatelessWidget {

  final Function onPressed;

  HomeButton({this.text, this.xAlign, this.yAlign, this.width, this.onPressed});


  final String text;
  final double xAlign, yAlign, width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(xAlign, yAlign),
      child: SizedBox(
        width: width,
        height: 50,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          textColor: Colors.white,
          color: Colors.deepPurple,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}