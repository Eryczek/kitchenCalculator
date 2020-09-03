import 'dart:io';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'Dish.dart';
import 'DishMenu.dart';
import 'IngredientDish.dart';
import 'Menu.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String menuTable = 'menu_table';
  String dishMenuTable = 'dish_menu_table';
  String dishTable = 'dish_table';
  String ingredientDishTable = 'ingredient_dish_table';
  String ingredientTable = 'ingredient_table';
  String colIngredientId = 'ingredientId';
  String colMenuId = 'menuId';
  String colDishId = 'dishId';
  String colId = 'id';
  String colName = 'name';
  String colRestaurant = 'restaurant';
  String colCuantity = 'cuantity';
  String colCuantityType = 'cuantityType';
  String colPrice = 'price';
  String colPortions = 'portions';
  String colWaste = 'waste';

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'kitchen_caltulator.db';
    
    var kitchenCalculatorDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return kitchenCalculatorDatabase;

  }
  
  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $menuTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colRestaurant TEXT)');

    await db.execute('CREATE TABLE $dishMenuTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colMenuId INTEGER, $colDishId INTEGER)');

    await db.execute('CREATE TABLE $dishTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colPortions DOUBLE, $colWaste DOUBLE, $colPrice DOUBLE)');

    await db.execute('CREATE TABLE $ingredientDishTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDishId INTEGER, $colIngredientId INTEGER, $colCuantity DOUBLE, $colPrice DOUBLE)');

    await db.execute('CREATE TABLE $ingredientTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colName TEXT, $colCuantity DOUBLE, $colCuantityType TEXT, $colPrice DOUBLE)');

  }

  // INGREDIENT

  Future<List<Map<String, dynamic>>> getIngredientMapList() async {
    Database db = await this.database;

    var list = await db.query(ingredientTable);
    return list;
  }
  
  Future<int> insertIngredient(Ingredient ingredient) async {
    Database db = await this.database;
    var result = await db.insert(ingredientTable, ingredient.toMap());
    return result;
  }
  
  Future<int> updateIngredient(Ingredient ingredient) async {
    var db = await this.database;
    var result = await db.update(ingredientTable, ingredient.toMap(), where: '$colId = ?', whereArgs: [ingredient.id]);
    return result;
  }

  Future<int> deleteIngredient(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $ingredientTable WHERE $colId = $id');
    return result;
  }

  Future<Ingredient> getIngredientByName(String name) async{
    var db = await this.database;
    List<Map<String, dynamic>> ingredientMap = await db.rawQuery('SELECT * FROM $ingredientTable WHERE $colName = ?', [name]);
    if(ingredientMap.length >0){
      return Ingredient.fromMapObject(ingredientMap[0]);
    } else {
      return null;
    }
  }

  Future<Ingredient> getIngredientById(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> ingredientMap = await db.rawQuery('SELECT * FROM $ingredientTable WHERE $colId = ?', [id]);
    if(ingredientMap.length >0){
      return Ingredient.fromMapObject(ingredientMap[0]);
    } else {
      return null;
    }
  }

  Future<int> getIngredientCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> number = await db.rawQuery('SELECT COUNT (*) FROM $ingredientTable');
    int result = Sqflite.firstIntValue(number);
    return result;
  }

  Future<List<Ingredient>> getIngredientList() async {
    var ingredientMapList = await getIngredientMapList();

    List<Ingredient> ingredientList = List<Ingredient>();
    for(int i = 0; i < ingredientMapList.length; i++){
      ingredientList.add(Ingredient.fromMapObject(ingredientMapList[i]));
    }

    return ingredientList;
  }

  // INGREDIENTDISH

  Future<List<Map<String, dynamic>>> getIngredientDishMapList() async {
    Database db = await this.database;

    var list = await db.query(ingredientDishTable);
    return list;
  }

  Future<int> insertIngredientDish(IngredientDish ingredientDish) async {
    Database db = await this.database;
    var result = await db.insert(ingredientDishTable, ingredientDish.toMap());
    return result;
  }

  Future<int> updateIngredientDish(IngredientDish ingredientDish) async {
    var db = await this.database;
    var result = await db.update(ingredientDishTable, ingredientDish.toMap(), where: '$colId = ?', whereArgs: [ingredientDish.id]);
    return result;
  }

  Future<List<IngredientDish>> getIngredientDishByIngredientId(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> ingredientDishMap = await db.rawQuery('SELECT * FROM $ingredientDishTable WHERE $colIngredientId = ?', [id]);
    if(ingredientDishMap.length >0){
      List<IngredientDish> ingredientDishes = List<IngredientDish>();
      for(Map<String, dynamic> map in ingredientDishMap){
        ingredientDishes.add(IngredientDish.fromMapObject(map));
      }
      return ingredientDishes;
    } else {
      return null;
    }
  }

  Future<List<IngredientDish>> getIngredientDishByDishId(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> ingredientDishMap = await db.rawQuery('SELECT * FROM $ingredientDishTable WHERE $colDishId = ?', [id]);
    if(ingredientDishMap.length >0){
      List<IngredientDish> ingredientDishes = List<IngredientDish>();
      for(Map<String, dynamic> map in ingredientDishMap){
        ingredientDishes.add(IngredientDish.fromMapObject(map));
      }
      return ingredientDishes;
    } else {
      return null;
    }
  }

  Future<IngredientDish> getIngredientDishByBothId(int ingredientId, int dishId) async{
    var db = await this.database;
    List<Map<String, dynamic>> ingredientDishMap = await db.rawQuery('SELECT * FROM $ingredientDishTable WHERE $colIngredientId = $ingredientId AND $colDishId = $dishId');
    if(ingredientDishMap.length >0){
      return IngredientDish.fromMapObject(ingredientDishMap[0]);
    } else {
      return null;
    }
  }

  Future<int> deleteIngredientDish(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $ingredientDishTable WHERE $colId = $id');
    return result;
  }

  Future<int> getIngredientDishCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> number = await db.rawQuery('SELECT COUNT (*) FROM $ingredientDishTable');
    int result = Sqflite.firstIntValue(number);
    return result;
  }

  Future<List<IngredientDish>> getIngredientDishList() async {
    var ingredientDishMapList = await getIngredientDishMapList();

    List<IngredientDish> ingredientDishList = List<IngredientDish>();
    for(int i = 0; i < ingredientDishMapList.length; i++){
      ingredientDishList.add(IngredientDish.fromMapObject(ingredientDishMapList[i]));
    }

    return ingredientDishList;
  }

  // DISH

  Future<List<Map<String, dynamic>>> getDishMapList() async {
    Database db = await this.database;

    var list = await db.query(dishTable);
    return list;
  }

  Future<int> insertDish(Dish dish) async {
    Database db = await this.database;
    var result = await db.insert(dishTable, dish.toMap());
    return result;
  }

  Future<int> updateDish(Dish dish) async {
    var db = await this.database;
    var result = await db.update(dishTable, dish.toMap(), where: '$colId = ?', whereArgs: [dish.id]);
    return result;
  }

  Future<int> deleteDish(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $dishTable WHERE $colId = $id');
    return result;
  }

  Future<Dish> getDishById(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> dishMap = await db.rawQuery('SELECT * FROM $dishTable WHERE $colId = ?', [id]);
    if(dishMap.length >0){
      return Dish.fromMapObject(dishMap[0]);
    } else {
      return null;
    }
  }

  Future<Dish> getDishByName(String name) async{
    var db = await this.database;
    List<Map<String, dynamic>> dishMap = await db.rawQuery('SELECT * FROM $dishTable WHERE $colName = ?', [name]);
    if(dishMap.length >0){
      return Dish.fromMapObject(dishMap[0]);
    } else {
      return null;
    }
  }

  Future<int> getDishCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> number = await db.rawQuery('SELECT COUNT (*) FROM $dishTable');
    int result = Sqflite.firstIntValue(number);
    return result;
  }

  Future<List<Dish>> getDishList() async {
    var dishMapList = await getDishMapList();

    List<Dish> dishList = List<Dish>();
    for(int i = 0; i < dishMapList.length; i++){
      dishList.add(Dish.fromMapObject(dishMapList[i]));
    }

    return dishList;
  }

  // DISHMENU

  Future<List<Map<String, dynamic>>> getDishMenuMapList() async {
    Database db = await this.database;

    var list = await db.query(dishMenuTable);
    return list;
  }

  Future<int> insertDishMenu(DishMenu dishMenu) async {
    Database db = await this.database;
    var result = await db.insert(dishMenuTable, dishMenu.toMap());
    return result;
  }

  Future<int> updateDishMenu(DishMenu dishMenu) async {
    var db = await this.database;
    var result = await db.update(dishMenuTable, dishMenu.toMap(), where: '$colId = ?', whereArgs: [dishMenu.id]);
    return result;
  }

  Future<int> deleteDishMenu(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $dishMenuTable WHERE $colId = $id');
    return result;
  }

  Future<List<DishMenu>> getDishMenusByMenuId(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> dishMenuMap = await db.rawQuery('SELECT * FROM $dishMenuTable WHERE $colMenuId = ?', [id]);
    if(dishMenuMap.length >0){
      List<DishMenu> dishMenus = List<DishMenu>();
      for(Map<String, dynamic> map in dishMenuMap){
        dishMenus.add(DishMenu.fromMapObject(map));
      }
      return dishMenus;
    } else {
      return null;
    }
  }

  Future<List<DishMenu>> getDishMenusByDishId(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> dishMenuMap = await db.rawQuery('SELECT * FROM $dishMenuTable WHERE $colDishId = ?', [id]);
    if(dishMenuMap.length >0){
      List<DishMenu> dishMenus = List<DishMenu>();
      for(Map<String, dynamic> map in dishMenuMap){
        dishMenus.add(DishMenu.fromMapObject(map));
      }
      return dishMenus;
    } else {
      return null;
    }
  }

  Future<DishMenu> getDishMenuByBothId(int menuId, int dishId) async{
    var db = await this.database;
    List<Map<String, dynamic>> dishMenuMap = await db.rawQuery('SELECT * FROM $dishMenuTable WHERE $colMenuId = $menuId AND $colDishId = $dishId');
    if(dishMenuMap.length >0){
      return DishMenu.fromMapObject(dishMenuMap[0]);
    } else {
      return null;
    }
  }

  Future<int> getDishMenuCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> number = await db.rawQuery('SELECT COUNT (*) FROM $dishMenuTable');
    int result = Sqflite.firstIntValue(number);
    return result;
  }

  Future<List<DishMenu>> getDishMenuList() async {
    var dishMenuMapList = await getDishMenuMapList();

    List<DishMenu> dishMenuList = List<DishMenu>();
    for(int i = 0; i < dishMenuMapList.length; i++){
      dishMenuList.add(DishMenu.fromMapObject(dishMenuMapList[i]));
    }

    return dishMenuList;
  }

  // MENU

  Future<List<Map<String, dynamic>>> getMenuMapList() async {
    Database db = await this.database;

    var list = await db.query(menuTable);
    return list;
  }

  Future<int> insertMenu(Menu menu) async {
    Database db = await this.database;
    var result = await db.insert(menuTable, menu.toMap());
    return result;
  }

  Future<int> updateMenu(Menu menu) async {
    var db = await this.database;
    var result = await db.update(menuTable, menu.toMap(), where: '$colId = ?', whereArgs: [menu.id]);
    return result;
  }

  Future<int> deleteMenu(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $menuTable WHERE $colId = $id');
    return result;
  }

  Future<Menu> getMenuByName(String name) async{
    var db = await this.database;
    List<Map<String, dynamic>> menuMap = await db.rawQuery('SELECT * FROM $menuTable WHERE $colName = ?', [name]);
    if(menuMap.length >0){
      return Menu.fromMapObject(menuMap[0]);
    } else {
      return null;
    }
  }

  Future<Menu> getMenuById(int id) async{
    var db = await this.database;
    List<Map<String, dynamic>> menuMap = await db.rawQuery('SELECT * FROM $menuTable WHERE $colId = ?', [id]);
    if(menuMap.length >0){
      return Menu.fromMapObject(menuMap[0]);
    } else {
      return null;
    }
  }

  Future<int> getMenuCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> number = await db.rawQuery('SELECT COUNT (*) FROM $menuTable');
    int result = Sqflite.firstIntValue(number);
    return result;
  }

  Future<List<Menu>> getMenuList() async {
    var menuMapList = await getMenuMapList();

    List<Menu> menuList = List<Menu>();
    for(int i = 0; i < menuMapList.length; i++){
      menuList.add(Menu.fromMapObject(menuMapList[i]));
    }

    return menuList;
  }

}