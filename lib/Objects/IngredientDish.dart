
class IngredientDish {

  int _id;
  int _ingredientId;
  int _dishId;
  double _cuantity;
  double _price;

  IngredientDish(this._ingredientId, this._dishId, this._cuantity, this._price);

  int get id => _id;
  int get ingredientId => _ingredientId;
  int get dishId => _dishId;
  double get cuantity => _cuantity;
  double get price => _price;

  set igredientId(int newIngredientId) {
    this._ingredientId = newIngredientId;
  }

  set dishId(int newDishId) {
    this._dishId = newDishId;
  }

  set cuantity(double newCuantity){
    this._cuantity = newCuantity;
  }

  set price(double newPrice){
    this._price = newPrice;
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id != null){
      map['id'] = _id;
    }
    map['ingredientId'] = _ingredientId;
    map['dishId'] = _dishId;
    map['cuantity'] = _cuantity;
    map['price'] = _price;

    return map;

  }

  IngredientDish.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._ingredientId = map['ingredientId'];
    this._dishId = map['dishId'];
    this._cuantity = map['cuantity'];
    this._price = map['price'];
  }
}