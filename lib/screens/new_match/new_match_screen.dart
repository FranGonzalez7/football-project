import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class NewMatchScreen extends StatelessWidget {
  const NewMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Partido'),
        backgroundColor: AppColors.primaryButton,
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SizedBox(
            height: 800,
            child: AspectRatio(aspectRatio: 16/9,
            child: Image.asset('assets/images/field.png',
            fit: BoxFit.contain,),),
          ),)
        ],
      )
    );
  }
}
