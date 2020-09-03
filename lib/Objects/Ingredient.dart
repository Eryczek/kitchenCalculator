
class Ingredient {

  int _id;
  String _name;
  double _cuantity;
  String _cuantityType;
  double _price;

  Ingredient(this._name, this._cuantity, this._cuantityType, this._price);

  int get id => _id;
  String get name => _name;
  double get cuantity => _cuantity;
  String get cuantityType => _cuantityType;
  double get price => _price;

  set name(String newName) {
    if(newName.length <= 25){
      this._name = newName;
    }
  }

  set cuantity(double newCuantity) {
    if(newCuantity > 0){
      this._cuantity = newCuantity;
    }
  }

  set cuantityType(String newCuantityType) {
    this._cuantityType = newCuantityType;
  }

  set price(double newPrice) {
    if(newPrice > 0){
      this._price = newPrice;
    }
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id != null){
      map['id'] = _id;
    }
    map['name'] = _name;
    map['cuantity'] = _cuantity;
    map['cuantityType'] = _cuantityType;
    map['price'] = _price;

    return map;

  }

  Ingredient.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._cuantity = map['cuantity'];
    this._cuantityType = map['cuantityType'];
    this._price = map['price'];
  }



}