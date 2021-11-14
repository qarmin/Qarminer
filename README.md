## Qarminer
Qarminer is fuzzer which finds crashes, memory leaks and undefined behaviors in Godot Engine.  
It can be used to fuzz Godot modules(C++, Rust etc.), already found several crashes in [Goost](https://github.com/goostengine/goost), [Godex](https://github.com/GodotECS/godex/) or [Godot Voxel](https://github.com/Zylann/godot_voxel).  
It found around 200/300 crashes, undefined behaviours, freezes etc. in Godot.

This repository contains many tools:
- Function Executor - run every function random arguments(or not)
- Physics Tester - run specialized test to catch more physics related bugs
- Variant Tester - test functions in builtin Godot classes like String
- Reparenting/Deleting - tool to reparent and delete randomly nodes
- Simple Things - creates and deletes objects of every class

Qarminer can test functions with random data(used for fuzzing - just look into CI of this project) or always with same(used as simple check in Godot CI)

I strongly suggest to use Godot binaries with Address + Undefined sanitizers(prebuilt binaries for Linux are available here(look at actions artifacts or releases page) - https://github.com/qarmin/GodotBuilds).  
Such binaries will help find bugs earlier and will provide very detailed info why exactly Godot crashed.

## Modes
### Function tests
Default and the most advanced tool of Qarminer which allows to tests all available classes and functions specific arguments.  
It is very flexible and can be configured via `settings.txt` file(for example usage look at `settings_example.txt`, list of all settings and default values are visible in `FunctionExecutor.gd`)
Info about executed functions, created objects, used arguments etc. are saved to files, so it is easy reproduce crashes and fix or report them.

### Testing Physics(TODO)
Project adds randomly physics nodes, set shape to it, move and at the end delete.  
For now it is quite hard to find exact steps to reproduce crashes.

### Variant Tester(TODO)
This needs https://github.com/godotengine/godot/pull/49053 to work.  
Same as Function Tester it tests functions but on builtin classes like e.g. String.

### Reparenting Deleting(TODO)
Tool which randomly reparents and delete nodes.  
It is improved version with logging of RegressionTestProject  
For now it is not possible to reproduce steps which cause crash

### Simple Things
Tool which creates objects and deletes objects.  
It is used to early catch most important and the easiest to fix bugs which happens when instancing or destroying objects.

## How to use it?
If you have your own module or library, just compile it normally to get Godot binary.  
I suggest to undefined and address sanitizer(`use_asan=yes use_ubsan=yes` on Linux and MacOS) and enable(or don't disable/strip) debug symbols.  
Next it is only required to run this repository, info should print to screen and GDScript commands should be written to `results.txt` file.  
After e.g. crash, you need only to check and try to run GDScript from file `results.txt` to find exact cause of crash.  

If you use non modified version of Godot, then you can experiment with with specific arguments, settings etc.  
Most crashes in official Godot binaries were fixed or reported to repository.  

## 4.0 version(WIP)
4.0 version is available in 4.0 branch, but since Godot 4 is not stable yet, project also isn't stable.  
Conversion project from 3.x to 4.0 is quite easy and require to use project converter - https://github.com/godotengine/godot/pull/51950.  
Later only uncommenting some code is required(marked by `TODOGODOT4`) which handle additional types like Callable or Signal is required

## LICENSE
MIT
