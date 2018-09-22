local PseudoLua = {};

function PseudoLua:GeneratePseudo(chunk)
  local ret = "";
  ret = "[0]\t.function(";
  for acount = 1, chunk.arguments do
    if (chunk.arguments == acount) then
      ret = ret .. "arg" .. acount-1;
    else
      ret = ret .. "arg" .. acount-1 .. ", ";
    end
  end
  ret = ret .. ")\n";
  local PC = 1;
  for _,instruction in pairs(chunk.instructions) do
    ret = ret .. "[" .. PC .. "]\t";
    local r = PseudoLua:GenerateInstruction(chunk, instruction, PC);
    if (r == "end") then
      ret = ret .. "." .. r .. "\n";
    else
      ret = ret .. "\t." .. r .. "\n";
    end
    PC = PC+1;
  end
  return ret;
end

function PseudoLua:GenerateInstruction(chunk, instruct, PC)
  local pseudoInstructions = {
    [5] = function(ins) -- LUA GETGLOBAL
      return "get " .. chunk.constants[ins.Bx].data;
    end,
    [1] = function(ins) -- LUA LOADK
      local x = "local v" .. ins.A .. " = ";
      local c = chunk.constants[ins.Bx].data;
      if (tonumber(c) ~= nil) then
        x = x .. c;
      else
        x = x .. "'" .. c .. "'";
      end
      return x;
    end,
    [28] = function(ins) -- LUA CALL
      if (chunk.instructions[PC-1].opcode == 1) then
        local e = chunk.constants[chunk.instructions[PC-1].Bx].data;
        if (tonumber(e) == nil) then
          e = "'" .. e .. "'";
        end
        return "call(" .. e .. ")"
      else
        return "call(args)";
      end
    end,
    [30] = function(ins) -- LUA RETURN
      if (ins.B ~= 1) and (ins.A ~= 0) then
        return "return";
      else
        return "end";
      end
    end,
    [22] = function(ins) -- LUA JMP
      return "goto line: " .. PC+ins.sBx + 1
    end,
    [12] = function(ins) -- LUA ADD
      local r = "add ";
      r = r .. "v" .. ins.B .. " + " .. "v" .. ins.C;
      return r;
    end,
    [13] = function(ins) -- LUA SUB
      local r = "sub ";
      r = r .. "v" .. ins.B .. " - " .. "v" .. ins.C;
      return r;
    end,
    [23] = function(ins) -- LUA EQ
      local r = "if (" .. ins.B .. " == " .. ins.C-256 .. ") ~= " .. ins.A .. " goto line: " .. PC+2;
      return r;
    end,
    [7] = function(ins) -- LUA SETGLOBAL
      local r = "";
      r = chunk.constants[ins.Bx].data .. " = stack[R(A)]";
      return r;
    end,
    [36] = function(ins) -- LUA CLOSURE
      local r = "set[closure] ";
      local key = string.upper(string.gsub(tostring(chunk.prototypes[ins.Bx]), 'table: ', ''));
      key = string.gsub(key, "X", '0');
      r = r .. key;
      return r;
    end,
  };
  if (pseudoInstructions[instruct.opcode] ~= nil) then
    return pseudoInstructions[instruct.opcode](instruct);
  else
    return "undefined"
  end
end

return PseudoLua
