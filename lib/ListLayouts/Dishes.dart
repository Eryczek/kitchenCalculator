import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'DropDownAppBar.dart';
import 'ListWidget.dart';

class Dishes extends StatefulWidget {

  @override
  State createState() => DishesState();
}

class DishesState extends State<Dishes>{

  List<Dish> dishes;
  List<String> _sortList;
  String itemSelected;

  DatabaseHelper dbHelper;
  
  String _sortByNameString, _sortByPriceLowString, _sortByPriceHighString;

  bool isSearchClicked = false;

  List<Dish> filteredDishes = List();
  List<String> titleList = List();
  List<String> subStringList = List();

  @override
  void initState() {
    dbHelper = DatabaseHelper();
    updateDishList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _sortByNameString = "${AppLocalizations.of(context).translate("sort_by")}: ${AppLocalizations.of(context).translate("name")}";
    _sortByPriceLowString = "${AppLocalizations.of(context).translate("sort_by")}: ${AppLocalizations.of(context).translate("price_low")}";
    _sortByPriceHighString = "${AppLocalizations.of(context).translate("sort_by")}: ${AppLocalizations.of(context).translate("price_high")}";
    _sortList = [ _sortByNameString, _sortByPriceLowString, _sortByPriceHighString];

    return Scaffold(
      appBar: AppBar(
        title: !isSearchClicked ? Text(AppLocalizations.of(context).translate("dishes"),): searchTextField(),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          !isSearchClicked? searchButton(): closeButton(),
        ],
      ),
      floatingActionButton: addFloatingButton(context),
      body: Container(
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            DropDownAppBar(sortList: _sortList, itemSelected: itemSelected, setItemSelected: setItemSelected,),
            Expanded(child: ListWidget(titleList: titleList, subsStringList: subStringList, fileName: "Dish",),
          ),
        ],
      ),
      ),
    );
  }

  TextField searchTextField() {
    return TextField(
      onChanged: (value){
        filteredDishes = null;
        setState(() {
          filteredDishes = dishes.where((dish) => dish.name.toLowerCase().contains(value.toLowerCase())).toList();
        });
        setTitleAndSubStringLists();
      },
      autofocus: true,
      style: TextStyle(color: Colors.white,),
      decoration: InputDecoration(
        icon: Icon(Icons.search, color: Colors.white,),
        hintText: AppLocalizations.of(context).translate("search"),
        hintStyle: TextStyle(color: Colors.white,),
      ),
    );
  }

  IconButton searchButton() {
    return IconButton(icon: Icon(Icons.search, color: Colors.white,),
      onPressed: (){
        setState(() {
          isSearchClicked = !isSearchClicked;
        });
      },
    );
  }

  IconButton closeButton() {
    return IconButton(icon: Icon(Icons.close, color: Colors.white),
      onPressed: (){
        setState(() {
          isSearchClicked = !isSearchClicked;
          filteredDishes = dishes;
          setTitleAndSubStringLists();
        });
      },
    );
  }

  FloatingActionButton addFloatingButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: Icon(Icons.add, color: Colors.white,),
      onPressed: () => Navigator.pushReplacementNamed(context, "/Create/CreateDish"),
    );
  }

  void setItemSelected(item){
    setState(() {
      itemSelected = item;
    });
    setTitleAndSubStringLists();
  }

  void updateDishList() async{

    await dbHelper.initializeDatabase();
    dishes = await dbHelper.getDishList();

    setState(() {
      filteredDishes = dishes;
      itemSelected = _sortList[0];
    });

    setTitleAndSubStringLists();
  }

  void setTitleAndSubStringLists(){

    titleList = List();
    subStringList = List();

    if(dishes != null){
      sortListBy();

      for(Dish dish in filteredDishes){
        setState(() {
          titleList.add(dish.name);
          subStringList.add("£${((dish.price - ((dish.price * dish.waste)/100))/dish.portions).toStringAsFixed(2)} ${AppLocalizations.of(context).translate("per_portion")}.");
        });
      }
    }
  }

  void sortListBy(){

    if(itemSelected == _sortByNameString){
      dishes.sort((a, b) => a.name.compareTo(b.name));
    } else if(itemSelected == _sortByPriceLowString){
      dishes.sort((a, b) => a.price.compareTo(b.price));
    } else if(itemSelected == _sortByPriceHighString){
      dishes.sort((a, b) => b.price.compareTo(a.price));
    }

  }

}