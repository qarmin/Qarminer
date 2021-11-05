## Qarminer
Qarminer is fuzzer which finds crashes, memory leaks and undefined behaviors in Godot Engine.  
It can be used to fuzz Godot modules(C++, Rust etc.), already found several crashes in [Goost](https://github.com/goostengine/goost), [Godex](https://github.com/GodotECS/godex/) or [Godot Voxel](https://github.com/Zylann/godot_voxel).

This reporsitory constains many tools:
- Executing every single function randomly(or not)
- Creating test GDScript project(e.g. to support converting projects from Godot 3.x to 4.x version)
- Testing Physics nodes
- Variant Tester - test functions in builtin Godot classes like String
- Reparenting/Deleting - tool to reparent and delete randomly nodes
- Simple Things - creates and deletes objects

Qarminer can test functions with random data(used for fuzzing - just look into CI of this project) or always with same(used as simple check in Godot CI)

## Modes
### Function tests
Basic mode of Qarminer is to test each available function with specific arguments.  
To use it just execute `FunctionExecutor.tscn`.  
It will get list of all classes(minus some user exceptions) and all its functions(minus some functions which are known that cause crashes or do something strange).  
Next object class is created and each available function is executed on it with random or not arguments  
Executed things are saved to files, so it is easy to check if crashes are reproducible and report crashes.

### Creating Test Projects(Deprecated)
Executing `CreateGDScriptProject.tscn` will allow to create test project in `GDScript` folder.  
This projects allow to check how project works when functions randomly are executed and also allow to easy change/mix invidual classes and functions.  
This thing is deprecated, because function testing is simpler and easier to use method to get crashes.  
The only thing that is better in this tool, is ability to not remove things between frames(but I want to implement this also in tool above).

### Testing Physics
Project adds randomly physics nodes, set shape to it, move and at the end delete.  
For now it is quite hard to find exact steps to reproduce crashes.

### Variant Tester(TODO)
This needs https://github.com/godotengine/godot/pull/49053 to work.  
Same as Function Tester it tests functions but on builtin classes like e.g. String.

### Reparenting Deleting(TODO)
Tool which randomly reparents and delete nodes.  
It is improved version with logging of RegressionTestProject

### Simple Things
Tool which creates objects and deletes objects.  
It is used to early catch most important and the easiest to fix bugs.

## 4.0 version
4.0 version is available in 4.0 branch.  
Conversion project from 3.x to 4.0 is quite easy and require to use project converter - https://github.com/godotengine/godot/pull/51950.  
Later only uncommenting some code which handle additional types like Callable or Signal is required

## LICENSE
MIT
