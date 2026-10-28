setmetatable(_G, {__index = function(t, k) local v = setmetatable({}, {__index = function() return 0 end, __call = function() return {} end}); rawset(t, k, v); return v end})
function import() return setmetatable({}, {__index = function() return function() return {} end end}) end
local f = assert(io.open(arg[1], "rb")); local src = f:read("*a"); f:close()
src = src:gsub("^\239\187\191", "")
pcall(assert(loadstring(src)))
local out = io.open(arg[2], "w")
local function esc(s) return (tostring(s):gsub('["'..string.char(92)..']', function(c) return string.char(92)..c end)) end
out:write("{")
local first = true
for _, k in ipairs({"hair","beard","hairTop","hairSide","hairSide2","hairCap_col","moustache","chinhair","sideburns","eyebrows_head_col","headShapeMorphList","jawShapeMorphList","noseShapeMorphList","eyesShapeMorphList","mouthShapeMorphList","ethnicityShapeMorphList","earsShapeMorphList","bodyPresetList_male","bodyPresetList_female","crows_feet_col","m_ethnicity_col","f_ethnicity_col","head_col"}) do
  local m = ItemMaps[k]; local list = m and (m.item_setup or m)
  if type(list) == "table" then
    out:write((first and "" or ",") .. '\n"' .. k .. '":['); first = false
    local fi = true
    for i, it in ipairs(list) do
      if type(it) == "table" then
        out:write((fi and "" or ",") .. "{"); fi = false
        local fk = true
        for kk, vv in pairs(it) do
          if type(vv) == "string" or type(vv) == "number" or type(vv) == "boolean" then
            out:write((fk and "" or ",") .. '"' .. esc(kk) .. '":' .. (type(vv) == "string" and ('"' .. esc(vv) .. '"') or tostring(vv))); fk = false
          end
        end
        out:write("}")
      end
    end
    out:write("]")
  end
end
out:write(',\n"hairColours":[')
for i, c in ipairs(ItemMaps.hairColours) do local col = c.colour or {} out:write((i > 1 and "," or "") .. string.format('{"guid":%s,"rgb":[%s,%s,%s]}', tostring(c.guid), tostring(col[1]), tostring(col[2]), tostring(col[3]))) end
out:write('],\n"skin":[')
for i, c in ipairs(ColourSwatches.skinColourSwatches) do out:write((i > 1 and "," or "") .. string.format('{"guid":%s,"rgb":[%s,%s,%s]}', tostring(c.guid), c.r, c.g, c.b)) end
out:write("]}\n")
out:close()
