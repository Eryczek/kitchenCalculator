
class DishMenu {

  int _id;
  int _menuId;
  int _dishId;

  DishMenu(this._menuId, this._dishId);

  int get id => _id;
  int get menuId => _menuId;
  int get dishId => _dishId;

  set menuId(int newMenuId) {
    this._menuId = newMenuId;
  }

  set dishId(int newDishId) {
    this._dishId = newDishId;
  }


  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id!= null){
      map['id'] = _id;
    }
    map['menuId'] = _menuId;
    map['dishId'] = _dishId;

    return map;

  }

  DishMenu.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._menuId = map['menuId'];
    this._dishId = map['dishId'];
  }
}