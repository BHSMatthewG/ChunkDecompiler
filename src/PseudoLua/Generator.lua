local PseudoLua = {};

function PseudoLua:GeneratePseudo(chunk)
  local ret = ".function\n";
  local PC = 1;
  for _,instruction in pairs(chunk.instructions) do
    ret = ret .. "." .. PseudoLua:GenerateInstruction(chunk, instruction, PC) .. "\n";
    PC = PC+1;
  end
  return ret;
end

function PseudoLua:GenerateInstruction(chunk, instruct, PC)
  local pseudoInstructions = {
    [5] = function(ins)
      return "get " .. chunk.constants[ins.Bx].data;
    end,
    [1] = function(ins)
      local x = "load ";
      local c = chunk.constants[ins.Bx].data;
      if (tonumber(c) ~= nil) then
        x = x .. c;
      else
        x = x .. "'" .. c .. "'";
      end
      return x;
    end,
    [28] = function(ins)
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
    [30] = function(ins)
      if (ins.B ~= 1) and (ins.A ~= 0) then
        return "return";
      else
        return "end";
      end
    end,
  };
  return pseudoInstructions[instruct.opcode](instruct);
end
