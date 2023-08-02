function print(...)
    for i, e in ipairs(arg) do
        DEFAULT_CHAT_FRAME:AddMessage(tostring(e));
    end
end

local SPELL_RANK_PATTERN = "%(Rank (%d+)%)"

SLASH_RELOAD1 = "/reload"
SLASH_RELOAD2 = "/rl"

SlashCmdList["RELOAD"] = function() ReloadUI() end;

oldTostring = tostring;

function stripSpellRank(spellName)
    return string.gsub(spellName, SPELL_RANK_PATTERN, "");
end


local spellBook = {};
do
    local spellID = 1;
    local spellName, spellRank;
    while true do
        spellName, spellRank = GetSpellName(spellID, "spell");
        if spellName == nil then break end;
        local suffix;
        if tonumber(spellRank) then
            suffix = string.format("(Rank %d)", tonumber(spellRank));
        else
            suffix = "(" .. tostring(spellRank) .. ")";
        end 
        
        spellBook[spellName .. suffix] = spellID;
        spellBook[stripSpellRank(spellName)] = spellID; --Max rank spell
        spellID = spellID + 1;
    end;
    
end

function GetSpellID(spellName)
    return spellBook[spellName]
end

function SpellIsOnCooldown(spellName)
    local start, duration, enabled = GetSpellCooldown(GetSpellID(spellName), "spell");
    return start ~= 0;
end

function SpellIsEnabled(spellName)
    local start, duration, enabled = GetSpellCooldown(GetSpellID(spellName), "spell");
    return enabled == 0; --enabled = 0 actually means spell is enabled. Fucked up.
end

function tableTostring(tbl, indent)
	local ILENGTH = 4;
    local ICHAR = " "
    local MAX_INDENT = 3;
	indent = indent or 0;
	ret = string.rep(ICHAR, indent * ILENGTH) .. "{\n";
	indent = indent + 1
	for i, e in tbl do
        if indent <= MAX_INDENT then
		    ret = ret .. string.rep(ICHAR, indent * ILENGTH) .. "[" .. i .. "]" .. " : " .. ((type(e) ~= "table") and tostring(e) or (oldTostring(e) .. ": \n" .. tableTostring(e, indent + 1))) .. "\n";
        else
            ret = ret .. string.rep(ICHAR, indent * ILENGTH + 1) .. "...\n";
        end
	end
	indent = indent - 1;
	ret = ret .. string.rep(ICHAR, indent * ILENGTH) .. "}";
	return ret;
end



tostring = function(obj)
	if type(obj) ~= "table" then
		return oldTostring(obj);
	end
	return tableTostring(obj)
end


string.join = function(token, arr)
    assert(type(arr) == "table" and type(token) == "string");
    local i = 1;
    local ret = getn(arr) >= 1 and arr[1] or "";
    while i <= getn(arr) - 1 do
        i = i + 1;
        ret = ret .. token .. arr[i];
    end
    return ret;
end



string.strip = function(str)
    return string.gsub(str,"^%s*(%S+.*%S*)%s*", "%1")
end

table.has = function(tbl, element)
    for i, e in tbl do
        if e == element then return true end;
    end
    return false;
end