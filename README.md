# ChunkDecompiler
A Lua Chunk Decompiler for https://github.com/JustAPerson/lbi/blob/master/src/lbi.lua

## How It Works
When JustAPerson's Lua Bytecode Interpreter decodes a chunk, it will decode all the instructions, prototypes, constants, etc.
Using this information if we hook a function onto decode_chunk before it returns the decoded chunk.
We can output the lua bytecode instructions, as good as we can. (Referencing to can't do anything without stack)

## Results

### ChunkDecompiler (Current As Of 9/22/18)
```
 main[NUPV 0, NARG 2, PC 0, IC 3, CC 0, FLIN 7]
0x1     [12]    add             2 0 1
0x2     [30]    return          2 2
0x3     [30]    return          0 1

chunk[NUPV 0, NARG 0, PC 0, IC 12, CC 3, FLIN 5]
0x1     [1]     loadk           0 0     ; 1.1125369292536e-308
0x2     [36]    closure         1 0     ; 00A341A8
0x3     [7]     setglobal       1 1     ; add
0x4     [23]    eq              0 0 2
0x5     [22]    jmp             6       ; Jump to Address 0xC
0x6     [5]     getglobal       1 3     ; print
0x7     [5]     getglobal       2 1     ; add
0x8     [1]     loadk           3 2     ; 2
0x9     [1]     loadk           4 2     ; 2
0xA     [28]    call            2 3 0
0xB     [28]    call            1 0 1
0xC     [30]    return          0 1
```

### ChunkDecompiler PseudoLua (Current As Of 9/21/18)
```lua
[0]     .function(arg0, arg1)
[1]             .add v0 + v1
[2]             .return
[3]     .end


[0]     .function()
[1]             .local v0 = 1.1125369292536e-308
[2]             .set[closure] 00ABE9F8
[3]             .add = stack[R(A)]
[4]             .if (0 == 2) ~= 0 goto line: 6
[5]             .goto line: 12
[6]             .get print
[7]             .get add
[8]             .local v3 = 2
[9]             .local v4 = 2
[10]            .call(2)
[11]            .call(args)
[12]    .end
```
