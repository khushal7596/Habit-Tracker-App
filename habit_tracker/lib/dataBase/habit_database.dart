import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
class HabitDatabase extends ChangeNotifier{
  static late Isar isar;

  /*
  
  S E T U P
  
  
   */

  // I N I T I A L I Z E - DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }


  // Save First date of app startup (for heatmap)

 static Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if(existingSettings == null){
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async{
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }



  /*

  C U R D - O P E R A T I O N S
   
   */

  // List of Habits
  final List<Habit> currentHabits = [];


  // Create - add a new habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;
    await isar.writeTxn(()=> isar.habits.put(newHabit));

    // re read from db
    readHabits();

  }

  // Read - read saved habits from daabase

  Future<void> readHabits() async {
    // fetch all habit from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);


    // update ui
    notifyListeners();
  }

  // Update - check habit on and off
  Future<void> updateHabitCompletion (int id , bool isCompleted)async{
    // find all specific habit
    final habit = await isar.habits.get(id);

    if(habit!=null){
      await isar.writeTxn(()async {
        // if habit is completed -> add the current date to the completedDays list
        if(isCompleted && !habit.completedDays.contains(DateTime.now())){
          // today
          final today = DateTime.now();
          // add the current date if it's not already in the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            )
            );
        }
        // otherwise remove the current date from the list
        else{
          // remove the current date if the habit is marked as not completed
          habit.completedDays.removeWhere(
            (date)=> 
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day 
          );
        }
        // save the updated habit back to the db
        await isar.habits.put(habit);

      });
    }

    // re read from db
    readHabits();

  }

  // Update - edit habit name

  Future<void> updateHabitName(int id , String newName) async{
    // find the specific habit
    final habit = await isar.habits.get(id);
      if(habit != null){
        
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
     });

      }
      // re read from db
      readHabits();
  }

  // Delete delete habit
  Future<void> deleteHabit(int id) async{
    await isar.writeTxn(()async{
       isar.habits.delete(id);
    });

    readHabits();
  }



}
