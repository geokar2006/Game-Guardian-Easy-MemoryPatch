local function MemoryPatch(libname, offset, hex)
  local start = 0
  ---------- FUNCTIONS ----------
  local function check_hex_symbol(sym)
    local hexdigts = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f"}
    for _,v in pairs(hexdigts) do
      if v == sym then
        return true
      end
    end
    return false
  end
  local function check_hex(hex)
    if #hex == 0 then return false end
    for i = 1, #hex do
      if not check_hex_symbol(hex:sub(i, i)) then return false end
    end
    return true
  end
  local function getHexFromMem(offsetFrom, offsetTo)
    local length = (offsetTo - offsetFrom) / 4
    local str = ""
    local num = 0
    for i = 1, length, 1 do
      local h = {}
      h[1] = {}
      h[1].address = start + offsetFrom + num
      h[1].flags = gg.TYPE_DWORD
      local output = string.format("%x", gg.getValues(h)[1].value)
      str = str..string.gsub(output,"ffffffff","")
      num = num + 4
    end
    return str
  end
  local function revers_hex(hex)
    local newhex = ""
    if #hex == 0 then return false end
    for g=1, #hex, 8 do 
      local curhex = string.sub(hex, g, g+7)
      for i=#curhex, 1, -2 do
        newhex = newhex..string.sub(curhex, i-1, i)
      end
    end
    return newhex:upper()
  end
  local function hex2gg_list(hex)
    local lst = {}
    for i=1, #hex, 8 do
      table.insert(lst, "h"..hex:sub(i, i+7))
    end
    return lst
  end
  ---------- DO WORK ----------
  hex = hex:gsub(" ", "")
  if not check_hex(hex) then print("Hex has error") return nil end
  local i = 0
  if not libname:sub(1, 3) == "lib" then
    libname = "lib"..libname
  end
  local result = gg.getRangesList(libname)
  while true do
    i = i + 1
    if result[i].type == "r-xp" then
      start = result[i].start
      break
    end
  end
  local this = {}
  local inmemsize = 0
  if #hex % 4 ~= 0 then
    inmemsize = #hex / 2 + (16 - #hex % 4)
  else
    inmemsize = #hex / 2
  end
  local original_hex = revers_hex(getHexFromMem(offset, offset+inmemsize, false))
  local original_hex_gg = hex2gg_list(original_hex)
  newhex = ""
  if #hex < #original_hex then
    newhex = hex..original_hex:sub(#hex+1)
  end
  local hex_gg_list = hex2gg_list(newhex)
  local is_modifed = false
  ---------- Modify and Restore functions ----------
  this.Modify = function()
    local num = 0
    for g,v in ipairs(hex_gg_list) do
      local h = {}
      h[1] = {}
      h[1].address = start + offset + num
      h[1].flags = gg.TYPE_DWORD
      h[1].value = v
      gg.setValues(h)
      num = num + 4
    end
  end
  this.Restore = function()
    local num = 0
    for g,v in ipairs(original_hex_gg) do
      local h = {}
      h[1] = {}
      h[1].address = start + offset + num
      h[1].flags = gg.TYPE_DWORD
      h[1].value = v
      gg.setValues(h)
      num = num + 4
    end
  end
  return this
end