import 'package:flutter/material.dart';

class DropDownAppBar extends StatelessWidget {

  DropDownAppBar({this.sortList, this.itemSelected, this.setItemSelected });

  final List<String> sortList;
  final String itemSelected;
  final Function setItemSelected;


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 50,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: DropdownButton(
        isExpanded: true,
        value: itemSelected,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.deepPurple,
        ),
        iconSize: 28,
        onChanged: (String newItem){
          setItemSelected(newItem);
        },
        style: TextStyle(
          fontSize: 16,
        ),
        items: sortList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.deepPurple,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}