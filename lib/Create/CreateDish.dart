import 'package:firstapp/ListLayouts/Dishes.dart';
import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:firstapp/Objects/IngredientDish.dart';
import 'package:firstapp/Show/ShowDish.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../app_localizations.dart';

class CreateDish extends StatefulWidget {

  final Dish dish;

  CreateDish({this.dish});

  @override
  State createState() => CreateDishState(dish: dish);
}

class CreateDishState extends State<CreateDish>{

  Dish dish;

  CreateDishState({this.dish});

  final GlobalKey<FormState> _dishFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _ingredientFormKey = GlobalKey<FormState>();

  bool _nameAutovalidate = false, _portionsAutovalidate = false, _wasteAutovalidate = false, _cuantityAutovalidate = false, _update = false;

  var _portionsText = TextEditingController();
  var _nameText = TextEditingController();
  var _wasteText = TextEditingController();
  var _cuantityText = TextEditingController();

  final FocusNode _cuantityFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _portionsFocus = FocusNode();
  final FocusNode _wasteFocus = FocusNode();

  List<String> _ingredientNameList = List<String>(), _cuantityTypeList = List<String>();
  List<double> _cuantityList = List<double>();
  List<Ingredient> _selectedIngredients = List<Ingredient>();

  String _name = "", _oldName = "", _cuantity = "", _portions = "", _waste = "", _ingredientSelected = "", _cuantityTypeSelected ="";

  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState(){
    super.initState();
    initializeLists();
  }

  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery.of(context).size;
    Orientation screenOrientation = MediaQuery.of(context).orientation;

