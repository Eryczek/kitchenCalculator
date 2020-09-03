import 'package:firstapp/ListLayouts/Ingredients.dart';
import 'package:firstapp/Show/Conformation.dart';
import 'package:firstapp/Create/CreateIngredient.dart';
import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:firstapp/Objects/IngredientDish.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

import '../app_localizations.dart';

class ShowIngredient extends StatefulWidget {

  final Ingredient ingredient;

  ShowIngredient({this.ingredient});

  @override
  State createState() => ShowIngredientState(ingredient: ingredient);

}

class ShowIngredientState extends State<ShowIngredient>{

  Ingredient ingredient;

  ShowIngredientState({this.ingredient});

  Size size;
  Orientation orientation;

  List<Dish> _dishes = List();

  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState(){
    super.initState();
    initializeLists();
  }

  @override
  Widget build(BuildContext context) {

    orientation = MediaQuery.of(context).orientation;
    size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Ingredients()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("ingredient")),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            deleteIconButton(),
            editIconButton(context),
          ],
        ),
        body: SingleChildScrollView(
          child: body(),
        ),
      ),
    );
  }

  IconButton deleteIconButton() {
    return IconButton(
      icon: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () {
        deleteIngredient();
      },
    );
  }

  IconButton editIconButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: Colors.white,
      ),
      onPressed: (){
        setState(() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateIngredient(ingredient: ingredient,)));
        });
      },
    );
  }

  void deleteIngredient() async{

    if(_dishes.length == 0) {
      Confirmation confirmation = await showAlertDialog(context);
      if(confirmation == Confirmation.Yes){
        Navigator.pop(context);
      }
    } else {
      String dishText = _dishes.length == 1? AppLocalizations.of(context).translate("dish").toLowerCase(): AppLocalizations.of(context).translate("dishes").toLowerCase();
      Fluttertoast.showToast(
        msg: "${ingredient.name} ${AppLocalizations.of(context).translate("cant_be_deleted")} ${_dishes.length} $dishText",
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    }

  }

  Future<Confirmation> showAlertDialog(BuildContext context) async {

    Widget cancelButton = FlatButton(
      child: Text(AppLocalizations.of(context).translate("cancel")),
      onPressed:  () {
        Navigator.pop(context, Confirmation.Cancel);
      },
    );

    Widget yesButton = FlatButton(
      child: Text(AppLocalizations.of(context).translate("yes")),
      onPressed:  () {
        dbHelper.deleteIngredient(ingredient.id);
        Navigator.pop(context, Confirmation.Yes);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).translate("delete")),
      content: Text("${AppLocalizations.of(context).translate("want_to_delete")} ${ingredient.name}?"),
      actions: [
        cancelButton,
        yesButton,
      ],
    );

    return showDialog<Confirmation>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Container body() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40,),
        color: Colors.grey[300],
        child: orientation == Orientation.portrait ? portraitBody() : landscapeBody(),
      );
  }

  Column portraitBody() {
    return Column(
      children: <Widget>[
        Container(
          height: size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child:ingredientInformation(),
        ),
        SizedBox(
          height: 40,
        ),
        Align(
          child: Text("${AppLocalizations.of(context).translate("dishes")}:"),
          alignment: Alignment.topCenter,
        ),
        Container(
          height: size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: dishesList(),
        ),
      ],
    );
  }

  Column landscapeBody() {
    return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: size.width * 0.4,
                height: size.width * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child:ingredientInformation(),
              ),
              SizedBox(
                width: 40,
              ),
              Column(
                children: <Widget>[
                  Align(
                    child: Text("${AppLocalizations.of(context).translate("dishes")}:"),
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: dishesList(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
  }
  
  Column ingredientInformation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        textRow("${AppLocalizations.of(context).translate("name")}:", ingredient.name),
        textRow("${AppLocalizations.of(context).translate("cuantity")}:", "${ingredient.cuantity.toStringAsFixed(2)} ${getCuantityType(ingredient.cuantity)}"),
        textRow("${AppLocalizations.of(context).translate("total_price")}:", "£${ingredient.price.toStringAsFixed(2)}"),
        textRow("${AppLocalizations.of(context).translate("price")} ${AppLocalizations.of(context).translate("per")} ${getCuantityType(1)}:", "£${(ingredient.price / ingredient.cuantity).toStringAsFixed(2)}"),
      ],
    );
  }
  
  Row textRow(String title, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(text,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String getCuantityType(double cuantity){

    if(cuantity == 1){
      if(ingredient.cuantityType.contains("Unites")){
        return AppLocalizations.of(context).translate("unit");
      } else if(ingredient.cuantityType.contains("Litres")){
        return AppLocalizations.of(context).translate("litre");
      }
    }
    return AppLocalizations.of(context).translate(ingredient.cuantityType.toLowerCase());
  }

  ListView dishesList() {

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      itemCount: _dishes.length,
      itemBuilder: (context, index) {

        return Card(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.deepPurple,
                width: 3,
              ),
            ),
            child: ListTile(
              title: Text(_dishes[index].name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0, horizontal: 20,),
            ),
          ),
        );
      },
    );
  }

  void initializeLists() {

    final Future<Database> dbFuture = dbHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<IngredientDish>> ingredientDishListFuture = dbHelper.getIngredientDishByIngredientId(ingredient.id);
      ingredientDishListFuture.then((ingredientDishList) {

        if(ingredientDishList != null){

          for(IngredientDish ingredientDish in ingredientDishList){

            Future<Dish> ingredientDishListFuture = dbHelper.getDishById(ingredientDish.dishId);
            ingredientDishListFuture.then((dish) {

              setState(() {
                _dishes.add(dish);
              });

            });
          }
        }
      });
    });
  }
}