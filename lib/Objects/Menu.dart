
class Menu {

  int _id;
  String _name;
  String _restaurant;

  Menu(this._name, this._restaurant);

  int get id => _id;
  String get name => _name;
  String get restaurant => _restaurant;

  set name(String newName) {
    if(newName.length <= 25){
      this._name = newName;
    }
  }

  set restaurant(String newRestaurant) {
    if(newRestaurant.length <= 25){
      this._restaurant = newRestaurant;
    }
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id != null){
      map['id'] = _id;
    }
    map['name'] = _name;
    map['restaurant'] = _restaurant;

    return map;

  }

  Menu.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._restaurant = map['restaurant'];
  }
}