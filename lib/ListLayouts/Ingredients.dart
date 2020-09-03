 import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'DropDownAppBar.dart';
import 'ListWidget.dart';

class Ingredients extends StatefulWidget{
  @override
  State createState() => IngredientsState();
}

class IngredientsState extends State<Ingredients>{

  List<Ingredient> _ingredients;
  List<String> _sortList;
  String _itemSelected;

  bool _isSearchClicked = false;

  String _sortByNameString, _sortByPriceLowString, _sortByPriceHighString;

  DatabaseHelper _dbHelper;

  List<Ingredient> _filteredIngredients;
  List<String> _titleList = List();
  List<String> _subStringList = List();

  @override
  void initState() {
    _dbHelper = DatabaseHelper();
    updateIngredientList();
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
        title: !_isSearchClicked ? Text(AppLocalizations.of(context).translate("ingredients"),) : searchTextField(),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          !_isSearchClicked? searchButton(): closeButton(),
        ],
      ),
      floatingActionButton: addFloatingButton(context),
      body: Container(
        color: Colors.grey[300],
          child: Column(
            children: <Widget>[
              DropDownAppBar(sortList: _sortList, itemSelected: _itemSelected, setItemSelected: setItemSelected,),
              Expanded(child: ListWidget(titleList: _titleList, subsStringList: _subStringList, fileName: "Ingredient",),
              ),
            ],
          ),
      ),
    );
  }

  TextField searchTextField() {
    return TextField(
      onChanged: (value){
        _filteredIngredients = null;
        setState(() {
          _filteredIngredients = _ingredients.where((ingredient) => ingredient.name.toLowerCase().contains(value.toLowerCase())).toList();
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
          _isSearchClicked = !_isSearchClicked;
        });
      },
    );
  }

  IconButton closeButton() {
    return IconButton(icon: Icon(Icons.close, color: Colors.white),
      onPressed: (){
        setState(() {
          _isSearchClicked = !_isSearchClicked;
          _filteredIngredients = _ingredients;
          setTitleAndSubStringLists();
        });
      },
    );
  }

  FloatingActionButton addFloatingButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: Icon(Icons.add, color: Colors.white,),
      onPressed: () => Navigator.pushReplacementNamed(context, "/Create/CreateIngredient"),
    );
  }

  void setItemSelected(item){
    setState(() {
      _itemSelected = item;
    });
    setTitleAndSubStringLists();
  }

  void updateIngredientList() async{

    await _dbHelper.initializeDatabase();
    _ingredients = await _dbHelper.getIngredientList();

    setState(() {
      _itemSelected = _sortList[0];
      _filteredIngredients = _ingredients;
    });

    setTitleAndSubStringLists();
  }

  void setTitleAndSubStringLists(){

    _titleList = List();
    _subStringList = List();

    if(_ingredients != null){
      sortListBy();
    } else {
      _filteredIngredients = List();
    }

    for(Ingredient ingredient in _filteredIngredients){
      setState(() {
        _titleList.add(ingredient.name);
        _subStringList.add("£${(ingredient.price/ingredient.cuantity).toStringAsFixed(2)} ${AppLocalizations.of(context).translate("per")} ${getCuantityType(ingredient.cuantityType).toLowerCase()}");
      });
    }
  }

  String getCuantityType(String cuantityType){
    print(cuantityType);

    if(cuantityType.contains("Unites")){
      return AppLocalizations.of(context).translate("unit");
    } else if(cuantityType.contains("Litres")){
      return AppLocalizations.of(context).translate("litre");
    }

    return AppLocalizations.of(context).translate("kg");

  }

  void sortListBy(){

    if(_itemSelected == _sortByNameString) {
      _ingredients.sort((a, b) => a.name.compareTo(b.name));
    } else if(_itemSelected == _sortByPriceLowString){
      _ingredients.sort((a, b) => (a.price/a.cuantity).compareTo(b.price/b.cuantity));
    } else if(_itemSelected == _sortByPriceHighString){
      _ingredients.sort((a, b) => (b.price/b.cuantity).compareTo(a.price/a.cuantity));
    }
  }

}
