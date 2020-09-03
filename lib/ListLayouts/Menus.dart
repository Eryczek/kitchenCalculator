import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Objects/Menu.dart';
import '../app_localizations.dart';
import 'DropDownAppBar.dart';
import 'ListWidget.dart';

class Menus extends StatefulWidget {

  @override
  State createState() => MenusState();
}

class MenusState extends State<Menus>{

  List<Menu> _menus = List();
  List<String> _sortList;
  String _itemSelected, _sortByRestaurantString, _sortByNameString;

  DatabaseHelper _dbHelper;

  bool _isSearchClicked = false;

  List<Menu> _filteredMenus = List();
  List<String> _titleList = List();
  List<String> _substringList = List();

  @override
  initState(){
    _dbHelper = DatabaseHelper();
    updateMenuList();
    super.initState();
  }

  Widget build(BuildContext context) {

    _sortByNameString = "${AppLocalizations.of(context).translate("sort_by")}: ${AppLocalizations.of(context).translate("name")}";
    _sortByRestaurantString = "${AppLocalizations.of(context).translate("sort_by")}: ${AppLocalizations.of(context).translate("restaurant")}";
    _sortList = [ _sortByNameString, _sortByRestaurantString];

    return Scaffold(
      appBar: AppBar(
        title: !_isSearchClicked ? Text(AppLocalizations.of(context).translate("menus"),) : searchTextField(),
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
            Expanded(child: ListWidget(titleList: _titleList, subsStringList: _substringList, fileName: "Menu",),
            ),
          ],
        ),
      ),
    );
  }

  TextField searchTextField() {
    return TextField(
      onChanged: (value){
        _filteredMenus = null;
        setState(() {
          _filteredMenus = _menus.where((menu) => menu.name.toLowerCase().contains(value.toLowerCase())).toList();
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
          _filteredMenus = _menus;
          setTitleAndSubStringLists();
        });
      },
    );
  }

  FloatingActionButton addFloatingButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: Icon(Icons.add, color: Colors.white,),
      onPressed: () => Navigator.pushReplacementNamed(context, "/Create/CreateMenu"),
    );
  }

  void setItemSelected(item){
    setState(() {
      _itemSelected = item;
    });
    setTitleAndSubStringLists();
  }

  void updateMenuList() async{

    await _dbHelper.initializeDatabase();
    _menus = await _dbHelper.getMenuList();

    setState(() {
      _filteredMenus = _menus;
      _itemSelected = _sortList[0];
    });

    setTitleAndSubStringLists();
  }

  void setTitleAndSubStringLists(){

    _titleList = List();
    _substringList = List();

    if(_menus != null) {
      sortListBy();

      for (Menu menu in _filteredMenus) {
        setState(() {
          _titleList.add(menu.name);
          _substringList.add(menu.restaurant);
        });
      }
    }

  }

  void sortListBy(){

    if(_itemSelected == _sortByNameString){
      _menus.sort((a, b) => a.name.compareTo(b.name));
    } else if(_itemSelected == _sortByRestaurantString){
      _menus.sort((a, b) => a.restaurant.compareTo(b.restaurant));
    }
  }

}