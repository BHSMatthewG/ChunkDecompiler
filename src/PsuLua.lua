local Settings = require("ChunkDecV2\\Settings");
local PseudoLua = {
    ChunkIndex = 0;
};

PseudoLua.Opcodes = Settings.PseudoLua.Opcodes;

function PseudoLua:IntToHex(int)
    local wheel = "0123456789ABCDEF";
    local result = "";
    int = int + 1;
    while int > 0 do
        local modifier = math.fmod(int, 16);
        result = string.sub(wheel, modifier+1, modifier+1) .. result;
        int = math.floor(int / 16);
    end
    if result == "" then result = "0" end;
    return "0x" .. result;
end

function PseudoLua:GetNameFromOpcode(Opcode)
    local success, message = xpcall(function()
        return PseudoLua.Opcodes[Opcode].N;
    end, function()
        return "undefined";
    end)
    return message;
end

function PseudoLua:GetOpcodeFromName(name)
    for y,instruction in pairs(PseudoLua.Opcodes) do
        if (instruction.N == name) then
            return y;
        end
    end
    return -1;
end

function PseudoLua:GeneratePseudoFunction(chunk)
    local ret = "";
    PseudoLua.ChunkIndex = PseudoLua.ChunkIndex + 1;
    ret = "[" .. PseudoLua:IntToHex(0) .. "]\t.function f" .. PseudoLua.ChunkIndex .. "(";
    for argcount = 1, chunk.arguments do
        if (chunk.arguments == argcount) then
            ret = ret .. "arg" .. argcount-1;
        else
            ret = ret .. "arg" .. argcount-1 .. ", ";
        end
    end
    ret = ret .. ")\n";
    local PC = 1;
    for _,instruction in pairs(chunk.instructions) do
        ret = ret .. "[" .. PseudoLua:IntToHex(PC) .. "]\t";
        local dec = PseudoLua:GenerateInstruction(chunk, instruction, PC);
        if (dec == "end") then
            ret = ret .. "." .. dec .. "\n";
        else
            ret = ret .. "\t." .. dec .. "\n";
        end
        PC = PC + 1;
    end

    return ret;
end

function PseudoLua:GenerateInstruction(chunk, instruction, PC)
    local PseudoInstructions = {
        [PseudoLua:GetOpcodeFromName("move")] = function(instruction) -- LUA MOVE
            return "move " .. instruction.A .. " -> " .. instruction.B;
        end,
        [PseudoLua:GetOpcodeFromName("loadk")] = function(instruction) -- LUA LOADK
            local x = "local v" .. instruction.A .. " = ";
            local c = chunk.constants[instruction.Bx].data;
            if (tonumber(c) ~= nil) then
                x = x .. c;
            else
                x = x .. "'" .. c .. "'";
            end
            return x;
        end,
        [PseudoLua:GetOpcodeFromName("loadbool")] = function(instruction) -- LUA LOADBOOL
            return "loadbool " .. instruction.B ~= 0;
        end,
        [PseudoLua:GetOpcodeFromName("loadnil")] = function(instruction) -- LUA LOADNIL
            return "set " .. instruction.A .. " -> " .. instruction.B .. " to nil";
        end,
        [PseudoLua:GetOpcodeFromName("getupval")] = function(instruction) -- LUA GETUPVAL
            return "set Stack[R(A)] to UP[R(B)]\t-- Stack[" .. instruction.A .. "], UP[" .. instruction.B .. "]";
        end,
        [PseudoLua:GetOpcodeFromName("getglobal")] = function(instruction) -- LUA GETGLOBAL
            return "get " .. chunk.constants[instruction.Bx].data;
        end,
        [PseudoLua:GetOpcodeFromName("call")] = function(instruction) -- LUA CALL
            return "call()";
        end,
        [PseudoLua:GetOpcodeFromName("return")] = function(instruction) -- LUA RETURN
            if (instruction.B ~= 1) and (instruction.A ~= 0) then
                return "return";
            else
                return string.lower("END");
            end
        end,
        [PseudoLua:GetOpcodeFromName("jmp")] = function(instruction) -- LUA JMP
            local jmpAddress = PC + instruction.sBx + 1;
            return "jump to " .. PseudoLua:IntToHex(jmpAddress);
        end,
        [PseudoLua:GetOpcodeFromName("closure")] = function(instruction) -- LUA CLOSURE
            local r = "pushclosure ";
            local key = string.upper(string.gsub(tostring(chunk.prototypes[instruction.Bx]), 'table: ', ''));
            key = string.gsub(key, 'X', '0x');
            r = r .. key;
            return r;
        end,
    };
    local success, message = xpcall(function()
        return PseudoInstructions[instruction.opcode](instruction);
    end, function()
        return "undefined";
    end)

    return message;
end

return PseudoLua;
