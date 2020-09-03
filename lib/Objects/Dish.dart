class Dish{

  int _id;
  String _name;
  double _portions;
  double _waste;
  double _price;

  Dish(this._name, this._portions, this._waste, this._price);

  int get id => _id;
  String get name =>_name;
  double get portions => _portions;
  double get waste => _waste;
  double get price => _price;

  set name(String newName){
    if(newName.length <= 25){
      this._name = newName;
    }
  }

  set portions(double newPortions){
    if(newPortions > 0){
      this._portions = newPortions;
    }
  }

  set waste(double newWaste){
    if(newWaste > 0){
      this._waste = newWaste;
    }
  }

  set price(double newPrice){
    if(newPrice > 0){
      this._price = newPrice;
    }
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id!=null){
      map['id'] = _id;
    }
    map['name'] = _name;
    map['portions'] = _portions;
    map['waste'] = _waste;
    map['price'] = _price;

    return map;
  }

  Dish.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._portions = map['portions'];
    this._waste = map['waste'];
    this._price = map['price'];
  }

}