import 'package:flutter/material.dart';
import 'package:virtual_hike/ui/buttons.dart';
import 'package:virtual_hike/ui/ui_elements.dart';

class MyAppAlerts {
  static void alertDialogStepsUnavailable(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(UIElements.STEPS_UNAVAILABLE_ERROR),
          content: Text(UIElements.STEPS_UNAVAILABLE_INFO),
          actions: <Widget>[MyAppButtons.buildButtonOK(context, "Okay")],
          elevation: 5,
        );
      },
    );
  }

  static void alertDialogRouteNotChosen(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(UIElements.ROUTE_SELECTION_UNSUCCESSFUL),
          content: Text(UIElements.ROUTE_SELECTION_GUIDE),
          actions: <Widget>[MyAppButtons.buildButtonOK(context, "Okay")],
          elevation: 5,
        );
      },
    );
  }

  static void alertDialogRoutesEmpty(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(UIElements.ROUTE_HISTORY_NO_ROUTES),
          content: Text(UIElements.ROUTE_HISTORY_NO_ROUTES_GUIDE),
          actions: <Widget>[MyAppButtons.buildButtonBack(context, "Back")],
          elevation: 5,
        );
      },
    );
  }
}
