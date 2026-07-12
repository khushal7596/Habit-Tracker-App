import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/dataBase/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utils/habit_util.dart';
import 'package:provider/provider.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   
  @override
  void initState() {
      // read existing habits on app startup
      Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }


  // TextController
  final TextEditingController textController = TextEditingController();



  void createNewHabit(){
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Create a new Habit"),
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: (){
              // get the new habit name
              String newHabitName = textController.text;

              // save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              // pop box
              Navigator.pop(context);

              // clear controller
              textController.clear();
            },
            child: const Text("Save"),
            
            ),

            // cencel button
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
                textController.clear();
              },
              child: Text("Cencel"),
            )


        ],
      ));
  }


  // Check Habit On Or Off
  void checkHabitOnOff(bool? value , Habit habit){
    // update habit completion status
    if(value != null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id , value);
    }
  }


  // edit habit box
  void editHabitBox(Habit habit){
    // set the controller's text to the habit current name 
    textController.text = habit.name;
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: (){
              // get the new habit name
              String newHabitName = textController.text;

              // save to db
              context.read<HabitDatabase>().updateHabitName(habit.id , newHabitName);

              // pop box
              Navigator.pop(context);

              // clear controller
              textController.clear();
            },
            child: const Text("Save"),
            
            ),

            // cencel button
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
                textController.clear();
              },
              child: Text("Cencel"),
            )


        ],
      )
    );

  }

  // delete habit box

  void deleteHabitBox(Habit habit){
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        title: Text("Are You Sure To Remove This Habit"),
        actions: [
          // delete button
          MaterialButton(
            onPressed: (){
             

              // delete to db
              context.read<HabitDatabase>().deleteHabit(habit.id,);

              // pop box
              Navigator.pop(context);

            },
            child: const Text("Remove"),
            
            ),

            // cencel button
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
                
              },
              child: Text("Cencel"),
            )


        ],
      )
    );
  }


  // build habit list
  Widget _buildHabitList(){
    // habit db
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List <Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context , index){
        
        // get each individual habit
        final habit = currentHabits[index];

        // check if the habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit tilt ui
        return HabitTile(
          text: habit.name, 
          isCompleted: isCompletedToday, 
          onChanged: (value) => checkHabitOnOff(value , habit),
          editHabit: (context)=> editHabitBox(habit),
          deleteHabit: (context) =>deleteHabitBox(habit),
          );
    }
    );
  }
  // 



  // HEAT MAP BUILD
  Widget _buildHeatMap(){
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // Current Habit
    List<Habit> currentHabits = habitDatabase.currentHabits;


    return FutureBuilder(
      future: habitDatabase.getFirstLaunchDate(), 
      builder: (context, snapshot){
        // once the data available -> build Heatmap
        if(snapshot.hasData){
          final firstlaunchDate = snapshot.data!;
          final monthStartDate = DateTime(
            firstlaunchDate.year,
            firstlaunchDate.month,
            1
          );
          return MyHeatMap(startDate: monthStartDate, datasets: preapHeatMapDataset(currentHabits));
        }

        // handle case Where no data returned
        else {
          return Container();
        }
      });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer:MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        elevation: 0,
        child: Icon(Icons.add , color: Theme.of(context).colorScheme.inversePrimary,),
        ),
        body: ListView(
          children: [
            // HEATMAP
            _buildHeatMap(),
            // HABITLIST
            _buildHabitList(),

          ],
        ),

    );
  }
}
