import 'package:firstapp/Objects/DatabaseHelper.dart';
import 'package:firstapp/Objects/Dish.dart';
import 'package:firstapp/Objects/Ingredient.dart';
import 'package:firstapp/Objects/Menu.dart';
import 'package:firstapp/Show/ShowDish.dart';
import 'package:firstapp/Show/ShowIngredient.dart';
import 'package:firstapp/Show/ShowMenu.dart';
import 'package:flutter/material.dart';

class ListWidget extends StatelessWidget{

  final String fileName;
  final List<String> titleList;
  final List<String> subsStringList;

  ListWidget({this.titleList, this.subsStringList, this.fileName});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      itemCount: titleList.length,
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
              onTap: () async{

                DatabaseHelper dbHelper = DatabaseHelper();
                await dbHelper.initializeDatabase();
                switch(fileName){
                  case "Ingredient":
                    {
                      Ingredient ingredient = await dbHelper.getIngredientByName(titleList[index]);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowIngredient(ingredient: ingredient,)));
                    }
                    break;
                  case "Dish":
                    {
                      Dish dish = await dbHelper.getDishByName(titleList[index]);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowDish(dish: dish,)));
                    }
                    break;
                  case "Menu":
                    {
                      Menu menu = await dbHelper.getMenuByName(titleList[index]);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowMenu(menu: menu,)));
                    }
                    break;
                  default:
                    break;
                }
              },
              title: Text(titleList[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(Icons.info_outline,
                color: Colors.deepPurple,
              ),
              contentPadding: EdgeInsets.symmetric( vertical: 0, horizontal: 6,),
              subtitle: Text(subsStringList[index],
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
