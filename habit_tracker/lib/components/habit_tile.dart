import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  void Function(bool?)? onChanged;
  void Function(BuildContext)? editHabit;
  void Function(BuildContext)? deleteHabit;
   HabitTile({
    super.key , 
    required this.text , 
    required this.isCompleted ,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0 , vertical: 10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(), 
          children: [
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
              ),
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
              )
          ]
        ),
        child: GestureDetector(
          onTap: (){
            if(onChanged != null){
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8)
          
            ),
            padding: EdgeInsets.all(12),
            // margin: EdgeInsets.symmetric(vertical: 5 , horizontal: 25),
            child: ListTile(
              title: Text(text),
              leading: Checkbox(
                value: isCompleted, 
                onChanged:onChanged ,
                activeColor: Colors.green,
                checkColor: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}