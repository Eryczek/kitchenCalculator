import 'package:firstapp/Create/CreateIngredient.dart';
import 'package:firstapp/ListLayouts/Dishes.dart';
import 'package:firstapp/Objects/DishMenu.dart';
import 'package:firstapp/Show/Conformation.dart';
import 'package:firstapp/Create/CreateDish.dart';
import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:firstapp/Objects/IngredientDish.dart';
import 'package:firstapp/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ShowDish extends StatefulWidget {

  final Dish dish;

  ShowDish({this.dish});

  @override
  State createState() => ShowDishState(dish: dish);
}

class ShowDishState extends State<ShowDish>{

  Dish dish;

  ShowDishState({this.dish});

  Size _size;
  Orientation _orientation;

  List<Ingredient> _ingredients = List();
  List<IngredientDish> _ingredientDishes = List();
  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState(){
    super.initState();
    initializeLists();
  }

  @override
  Widget build(BuildContext context) {

    _size = MediaQuery.of(context).size;
    _orientation = MediaQuery.of(context).orientation;

    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dishes()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("dish")),
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

  IconButton editIconButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: Colors.white,
      ),
      onPressed: (){
        setState(() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateDish(dish: dish,)));
        });
      },
    );
  }

  IconButton deleteIconButton() {
    return IconButton(
      icon: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () {
        deleteDish();
      },
    );
  }

  void deleteDish() async{

    Confirmation confirmation = await showAlertDialog(context);

    if(confirmation == Confirmation.Yes){
      Navigator.pop(context);
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
      onPressed:  () async{
        _dbHelper.deleteDish(dish.id);
        List<IngredientDish> ingredientDishList = await _dbHelper.getIngredientDishByDishId(dish.id);
        for(IngredientDish ingredientDish in ingredientDishList){
          _dbHelper.deleteIngredientDish(ingredientDish.id);
        }
        List<DishMenu> dishMenuList = await _dbHelper.getDishMenusByDishId(dish.id);
        for(DishMenu dishMenu in dishMenuList){
          _dbHelper.deleteDishMenu(dishMenu.id);
        }
        Navigator.pop(context, Confirmation.Yes);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).translate("delete")),
      content: Text("${AppLocalizations.of(context).translate("want_to_delete")} ${dish.name}?"),
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
      child: _orientation == Orientation.portrait ? portraitBody() : landscapeBody(),
    );
  }

  Column portraitBody() {
    return Column(
      children: <Widget>[
        Container(
          height: _size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child:dishInformation(),
        ),
        SizedBox(
          height: 30,
        ),
        addAsAIngredientButton(),
        SizedBox(
          height: 30,
        ),
        Align(
          child: Text(AppLocalizations.of(context).translate("ingredients")),
          alignment: Alignment.topCenter,
        ),
        Container(
          height: _size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ingredientList(),
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
              width: _size.width * 0.4,
              height: _size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child:dishInformation(),
            ),
            SizedBox(
              width: 40,
            ),
            Column(
              children: <Widget>[
                addAsAIngredientButton(),
                SizedBox(
                  height: 20,
                ),
                Align(
                  child: Text(AppLocalizations.of(context).translate("ingredients")),
                  alignment: Alignment.topCenter,
                ),
                Container(
                  width: _size.width * 0.4,
                  height: _size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ingredientList(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Column dishInformation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        textRow("${AppLocalizations.of(context).translate("name")}:", dish.name),
        textRow("${AppLocalizations.of(context).translate("portions")}:", "${dish.portions.toStringAsFixed(2)}"),
        textRow("${AppLocalizations.of(context).translate("waste")}:", "${dish.waste.toStringAsFixed(2)}%"),
        textRow("${AppLocalizations.of(context).translate("total_price")}:", "£${dish.price.toStringAsFixed(2)}"),
        textRow("${AppLocalizations.of(context).translate("price")} ${AppLocalizations.of(context).translate("per_portion")}:", "£${((dish.price - ((dish.price * dish.waste)/100))/dish.portions).toStringAsFixed(2)}"),
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

  RaisedButton addAsAIngredientButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
      ),
      textColor: Colors.white,
      color: Colors.deepPurple,
      child: Text(AppLocalizations.of(context).translate("add_as_ingredient"),
        style: TextStyle(
            fontSize: 20
        ),
      ),
      onPressed: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateIngredient(ingredient: Ingredient(dish.name, 0, AppLocalizations.of(context).translate("kg"), dish.price),)));
      },
    );
  }

  ListView ingredientList() {

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      itemCount: _ingredients.length,
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
              title: Text(_ingredients[index].name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text("${_ingredientDishes[index].cuantity} ${getCuantityType(_ingredients[index].cuantityType, _ingredientDishes[index].cuantity)} - £${((_ingredients[index].price/_ingredients[index].cuantity) * _ingredientDishes[index].cuantity).toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
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

  String getCuantityType(String cuantityType, double cuantity){

    if(cuantity == 1 && cuantityType.contains("Unites")){
      return AppLocalizations.of(context).translate("unit");
    } else if(cuantity == 1 && cuantityType.contains("Litres")){
      return AppLocalizations.of(context).translate("litre");
    }

    return AppLocalizations.of(context).translate(cuantityType.toLowerCase());

  }

  void initializeLists() {

      final Future<Database> dbFuture = _dbHelper.initializeDatabase();
      dbFuture.then((database) {

        Future<List<IngredientDish>> ingredientDishListFuture = _dbHelper.getIngredientDishByDishId(dish.id);
        ingredientDishListFuture.then((ingredientDishList) {

          if(ingredientDishList != null){

            for(IngredientDish ingredientDish in ingredientDishList){

              Future<Ingredient> ingredientDishListFuture = _dbHelper.getIngredientById(ingredientDish.ingredientId);
              ingredientDishListFuture.then((ingredient) {
                setState(() {
                  _ingredients.add(ingredient);
                  _ingredientDishes.add(ingredientDish);
                });
              });
            }
          }
        });
      });
  }

}