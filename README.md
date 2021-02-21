## Qarminer
Qarminer is simple tool(type of fuzzer) to find some types of bugs in Godot Engine with help of automation.

Contains three scenes which:
- Executes every single function
- Creating test GDScript project
- Creating test C# project(WIP, can't test because Mono Godot not working on my machine)

Qarminer can test functions with random data(helpful with fuzzing) or always with same(helpful in CI)

## Modes
### Function tests
Basic mode of Qarminer is to test each available function with specific arguments.  
To use it just execute `FunctionExecutor.tscn`.  
It will get list of all classes(minus some user exceptions) and all its functions(minus some functions which are known that cause crashes or do something strange).  
Next object class is created and each available function is executed on it with random or not arguments

### Creating Test Projects
Executing `CreateGDScriptProject.tscn` will allow to create test project in `GDScript` folder.  
Same `CreateCSharpProject.tscn` will create a new project in `CSharp` folder.  
This projects allow to check how project works when functions randomly are executed and also allow to easy change/mix invidual classes and functions.

## 4.0 version
Currently GDScript in Godot 4.0 is heavily broken, so it is not possible to get current newest version of Qarminer from master branch(with 3.2 Godot support) and easily update it to 4.0.  
Some basic port you can find in 4.0 branch(little striped and outdated)

## TODO
- Add signal checking - some basic progress I have done, but I don't know if it is possible(probably I will wait for Godot 4.0, which change most of things).
- Add generating special projects - like for physics - Areas with CollisionsBody etc.

## Differences between projects in The-Worst-Godot-Test-Project and Qarminer
### Qarminer advantages
- Automation - automatically list of functions is taken from Godot, so there is no way that I forgot to add recently added by Godot functions
- Size - Automation code `~1200` lines. Project code - Qarminer `34000` lines(auto generated) - The Worst `25000` lines(manually added)
- No dependeces - in created project each script is independent unlike as in The Worst(`Autoload.gd` and `AutoObjects.gd` autoloads are required), which allow to easily strip project and create minimal code to reproduce
- Function testing - Each function can be tested almost independetially

### The Worst Godot Test Project advantages
- Flexibility - each scene/script can have set invidual values
- Resources - Support for loading and modify resources before use it in functions
- Non object support - Unlike Qarminer, allow to execute functions at e.g String, Vector2 etc.

## LICENSE
MIT
