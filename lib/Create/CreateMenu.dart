import 'package:firstapp/ListLayouts/Menus.dart';
import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/DishMenu.dart';
import 'package:firstapp/Objects/Menu.dart';
import 'package:firstapp/Show/ShowMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../app_localizations.dart';

class CreateMenu extends StatefulWidget {

  final Menu menu;

  CreateMenu({this.menu});

  @override
  State createState() => CreateMenuState(menu: menu);
}

class CreateMenuState extends State<CreateMenu> {

  Menu menu;

  CreateMenuState({this.menu});

  final GlobalKey<FormState> _menuFormKey = GlobalKey<FormState>();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _restaurantFocus = FocusNode();

  bool _nameAutovalidate = false,
      _restaurantAutovalidate = false,
      _update = false;

  var _restaurantText = TextEditingController();
  var _nameText = TextEditingController();

  List<String> _dishNameList = List<String>();
  List<Dish> _selectedDishes = List<Dish>();

  String _name = "",
      _restaurant = "",
      _dishSelected = "",
      _oldName = "";

  @override
  void initState() {
    super.initState();
    initializeLists();
  }

  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery
        .of(context)
        .size;
    Orientation screenOrientation = MediaQuery
        .of(context)
        .orientation;

    return WillPopScope(
      onWillPop: () async{

        if(_update){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowMenu(menu: menu,)));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menus()));
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: _update ? Text(AppLocalizations.of(context).translate("edit_menu"),) : Text(AppLocalizations.of(context).translate("create_menu"),),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            saveButton(),
          ],
        ),
        body: body(screenOrientation, screenSize),
      ),
    );
  }

  IconButton saveButton() {
    return IconButton(
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
      onPressed: () {
        if (_menuFormKey.currentState.validate()) {
          _menuFormKey.currentState.save();
          saveMenu();
        }
      },
    );
  }

  SingleChildScrollView body(Orientation screenOrientation, Size screenSize) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40,),
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: screenOrientation == Orientation.portrait ? portraitBody() : landscapeBody(),
            ),
          ],
        ),
      ),
    );
  }

  Column landscapeBody() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 235,
              child: menuForm(),
            ),
            SizedBox(width: 30,),
            Column(
              children: <Widget>[
                Align(
                  child: Text("${AppLocalizations.of(context).translate("add_dishes")}:"),
                  alignment: Alignment.topCenter,
                ),
                Container(
                  width: 300,
                  child: dishForm(),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 40,),
        Align(
          child: Text("${AppLocalizations.of(context).translate("dishes")}:"),
          alignment: Alignment.topCenter,
        ),
        selectedDishesList(),
      ],
    );
  }

  Column portraitBody() {
    return Column(
      children: <Widget>[
        menuForm(),
        SizedBox(
          height: 30,
        ),
        Align(
          child: Text("${AppLocalizations.of(context).translate("add_dishes")}:",),
          alignment: Alignment.topCenter,
        ),
        dishForm(),
        SizedBox(
          height: 30,
        ),
        Align(
          child: Text("${AppLocalizations.of(context).translate("dishes")}:"),
          alignment: Alignment.topCenter,
        ),
        selectedDishesList(),
      ],
    );
  }

  Form menuForm() {
    return Form(
      key: _menuFormKey,
      child: Column(
        children: <Widget>[
          nameTextField(),
          restaurantTextField(),
        ],
      ),
    );
  }

  Container dishForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.deepPurple,
          width: 2,
        ),
      ),
      child: Column(
        children: <Widget>[
          dropdownButton(),
          SizedBox(
            height: 20,
          ),
          addButton(),
        ],),
    );
  }

  TextFormField nameTextField() {
    return TextFormField(
      controller: _nameText,
      textInputAction: TextInputAction.next,
      focusNode: _nameFocus,
      maxLength: 22,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("name"),),
      validator: (String value) {
        return validateText(value);
      },
      onSaved: (value) {
        _name = value;
      },
      autovalidate: _nameAutovalidate,
      onChanged: (value) {
        setState(() {
          _nameAutovalidate = true;
        });
      },
      onFieldSubmitted: (term){
        FocusScope.of(context).requestFocus(_restaurantFocus);
        _nameFocus.unfocus();
      },

    );
  }

  String validateText(String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context).translate("cant_be_empty");
    }
    return null;
  }

  TextFormField restaurantTextField() {
    return TextFormField(
      controller: _restaurantText,
      textInputAction: TextInputAction.done,
      focusNode: _restaurantFocus,
      maxLength: 22,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("restaurant"),),
      validator: (String value) {
        return validateText(value);
      },
      onSaved: (value) {
        _restaurant = value;
      },
      autovalidate: _restaurantAutovalidate,
      onChanged: (value) {
        setState(() {
          _restaurantAutovalidate = true;
        });
      },
      onFieldSubmitted: (term){
        _restaurantFocus.unfocus();
      },

    );
  }

  Container addButton() {
    return Container(
      width: 90,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textColor: Colors.white,
        color: Colors.deepPurple,
        child: Text(AppLocalizations.of(context).translate("add"),
          style: TextStyle(
              fontSize: 16
          ),
        ),
        onPressed: () => onPressedAddButton(),
      ),
    );
  }

  void onPressedAddButton() {
    setState(() {
      _nameFocus.unfocus();
      _restaurantFocus.unfocus();
      if (_dishNameList.isNotEmpty) {
        _dishNameList.remove(_dishSelected);
        _dbHelper.getDishByName(_dishSelected).then((dish) {
          _selectedDishes.add(dish);
        });
        if (_dishNameList.isEmpty) {
          _dishSelected = "";
        } else {
          _dishSelected = _dishNameList[0];
        }
      }
    });
  }

  Container dropdownButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton(
        isExpanded: true,
        value: _dishSelected,
        icon: Icon(
          Icons.arrow_drop_down,
        ),
        iconSize: 28,
        onChanged: (String newItem) {
          setState(() {
            _dishSelected = newItem;
          });
        },
        style: TextStyle(
          fontSize: 16,
        ),
        items: _dishNameList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Container selectedDishesList() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        itemCount: _selectedDishes.length,
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
                onTap: () => removeListItem(index),
                title: Text(_selectedDishes[index].name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(Icons.delete,
                  color: Colors.deepPurple,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0, horizontal: 6,),
                subtitle: Text("£${((_selectedDishes[index].price - ((_selectedDishes[index].price * _selectedDishes[index].waste)/100))/_selectedDishes[index].portions).toStringAsFixed(2)} ${AppLocalizations.of(context).translate("per_portion")}.",
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void removeListItem(int index) {
    setState(() {
      _dishNameList.add(_selectedDishes[index].name);
      if (_dishSelected == "") {
        _dishSelected = _dishNameList[0];
      }
      _selectedDishes.removeAt(index);

    });
  }

  void initializeLists() async {
    await _dbHelper.initializeDatabase();
    List<String> dishNameList = List();
    List<Dish> dishes = await _dbHelper.getDishList();

    if(menu != null){
      setState(() {
        _nameText = TextEditingController(text: menu.name);
        _oldName = menu.name;
        _restaurantText = TextEditingController(text: menu.restaurant);
        _update = true;
      });

      if(dishes.length > 0){

        for(Dish dish in dishes){
          DishMenu dishMenu = await _dbHelper.getDishMenuByBothId(menu.id, dish.id);
          if(dishMenu == null){
            dishNameList.add(dish.name);
          } else {
            _selectedDishes.add(dish);
          }
        }
      }

    } else {

      _nameText = TextEditingController();
      _restaurantText = TextEditingController();
      _oldName = "";

      if (dishes.length > 0) {
        for (Dish dish in dishes) {
          dishNameList.add(dish.name);
        }
      }
    }

    if(dishNameList.length > 0) {
      setState(() {
        _dishNameList = dishNameList;
        _dishSelected = dishNameList[0];
      });
    } else {
      setState(() {
        _dishSelected = "";
      });
    }

  }

  void saveMenu() async {

    String name = "${_name.substring(0, 1).toUpperCase()}${_name.substring(1).toLowerCase()}";
    String restaurant = "${_restaurant.substring(0, 1).toUpperCase()}${_restaurant.substring(1).toLowerCase()}";

    if (await _dbHelper.getMenuByName(name) != null && name != _oldName) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("name_exist"),
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (_selectedDishes.length < 1) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("at_least_one_dish"),
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } else {

      if(_update){

        setState(() {
          menu.name = name;
          menu.restaurant = restaurant;
        });

        await _dbHelper.updateMenu(menu);

        List<DishMenu> dishMenuList = await _dbHelper.getDishMenusByMenuId(menu.id);

        for(DishMenu dishMenu in dishMenuList){
          await _dbHelper.deleteDishMenu(dishMenu.id);
        }

      } else {

        await _dbHelper.insertMenu(Menu(name, restaurant));
        menu = await _dbHelper.getMenuByName(name);

      }

      for (Dish dish in _selectedDishes) {
        await _dbHelper.insertDishMenu(DishMenu(menu.id, dish.id));
      }

      if(_update){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowMenu(menu: menu,)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menus()));
      }

    }
  }
}