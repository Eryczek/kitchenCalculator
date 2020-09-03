import 'package:firstapp/ListLayouts/Ingredients.dart';
import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:firstapp/Objects/IngredientDish.dart';
import 'package:firstapp/Show/ShowDish.dart';
import 'package:firstapp/Show/ShowIngredient.dart';
import 'package:firstapp/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateIngredient extends StatefulWidget {

  final Ingredient ingredient;

  CreateIngredient({this.ingredient});

  @override
  State createState() => CreateIngredientState(ingredient: ingredient);
}

class CreateIngredientState extends State<CreateIngredient>{

  Ingredient ingredient;

  CreateIngredientState({this.ingredient});

  bool _initCuantityType = false;

  final GlobalKey<FormState> _ingredientFormKey = GlobalKey<FormState>();

  List<String> _cuantityTypeList = List();

  String _oldName = "", _name = "", _cuantity = "", _cuantityType = "Kg", _price = "";
  bool _nameAutovalidate = false, _cuantityAutovalidate = false, _priceAutovalidate = false, _update = false, _addAsIngredient = false;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _cuantityFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _cuantityTypeFocus = FocusNode();

  TextEditingController _nameText;
  TextEditingController _cuantityText;
  TextEditingController _priceText;

  double  _oldCuantity, _oldPrice;

  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState(){
    initialize();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    
    Size screenSize = MediaQuery.of(context).size;
    Orientation screenOrientation = MediaQuery.of(context).orientation;

    if(!_initCuantityType){
      setState(() {
        _cuantityTypeList = [AppLocalizations.of(context).translate("kg"),
          AppLocalizations.of(context).translate("unites"),
          AppLocalizations.of(context).translate("litres")];
      });

      if(ingredient != null){
        _cuantityType = AppLocalizations.of(context).translate(ingredient.cuantityType.toLowerCase());
      }

      _initCuantityType = true;

    }

    return  WillPopScope(
      onWillPop: () async{

        if(_update){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowIngredient(ingredient: ingredient,)));
        } else if(_addAsIngredient){
          Dish dish = await _dbHelper.getDishByName(ingredient.name);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowDish(dish: dish,)));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Ingredients()));
        }

        return false;

      },
      child: Scaffold(
        appBar: AppBar(
          title: _update ? Text(AppLocalizations.of(context).translate("edit_ingredient")) : Text(AppLocalizations.of(context).translate("create_ingredient")),
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
          onPressed: (){
            if(_ingredientFormKey.currentState.validate()){
              _ingredientFormKey.currentState.save();
              saveIngredient();
            }
          },
        );
  }

  SingleChildScrollView body(Orientation screenOrientation, Size screenSize) {
    return SingleChildScrollView(
      child: Container(
        height: screenOrientation == Orientation.portrait? screenSize.height * 0.885: screenSize.height * 1.65,
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40,),
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(40),
              child:Form(
                key: _ingredientFormKey,
                child: screenOrientation == Orientation.portrait ? portraitBody(): landscapeBody(),
              ),
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
              width: 220,
              child: nameTextField(),
            ),
            SizedBox(
              width: 100,
            ),
            cuantityTextField(),
            SizedBox(
              width: 30,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: cuantityTypeDropDown(),
            ),
          ],
        ),

        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: priceTextField(),
        ),
      ],
    );
  }

  Column portraitBody() {
    return Column(
      children: <Widget>[
        nameTextField(),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: cuantityTextField(),
            ),
            SizedBox(
              width: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: cuantityTypeDropDown(),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: priceTextField(),
        ),
      ],
    );
  }


  TextFormField nameTextField() {
    return TextFormField(
      controller: _nameText,
      textInputAction: TextInputAction.next,
      focusNode: _nameFocus,
      maxLength: 22,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("name"),),
      validator: (String value){
        return validateText(value);
      },
      onSaved: (value) {
        _name = value;
      },
      autovalidate: _nameAutovalidate,
      onChanged: (value){
        setState(() {
          _nameAutovalidate = true;
        });
      },
      onFieldSubmitted: (term){
        FocusScope.of(context).requestFocus(_cuantityFocus);
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

  Container cuantityTextField() {
    return Container(
      width: 80,
      height: 80,
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: _cuantityText,
        textInputAction: TextInputAction.next,
        focusNode: _cuantityFocus,
        decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("cuantity")),
        textAlign: TextAlign.right,
        validator: (value){
          return validateNumber(value);
        },
        onSaved: (String value){
          _cuantity = value;
        },
        autovalidate: _cuantityAutovalidate,
        onChanged: (input)  {
          setState(() {
            _cuantityAutovalidate = true;
          });
        } ,
        onFieldSubmitted: (term){
          FocusScope.of(context).requestFocus(_cuantityTypeFocus);
          _cuantityFocus.unfocus();
        },
      ),
    );
  }

  Container cuantityTypeDropDown() {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton(
        focusNode: _cuantityTypeFocus,
        isExpanded: true,
        value: _cuantityType,
        icon: Icon(
          Icons.arrow_drop_down,
        ),
        iconSize: 28,
        onChanged: (String newItem){
          setState(() {
            FocusScope.of(context).requestFocus(_priceFocus);
            _cuantityType = newItem;
          });
        },
        style: TextStyle(
          fontSize: 16,
        ),
        items: _cuantityTypeList.map((String value){
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

  Container priceTextField() {
    return Container(
      width: 80,
      height: 80,
      child: TextFormField(
        controller: _priceText,
        textInputAction: TextInputAction.done,
        focusNode: _priceFocus,
        decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("price"),),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.right,
        validator: (String value){
          return validateNumber(value);
        },
        onSaved: (String value){
          _price = value;
        },
        autovalidate: _priceAutovalidate,
        onChanged: (String newItem){
          setState(() {
            _priceAutovalidate = true;
          });
        },
        onFieldSubmitted: (term){
          _priceFocus.unfocus();
        },
      ),
    );
  }

  String validateNumber(String value){

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

  void initialize(){

    if(ingredient != null){
      setState(() {
        _nameText = TextEditingController(text: ingredient.name);
        _oldCuantity = ingredient.cuantity;
        _cuantityText = TextEditingController(text: ingredient.cuantity.toString());
        _oldPrice = ingredient.price;
        _priceText = TextEditingController(text: ingredient.price.toString());
        if(ingredient.cuantity == 0){
          _addAsIngredient = true;
        } else {
          _oldName = ingredient.name;
          _update = true;
        }
      });
    } else {
      setState(() {
      //  _cuantityType =  "Kg"; //AppLocalizations.of(context).translate("kg");
      });
      _nameText = TextEditingController();
      _cuantityText = TextEditingController();
      _priceText = TextEditingController();
    }
  }
  
  void saveIngredient() async {

    String name ="${_name.substring(0,1).toUpperCase()}${_name.substring(1).toLowerCase()}";

    Ingredient checkIngredient = await _dbHelper.getIngredientByName(name);

    if(checkIngredient != null && checkIngredient.name != _oldName){
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("name_exist"),
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } else {

      setCuantityType();

      if(_update){

        setState(() {
          ingredient.name = name;
          ingredient.cuantity = double.parse(_cuantity);
          ingredient.cuantityType = _cuantityType;
          ingredient.price = double.parse(_price);
        });

        await _dbHelper.updateIngredient(ingredient);

        List<IngredientDish> ingredientDishList = await _dbHelper.getIngredientDishByIngredientId(ingredient.id);

        if(ingredientDishList != null){

          for(IngredientDish ingredientDish in ingredientDishList){
            Dish dish = await _dbHelper.getDishById(ingredientDish.dishId);
            dish.price += (ingredient.price / ingredient.cuantity) - (_oldPrice / _oldCuantity);
            await _dbHelper.updateDish(dish);
          }

        }

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowIngredient(ingredient: ingredient,)));

      } else {

        await _dbHelper.insertIngredient(Ingredient(name, double.parse(_cuantity), _cuantityType, double.parse(_price)));

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Ingredients()));

      }

    }

  }

  void setCuantityType() {

    if(_cuantityType == "Unidades"){
      setState(() {
        _cuantityType = "Unites";
      });
    } else if(_cuantityType == "Litros"){
      _cuantityType = "Litres";
    }

  }

}