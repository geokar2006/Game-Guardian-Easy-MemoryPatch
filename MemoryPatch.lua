local function MemoryPatch(lib, offset, hex)
    local originalHex, ok, modified, hexTable, originalHexTable, libAddr = "", false, false, {}, {}, 0

    ---------- FUNCTIONS ----------
    local function isValidHex(hex) return #hex > 0 and hex:lower():find("[^%dabcdef]") == nil end
    local function readMemory(offset, size)
        local ret = ""
        local function f(v) v = string.format("%X", v) if #v == 1 then return "0"..v end return v end -- convert int to hex string 
        for i = 0, size - 1 do ret = ret..f(gg.getValues({{address = offset + i, flags = gg.TYPE_BYTE}})[1].value) end
        return ret
    end
    local function reverseHex(hex)
        local ret = ""
        if #hex == 0 then return false end
        for i = 1, #hex, 2 do ret = ret..hex:sub(i, i + 1) end
        return ret:upper()
    end
    -- Convert hex string to gg patch table
    local function hex2patchTable(hex, offset)
        local ret = {}
        local i = 0
        for v in hex:gmatch("%S%S") do table.insert(ret, {address = offset + i, flags = gg.TYPE_BYTE, value = v.."r"}) i = i + 1 end
        return ret
    end
    local methods = {
        Modify = function() if ok and not modified then gg.setValues(hexTable) modified = true return true end return false end,
        Restore = function() if ok and modified then gg.setValues(originalHexTable) modified = false return true end return false end,
        GetInfo = function() return {ok = ok, lib = lib, offset = string.format("0x%X", libAddr).." + "..string.format("0x%X", offset), hex = hex, originalHex = originalHex} end,
        IsModified = function() return modified end
    }

    ---------- DO WORK ----------
    hex = hex:gsub(" ", ""):gsub("0x", ""):upper() -- Remove spaces and 0x
    if not isValidHex(hex) then print("[MemoryPatch] Hex is wrong for "..methods.GetInfo()) return methods end -- Check Hex

    -- Try find lib
    for _, v in ipairs(gg.getRangesList(lib)) do
        if v.type == "r-xp" or v.state == "Xa" then
            libAddr = v.start
            ok = true
            break
        end
    end
    if not ok then print("[MemoryPatch] Lib not found for "..methods.GetInfo()) return methods end
    -- Read original hex and fix patch hex if need
    originalHex = reverseHex(readMemory(libAddr + offset, (#hex + #hex % 2) / 2))
    if #hex < #originalHex then
        hex = hex..originalHex:sub(#originalHex) -- Add byte if hex not even length
    end
    hexTable = hex2patchTable(hex, libAddr + offset)
    originalHexTable = hex2patchTable(originalHex, libAddr + offset)

    return methods
end