    return  WillPopScope(
      onWillPop: () async{
        if(_update){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowDish(dish: dish,)));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dishes()));
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: _update ? Text(AppLocalizations.of(context).translate("edit_dish")) : Text(AppLocalizations.of(context).translate("create_dish")),
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
            if(_dishFormKey.currentState.validate()){
              _dishFormKey.currentState.save();
              saveDish();
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
            dishForm(),
            SizedBox(width: 30,),
            Column(
              children: <Widget>[
                Align(
                  child: Text("${AppLocalizations.of(context).translate("add_ingredients")}:"),
                  alignment: Alignment.topCenter,
                ),
                Container(
                  width: 300,
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
                  child: ingredientsForm(),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 40,),
        Align(
          child: Text("${AppLocalizations.of(context).translate("ingredients")}:"),
          alignment: Alignment.topCenter,
        ),
        selectedIngredientsList(),
      ],
    );
  }

  Column portraitBody() {
    return Column(
      children: <Widget>[
        dishForm(),
        Align(
          child: Text("${AppLocalizations.of(context).translate("add_ingredients")}:"),
          alignment: Alignment.topCenter,
        ),
        Container(
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
          child: ingredientsForm(),
        ),
        SizedBox(
          height: 30,
        ),
        Align(
          child: Text("${AppLocalizations.of(context).translate("ingredients")}:"),
          alignment: Alignment.topCenter,
        ),
        selectedIngredientsList(),
      ],
    );
  }

  Form dishForm() {
    return Form(
      key: _dishFormKey,
      child: Column(
        children: <Widget>[
          Container(
            width: 235,
            child: nameTextField(),
          ),
          Row(children: <Widget>[
            portionTextField(),
            SizedBox(
              width: 25,
            ),
            wasteTextField(),
            Text("%", style: TextStyle(fontSize: 18),),
          ],),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }


  Form ingredientsForm() {
    return Form(
      key: _ingredientFormKey,
      child: Column(
        children: <Widget>[
          dropdownButton(),
          Row(children: <Widget>[
            cuantityTextField(),
            SizedBox(width: 5,),
            Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 40,
                  child: _cuantityTypeSelected.isEmpty ? Text("") :  Text(AppLocalizations.of(context).translate(_cuantityTypeSelected.toLowerCase()),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],),
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
       return validateName(value);
      },
      onSaved: (value){
        _name = value;
      },
      onFieldSubmitted: (term){
        _nameFocus.unfocus();
        FocusScope.of(context).requestFocus(_portionsFocus);

      },
      autovalidate: _nameAutovalidate,
      onChanged: (value){
        setState(() {
          _nameAutovalidate = true;
        });
      },

    );
  }

  String validateName(String value){
    if(value.isEmpty){
      return AppLocalizations.of(context).translate("cant_be_empty");
    }
    return null;
  }

  Container portionTextField() {
    return Container(
      width: 100,
      height: 80,
      child: TextFormField(
        controller: _portionsText,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.next,
        focusNode: _portionsFocus,
        decoration: InputDecoration(labelText: "${AppLocalizations.of(context).translate("portions")}:",),
        keyboardType: TextInputType.number,
        validator: (String value) {
          return validateNumber(value, 1);
        },
        onSaved: (String value)=> _portions = value,
        autovalidate: _portionsAutovalidate,
        onFieldSubmitted: (term){
          _portionsFocus.unfocus();
          FocusScope.of(context).requestFocus(_wasteFocus);
        },
        onChanged: (value){
          setState(() {
            _portionsAutovalidate = true;
          });
        },
      )
    );
  }

  Container wasteTextField() {
    return Container(
      width:100,
      height: 80,
      child: TextFormField(
        controller: _wasteText,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: "${AppLocalizations.of(context).translate("waste")}:",),
        keyboardType: TextInputType.number,
        focusNode: _wasteFocus,
        textAlign: TextAlign.right,
        validator: (String value) {
          return validateNumber(value, 0);
        },
        onSaved: (String value)=> _waste = value,
        autovalidate: _wasteAutovalidate,
        onFieldSubmitted: (term){
          _wasteFocus.unfocus();
        },
        onChanged: (value){
          setState(() {
            _wasteAutovalidate = true;
          });
        },
      ),
    );
  }

  String validateNumber(String value, double minimum){

    if(value.isEmpty){

      return AppLocalizations.of(context).translate("cant_be_empty");

    } else {

      double portionsValue = double.tryParse(value);

      if(portionsValue == null || portionsValue < minimum) {
        return AppLocalizations.of(context).translate("invalid_number");
      }
    }

    return null;
  }

  Container cuantityTextField() {
    return Container(
      width:100,
      child:TextFormField(
        focusNode: _cuantityFocus,
        controller: _cuantityText,
        decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("cuantity"),),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.right,
        validator: (String value) {
          return validateCuantity(value);
        },
        autovalidate: _cuantityAutovalidate,
        onChanged: (value){
          setState(() {
            _cuantityAutovalidate = true;
            _cuantityTypeSelected = getCuantityType(value);
            _cuantity = value;
          });

        },
      ),
    );
  }

  String validateCuantity(String value){

    if(value.isEmpty){

      return AppLocalizations.of(context).translate("cant_be_empty");

    } else {

      double portionsValue = double.tryParse(value);

      if(portionsValue == null || portionsValue <= 0) {
        return AppLocalizations.of(context).translate("invalid_number");
      }
    }

    return null;
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

  void onPressedAddButton(){
    setState(() {
      if(_ingredientFormKey.currentState.validate() && _ingredientNameList.isNotEmpty){

        _ingredientNameList.remove(_ingredientSelected);
        _cuantityList.add(double.parse(_cuantity));
        _dbHelper.getIngredientByName(_ingredientSelected).then((ingredient){
          _selectedIngredients.add(ingredient);
        });
        _cuantityTypeList.add(_cuantityTypeSelected);
        if(_ingredientNameList.isEmpty){
          _ingredientSelected = "";
          _cuantityTypeSelected = "";
        } else {
          _ingredientSelected = _ingredientNameList[0];
          setCuantityTypeSelected(_ingredientSelected);
        }

        _cuantityAutovalidate = false;
        _cuantityText.text = "";
        _wasteFocus.unfocus();
        _portionsFocus.unfocus();
        _nameFocus.unfocus();
        _cuantityFocus.unfocus();
      }

    });
  }

  String getCuantityType(String newItem){

    if(double.parse(newItem) == 1){
      if(_cuantityTypeSelected.contains("Unites")){
        return AppLocalizations.of(context).translate("unit");
      } else if(_cuantityTypeSelected.contains("Litres")){
        return "Litre";
      }
    } else {
      if(_cuantityTypeSelected.contains("Unit")){
        return "Unites";
      } else if(_cuantityTypeSelected.contains("Litre")){
        return "Litres";
      }
    }
    return _cuantityTypeSelected;

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
        value: _ingredientSelected,
        icon: Icon(
          Icons.arrow_drop_down,
        ),
        iconSize: 28,
        onChanged: (String newItem){
          setState(() {
            _ingredientSelected = newItem;
            setCuantityTypeSelected(newItem);
          });
        },
        style: TextStyle(
          fontSize: 16,
        ),
        items: _ingredientNameList.map((String value) {
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

  Container selectedIngredientsList() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child:ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        itemCount: _selectedIngredients.length,
        itemBuilder: (context, index){
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
                title: Text(_selectedIngredients[index].name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(Icons.delete,
                  color: Colors.deepPurple,
                ),
                contentPadding: EdgeInsets.symmetric( vertical: 0, horizontal: 6,),
                subtitle: Text("${_cuantityList[index]} ${AppLocalizations.of(context).translate(_cuantityTypeList[index].toLowerCase())} - £${((_selectedIngredients[index].price/_selectedIngredients[index].cuantity)*_cuantityList[index]).toStringAsFixed(2)}",
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

  void removeListItem(int index){
    setState(() {
      _ingredientNameList.add(_selectedIngredients[index].name);
      if(_ingredientSelected == ""){
        _ingredientSelected = _ingredientNameList[0];
        setCuantityTypeSelected(_ingredientSelected);
      }
      _selectedIngredients.removeAt(index);
      _cuantityList.removeAt(index);
      _cuantityTypeList.removeAt(index);
    });
  }

  void initializeLists() async{

    await _dbHelper.initializeDatabase();
    List<String> ingredientNameList = List();
    List<Ingredient> ingredients = await _dbHelper.getIngredientList();

    if(dish != null){

      setState(() {
        _nameText = TextEditingController(text: dish.name);
        _oldName = dish.name;
        _portionsText = TextEditingController(text: dish.portions.toString());
        _wasteText = TextEditingController(text: dish.waste.toString());
        _update = true;
      });

      if(ingredients.length > 0){

        for(Ingredient ingredient in ingredients){
          IngredientDish ingredientDish = await _dbHelper.getIngredientDishByBothId(ingredient.id, dish.id);
          if( ingredientDish == null){
            ingredientNameList.add(ingredient.name);
          } else {
            _selectedIngredients.add(ingredient);
            _cuantityList.add(ingredientDish.cuantity);
            _cuantityTypeSelected = ingredient.cuantityType;
            _cuantityTypeList.add(getCuantityType(ingredientDish.cuantity.toString()));
          }
        }
      }

    } else {

      _nameText = TextEditingController();
      _oldName = "";
      _portionsText = TextEditingController();
      _wasteText = TextEditingController();

      if(ingredients.length > 0){

        for(Ingredient ingredient in ingredients){
          ingredientNameList.add(ingredient.name);
        }
      }
    }

    if(ingredientNameList.length > 0){
      setState(() {
        _ingredientNameList = ingredientNameList;
        _ingredientSelected = ingredientNameList[0];
        _cuantityTypeSelected = ingredients[0].cuantityType;
      });

    } else {
      setState(() {
        _ingredientSelected = "";
        _cuantityTypeSelected = "";
      });
    }

  }

  void setCuantityTypeSelected(String newItem) async{
    await _dbHelper.getIngredientByName(newItem).then((ingredient){
      setState(() {
        _cuantityTypeSelected = ingredient.cuantityType;
        _cuantityTypeSelected = getCuantityType(_cuantity);
      });
    });
  }

  void saveDish() async {

    String name = "${_name.substring(0,1).toUpperCase()}${_name.substring(1).toLowerCase()}";

    if(await _dbHelper.getDishByName(name) != null && name != _oldName){
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("name_exist"),
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } else if(_selectedIngredients.length < 1) {
      Fluttertoast.showToast(
        msg:AppLocalizations.of(context).translate("at_least_one_ingredient"),
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } else {

      double price = 0;

      for(int i = 0; i < _selectedIngredients.length; i++){
        price += (_selectedIngredients[i].price / _selectedIngredients[i].cuantity) * _cuantityList[i];
      }

      if(_update){

        setState(() {
          dish.name = name;
          dish.portions = double.parse(_portions);
          dish.waste = double.parse(_waste);
          dish.price = price;
        });

        await _dbHelper.updateDish(dish);

        List<IngredientDish> ingredientDishes = await _dbHelper.getIngredientDishByDishId(dish.id);

        for(IngredientDish ingredientDish in ingredientDishes){
          await _dbHelper.deleteIngredientDish(ingredientDish.id);
        }

      } else {

        await _dbHelper.insertDish(Dish(name, double.parse(_portions), double.parse(_waste), price));
        dish = await _dbHelper.getDishByName(name);

      }

      for(int i = 0; i < _selectedIngredients.length; i++){
        await _dbHelper.insertIngredientDish(IngredientDish(_selectedIngredients[i].id, dish.id, _cuantityList[i],((_selectedIngredients[i].price / _selectedIngredients[i].cuantity) * _cuantityList[i]) ));
      }

      if(_update){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowDish(dish: dish,)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dishes()));
      }

    }

  }

}