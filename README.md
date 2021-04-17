# Game-Guardian-Easy-MemoryPatch
## Path any lib hex by offset in game guardian scripts. Fuly writed by me.
# Usage:
```lua
example_path = MemoryPatch("libil2cpp.so", 0x880CE8, "a 17 f 400")
example_path.Modify()
example_path.Restore()
```
# Information
## Many functions are local to hide methods in env.
