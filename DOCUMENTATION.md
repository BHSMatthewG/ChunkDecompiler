# Documentation on ChunkDecompiler

## ChunkDecompiler API

### ChunkDecompiler:DecompileInstruction(PC, chunk, instruction)
```lua
-- Converts a Instruction to chunkdec bytecode format

local ChunkDecompiler = require("ChunkDecompiler");

ChunkDecompiler:DecompileInstruction(0, chunk, {
  opcode = 0,
  A = 0,
  B = 1,
  C = nil,
  Bx = nil,
  sBx = nil
});

-- Returns: 0x1     [0]     move            0 1
```

### ChunkDecompiler:DecompileChunk(chunk)
```lua
-- Decompiles the Chunk's instructions using all the resources
-- in the chunk, constants, prototypes, etc.

local ChunkDecompiler = require("ChunkDecompiler");

ChunkDecompiler:DecompileChunk({
  instructions={};
  prototypes={};
  constants={};
  debug={
    debugLines={};
  };
});
-- Returns nothing as there is no instructions in the chunk.
```
