--//========================\\
--||  Sets Up ChunkSettings  ||
--\\========================//
local Settings = require("ChunkDecV2\\Settings");
local ChunkDecompiler = {
    DecompiledChunks = {};
};
ChunkDecompiler.Opcodes = Settings.ChunkDecompiler.Opcodes;

--//=========================\\
--||   Converts Int To Hex    ||
--\\=========================//
function ChunkDecompiler:IntToHex(int)
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

--//========================\\
--|| Get's Opcode From Name  ||
--\\========================//
function ChunkDecompiler:GetOpcodeFromName(name)
    local OP = 0;
    for _,instruction in pairs(ChunkDecompiler.Opcodes) do
        if (instruction[1] == name) then
            return OP;
        else
            OP = OP + 1;
        end
    end
    return -1;
end

--//========================\\
--|| Get's Name From Opcode  ||
--\\========================//
function ChunkDecompiler:GetNameFromOpcode(Opcode)
    local success, message = xpcall(function()
        return ChunkDecompiler.Opcodes[Opcode].N;
    end, function()
        return "undefined";
    end)
    return message;
end

--//========================\\
--|| Get's Args from Opcode  ||
--\\========================//
function ChunkDecompiler:GetArgs(chunk, COP, instruction, PC)
    local ret = "";
    local name = ChunkDecompiler:GetNameFromOpcode(instruction.opcode);

    for _,register in pairs(COP.Args) do
        if (instruction[register] > 255) then
            ret = ret .. instruction[register]-256 .. " ";
        else
            ret = ret .. instruction[register] .. " ";
        end
    end

    if (name == "jmp") then
        ret = ret .. "\t; Jump to Address " .. ChunkDecompiler:IntToHex(PC + instruction.sBx + 1);
    elseif (name == "getglobal") then
        ret = ret .. "\t; " .. chunk.constants[instruction.Bx].data;
    elseif (name == "loadk") then
        ret = ret .. "\t; ";
        local key = chunk.constants[instruction.Bx].data;
        if (tonumber(key) ~= nil) then else key = '"' .. key .. '"' end
        ret = ret .. key;
    elseif (name == "setglobal") then
        ret = ret .. "\t; " .. chunk.constants[instruction.Bx].data; 
    elseif (name == "closure") then
        local key = string.upper(string.gsub(tostring(chunk.prototypes[instruction.Bx]), 'table: ', ''));
        key = string.gsub(key, "X", '0');
        ret = ret .. "\t; " .. key;
    end
    return ret;
end

--//========================\\
--|| Decompiles Instruction  ||
--\\========================//
function ChunkDecompiler:DecompileInstruction(PC, chunk, instruction)
    local ret = ChunkDecompiler:IntToHex(PC) .. "\t[" .. instruction.opcode .. "]\t"
    local COP=nil;
    xpcall(function()
        COP = ChunkDecompiler.Opcodes[instruction.opcode];
    end, function()
        ret = ret .. "; Could not Fetch Instructon";
    end)

    if (COP~=nil) then
        if (COP.N ~= "setglobal") and (COP.N ~= "getglobal") then
            ret = ret .. COP.N .. "\t\t" .. ChunkDecompiler:GetArgs(chunk, COP, instruction, PC);
        else
            ret = ret .. COP.N .. "\t" .. ChunkDecompiler:GetArgs(chunk, COP, instruction, PC);
        end
    end

    return ret;
end

--//========================\\
--||   Decompiles a Chunk    ||
--\\========================//
function ChunkDecompiler:DecompileChunk(chunk)
    local ret = "";
    local PC = 0;
    
    if (#ChunkDecompiler.DecompiledChunks == 0) then
        ret = ret .. " main[";
    else
        ret = ret .. "chunk[";
    end
    ret = ret .. "NUPV " .. chunk.upvalues .. ", ";
    ret = ret .. "NARG " .. chunk.arguments .. ", ";
    ret = ret .. "PC " .. #chunk.prototypes .. ", ";
    ret = ret .. "IC " .. #chunk.instructions .. ", ";
    ret = ret .. "CC " .. #chunk.constants .. ", ";
    ret = ret .. "FLIN " .. chunk.first_line .. "]";
    ret = ret .. "\n";
    for _,instruction in pairs(chunk.instructions) do
        ret = ret .. ChunkDecompiler:DecompileInstruction(PC, chunk, instruction) .. "\n";
        PC = PC + 1;
    end
    table.insert(ChunkDecompiler.DecompiledChunks, ret);
    return ret;
end

return ChunkDecompiler;
