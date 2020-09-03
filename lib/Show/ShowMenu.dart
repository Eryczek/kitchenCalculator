import 'package:firstapp/ListLayouts/Menus.dart';
import 'package:firstapp/Show/Conformation.dart';
import 'package:firstapp/Create/CreateMenu.dart';
import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/DishMenu.dart';
import 'package:firstapp/Objects/Menu.dart';
import 'package:flutter/material.dart';

import '../app_localizations.dart';



class ShowMenu extends StatefulWidget {

  final Menu menu;

  ShowMenu({this.menu});

  @override
  State createState() => ShowMenuState(menu: menu);
}

class ShowMenuState extends State<ShowMenu>{

  Menu menu;

  ShowMenuState({this.menu});

  Size _size;
  Orientation _orientation;

  List<Dish> _dishes;
  List<DishMenu> _dishMenus;
  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    initializeLists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _size = MediaQuery.of(context).size;
    _orientation = MediaQuery.of(context).orientation;

    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menus()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("menu")),
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateMenu(menu: menu,)));
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menus()));
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
        _dbHelper.deleteMenu(menu.id);
        List<DishMenu> dishMenuList = await _dbHelper.getDishMenusByMenuId(menu.id);
        for(DishMenu dishMenu in dishMenuList){
          _dbHelper.deleteDishMenu(dishMenu.id);
        }
        Navigator.pop(context, Confirmation.Yes);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).translate("delete")),
      content: Text("${AppLocalizations.of(context).translate("want_to_delete")} ${menu.name}?"),
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
          height: _size.height * 0.2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child:dishInformation(),
        ),
        SizedBox(
          height: 40,
        ),
        Align(
          child: Text(AppLocalizations.of(context).translate("dishes")),
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
              height: _size.width * 0.2,
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
                Align(
                  child: Text(AppLocalizations.of(context).translate("dishes")),
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
        textRow("${AppLocalizations.of(context).translate("name")}:", menu.name),
        textRow("${AppLocalizations.of(context).translate("restaurant")}:", menu.restaurant),
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

  ListView ingredientList() {

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
              subtitle: Text("${AppLocalizations.of(context).translate("price")} ${AppLocalizations.of(context).translate("per_portion")}: £${((_dishes[index].price - ((_dishes[index].price * _dishes[index].waste)/100))/_dishes[index].portions).toStringAsFixed(2)}",
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


  void initializeLists() async {
    _dishMenus = List();
    _dishes = List();

    await _dbHelper.initializeDatabase();
    List<DishMenu> dishMenuList = await _dbHelper.getDishMenusByMenuId(menu.id);

    if (dishMenuList != null) {
      for (DishMenu dishMenu in dishMenuList) {
        Dish dish = await _dbHelper.getDishById(dishMenu.dishId);
        setState(() {
          _dishes.add(dish);
          _dishMenus.add(dishMenu);
        });
      }
    }
  }

}