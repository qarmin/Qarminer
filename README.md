## Qarminer
Qarminer is simple tool(type of fuzzer) to find some types of bugs in Godot Engine with help of automation.

Contains three main tools:
- Executing every single function randomly(or not)
- Creating test GDScript project(e.g. to support converting projects from Godot 3.x to 4.x version)
- Testing Physics nodes

Qarminer can test functions with random data(used for fuzzing(just look into CI of this project)) or always with same(used as simple check in Godot CI)

## Modes
### Function tests
Basic mode of Qarminer is to test each available function with specific arguments.  
To use it just execute `FunctionExecutor.tscn`.  
It will get list of all classes(minus some user exceptions) and all its functions(minus some functions which are known that cause crashes or do something strange).  
Next object class is created and each available function is executed on it with random or not arguments

### Creating Test Projects
Executing `CreateGDScriptProject.tscn` will allow to create test project in `GDScript` folder.  
This projects allow to check how project works when functions randomly are executed and also allow to easy change/mix invidual classes and functions.

### Testing Physics
Project adds randomly physics nodes, set shape to it, move and at the end delete.

## 4.0 version
There is in 4.0 branch, a project for testing Godot 4.0.  
Since Godot 4.0 isn't stabilized yet, project needs to be changed frequently.

## Differences between projects in The-Worst-Godot-Test-Project and Qarminer
### Qarminer advantages
- Automation - automatically list of functions is taken from Godot, so there is no way that I forgot to add recently added by Godot functions
- Size - Automation code `~2200` lines. Project code - Qarminer `50000` lines(auto generated) - The Worst `25000` lines(manually added)
- No dependeces - in created project each script is independent unlike as in The Worst(`Autoload.gd` and `AutoObjects.gd` autoloads are required), which allow to easily strip project and create minimal code to reproduce.
- Function testing - Each function can be tested almost independetially
- Scalability - It is very easy to create different modules which do different tasks

### The Worst Godot Test Project advantages
- Flexibility - each scene/script can easily have set invidual values
- Non object support - Unlike Qarminer, allow to execute functions at e.g String, Vector2 etc.

## LICENSE
MIT
