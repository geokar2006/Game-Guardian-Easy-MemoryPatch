# Game-Guardian-Easy-MemoryPatch
## Path any lib hex by offset in game guardian scripts. Fully writed by me.
# Usage:
```lua
local example_path = MemoryPatch("libil2cpp.so", 0x0, "a 17 f 400")
print(example_path.Modify()) -- true if lib found and hex ok and not modified
print(example_path.IsModified()) -- true or false
print(example_path.Restore()) -- true if lib found and hex ok and modified
print(example_path.GetInfo()) --[[{
                                    ['hex'] = 'A17F4006', -- 6 from original hex
                                    ['offset'] = '0x7C268E8000 + 0x0', -- 0x(lib address) + 0x(ur offset)
                                    ['originalHex'] = '7F454C46', -- Always this value because this is ELF header
                                    ['ok'] = true, -- false if lib not found or hex is wrong
                                    ['lib'] = 'libil2cpp.so',
                                }]]
```