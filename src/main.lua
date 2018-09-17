local ChunkDecoder = {
    cIdx = 0;
    iIdx = 0;
    bytecode = {
		[0] = {N="MOVE", Args={"A", "B"}};
		[1] = {N="LOADK", Args={"A", "Bx"}};
		[2] = {N="LOADBOOL", Args={"A", "B", "C"}};
		[3] = {N="LOADNIL", Args={"A", "B"}};
		[4] = {N="GETUPVAL", Args={"A", "B"}};
		[5] = {N="GETGLOBAL", Args={"A", "Bx"}};
		[6] = {N="GETTABLE", Args={"A", "B", "C"}};
		[7] = {N="SETGLOBAL", Args={"A", "Bx"}};
		[8] = {N="SETUPVAL", Args={"A", "B"}};
		[9] = {N="SETTABLE", Args={"A", "B", "C"}};
		[10] = {N="NEWTABLE", Args={"A", "B", "C"}};
		[11] = {N="SELF", Args={"A", "B", "C"}};
		[12] = {N="ADD", Args={"A", "B", "C"}};
		[13] = {N="SUB", Args={"A", "B", "C"}};
		[14] = {N="MUL", Args={"A", "B", "C"}};
		[15] = {N="DIV", Args={"A", "B", "C"}};
		[16] = {N="MOD", Args={"A", "B", "C"}};
		[17] = {N="POW", Args={"A", "B", "C"}};
		[18] = {N="UNM", Args={"A", "B"}};
		[19] = {N="NOT", Args={"A", "B"}};
		[20] = {N="LEN", Args={"A", "B"}};
		[21] = {N="CONCAT", Args={"A", "B", "C"}};
		[22] = {N="JMP", Args={"sBx"}};
		[23] = {N="EQ", Args={"A", "B", "C"}};
		[24] = {N="LT", Args={"A", "B", "C"}};
		[25] = {N="LT", Args={"A", "B", "C"}};
		[26] = {N="TEST", Args={"A", "C"}};
		[27] = {N="TESTSET", Args={"A", "B", "C"}};
		[28] = {N="CALL", Args={"A", "B", "C"}};
		[29] = {N="TAILCALL", Args={"A", "B", "C"}};
		[30] = {N="RETURN", Args={"A", "B"}};
		[31] = {N="FORLOOP", Args={"A", "sBx"}};
		[32] = {N="FORPREP", Args={"A", "sBx"}};
		[33] = {N="TFORLOOP", Args={"A", "C"}};
		[34] = {N="SETLIST", Args={"A", "B", "C"}};
		[35] = {N="CLOSE", Args={"A"}};
		[36] = {N="CLOSURE", Args={"A", "Bx"}};
		[37] = {N="VARARG", Args={"A", "B"}};
    };
};

function ChunkDecoder:GetSignature(chunk)
    local sig = "";
    if (ChunkDecoder.cIdx == 1) then
        sig = sig .. " main (";
    else
        sig = sig .. "function (";
    end
    local IC = 0;
    local PC = 0;
    pcall(function()
        for x,y in pairs(chunk.instructions) do
            IC = IC + 1;
        end
        for x,y in pairs(chunk.prototypes) do
            PC = PC + 1;
        end
    end)
    sig = sig .. "[IC: " .. IC .. "]:[PC: " .. PC .. "]:[ADDR: " .. string.gsub(tostring(chunk), "table: ", "") .. "])";
    return sig;
end

function ChunkDecoder:DecodeChunk(chunk)
    ChunkDecoder.cIdx = ChunkDecoder.cIdx + 1;
    print(ChunkDecoder:GetSignature(chunk));
    pcall(function()
        for _,instruction in pairs(chunk.instructions) do
            ChunkDecoder.iIdx = ChunkDecoder.iIdx + 1;
            ChunkDecoder:DecodeInstruction(chunk, ChunkDecoder.iIdx, instruction);
        end
    end)
    ChunkDecoder.iIdx = 0;
end

function ChunkDecoder:GetArgs(instruction, instructionData)
	local Args = "";
	if instructionData.N == "SETTABLE" then
		for _,arg in pairs(instructionData.Args) do
			if arg == "B" then
				Args = Args .. instruction[arg] - 256 .. " ";
			else
				if arg == "C" then
					if instruction[arg] > 255 then
						Args = Args .. instruction[arg] - 256 .. " ";
					else
						Args = Args .. instruction[arg] .. " ";
					end
				else
					Args = Args .. instruction[arg] .. " ";
				end
			end
		end
	elseif instructionData.N == "GETTABLE" then
		for _,arg in pairs(instructionData.Args) do
			if (arg == "C") then
				Args = Args .. instruction[arg] - 256 .. " ";
			else
				Args = Args .. instruction[arg] .. " ";
			end
		end
	elseif instructionData.N == "TAILCALL" then
		for _,arg in pairs(instruction.Args) do
			if (arg == "C") then
				Args = Args .. instruction[arg] - 256 .. " ";
			else
				Args = Args .. instruction[arg] .. " ";
			end
		end
	else
		for _,arg in pairs(instructionData.Args) do
			Args = Args .. instruction[arg] .. " ";
		end
	end
	return Args;
end

function ChunkDecoder:DecodeInstruction(chunk, iIdx, instruction)
    local instruct = iIdx .. "	[" .. instruction.opcode .. "]	";
	local opcode = instruction.opcode;
	local name;

	local instructionData = ChunkDecoder.bytecode[opcode];

	local success, err = pcall(function()
		name = instructionData.N;
		instruct = instruct .. name .. "	";
		if name == "GETGLOBAL" then
			instruct = instruct .. ChunkDecoder:GetArgs(instruction, instructionData);
			instruct = instruct .. "	; " .. chunk.constants[instruction.Bx].data;
		elseif name == "LOADK" then
			local key = chunk.constants[instruction.Bx].data;
			if (tonumber(key) ~= nil) then else key = '"' .. key .. '"' end
			instruct = instruct .. ChunkDecoder:GetArgs(instruction, instructionData);
			instruct = instruct .. "	; " .. key;
		elseif name == "CLOSURE" then
			local key = string.upper(string.gsub(tostring(chunk.prototypes[instruction.Bx]), 'table: ', ''));
			key = string.gsub(key, "X", '0');
			instruct = instruct .. ChunkDecoder:GetArgs(instruction, instructionData);
			instruct = instruct .. "	; " .. key;
		elseif name == "SETGLOBAL" then
			instruct = instruct .. ChunkDecoder:GetArgs(instruction, instructionData);
			instruct = instruct .. "	; " .. chunk.constants[instruction.Bx].data;
		elseif name == "JMP" then
			local jmp = iIdx + instruction.sBx + 1; -- Adds 1 for the current instruction lol
			instruct = instruct .. ChunkDecoder:GetArgs(instruction, instructionData);
			instruct = instruct .. "	; --> to " .. jmp;
		else
			instruct = instruct .. ChunkDecoder:GetArgs(instruction, instructionData);
		end
	end)
	if err then
		instruct = instruct .. "; Error Decoding Instruction";
	end
    print(instruct);
end
