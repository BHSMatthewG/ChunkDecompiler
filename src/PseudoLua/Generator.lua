local PseudoLua = {};

function PseudoLua:GeneratePseudo(chunk)
  local ret = "[0]\t.function(";
  local acount = 0;
  for acount = 1, chunk.arguments do
    if (chunk.arguments == acount) then
      ret = ret .. "arg" .. acount;
    else
      ret = ret .. "arg" .. acount .. ",";
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
    [5] = function(ins) -- LUAC GETGLOBAL
      return "get " .. chunk.constants[ins.Bx].data;
    end,
    [1] = function(ins) -- LUAC LOADK
      local x = "local ";
      local c = chunk.constants[ins.Bx].data;
      if (tonumber(c) ~= nil) then
        x = x .. c;
      else
        x = x .. "'" .. c .. "'";
      end
      return x;
    end,
    [28] = function(ins) -- LUAC CALL
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
    [30] = function(ins) -- LUAC RETURN
      if (ins.B ~= 1) and (ins.A ~= 0) then
        return "return";
      else
        return "end";
      end
    end,
    [22] = function(ins) -- LUAC JMP
      return "goto line: " .. PC+ins.sBx + 1
    end,
  };
  if (pseudoInstructions[instruct.opcode] ~= nil) then
    return pseudoInstructions[instruct.opcode](instruct);
  else
    return "undefined"
  end
end

return PseudoLua
