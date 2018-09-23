# Documentation on ChunkDecompiler

## ChunkDecompiler API

### ChunkDecompiler:DecompileInstruction(PC, chunk, instruction)
```lua
-- Converts a Instruction to chunkdec bytecode format

ChunkDecompiler:DecompileInstruction(1, chunk, {
  opcode = 0,
  A = 0,
  B = 1,
  C = nil,
  Bx = nil,
  sBx = nil
});

-- Returns: 0x2     [0]     move            0 1
```
