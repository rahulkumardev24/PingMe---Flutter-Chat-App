import 'package:flutter/material.dart';

class MyNavigationButton extends StatefulWidget {
  Color? btnBackground ;
  Color? iconColor ; 
  IconData btnIcon ;
  double? iconSize ;
  VoidCallback onPressed ;
  
  MyNavigationButton({super.key , 
     this.btnBackground = Colors.white,
     this.iconColor  , 
    required this.btnIcon ,
    required this.onPressed ,
    this.iconSize = 18 ,
  });

  @override
  State<MyNavigationButton> createState() => _MyNavigationButtonState();
}

class _MyNavigationButtonState extends State<MyNavigationButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: widget.onPressed ,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation:0,
      backgroundColor: widget.btnBackground,
      child:Icon(widget.btnIcon , size:widget.iconSize,),);
  }
}
