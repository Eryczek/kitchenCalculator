import 'package:firstapp/ListLayouts/Ingredients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Create/CreateDish.dart';
import 'Create/CreateIngredient.dart';
import 'Create/CreateMenu.dart';
import 'HomePage.dart';
import 'ListLayouts/Dishes.dart';
import 'ListLayouts/Menus.dart';
import 'app_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales){
        for(var supportedLocale in supportedLocales){
          if(supportedLocale.languageCode == locale.languageCode){
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/ListLayouts/Menus': (context) => Menus(),
        '/ListLayouts/Dishes': (context) => Dishes(),
        '/ListLayouts/Ingredients': (context) => Ingredients(),
        '/Create/CreateMenu': (context) => CreateMenu(),
        '/Create/CreateDish': (context) => CreateDish(),
        '/Create/CreateIngredient': (context) => CreateIngredient(),

      },
    );
  }
}

