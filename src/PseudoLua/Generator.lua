local PseudoLua = {};

function PseudoLua:GeneratePseudo(chunk)
  local ret = "function\n";
  for _,instruction in pairs(chunk.instructions) do
    ret = ret .. "\t" .. PseudoLua:GenerateInstruction(chunk, instruction) .. "\n";
  end
  return ret;
end

function PseudoLua:GenerateInstruction(chunk, instruct)
  local pseudoInstructions = {
    [5] = function(ins)
      return chunk.constants[ins.Bx].data;
    end,
    [1] = function(ins)
      local x = "";
      local c = chunk.constants[ins.Bx].data;
      if (tonumber(c) ~= nil) then
        x = c;
      else
        x = "'" .. c .. "'";
      end
      return x;
    end,
    [28] = function(ins)
      return "()";
    end,
    [30] = function(ins)
      if (ins.B ~= 1) and (ins.A ~= 0) then
        return "return";
      else
        return "";
      end
    end,
  };
  return pseudoInstructions[instruct.opcode](instruct);
end

return PseudoLua;
