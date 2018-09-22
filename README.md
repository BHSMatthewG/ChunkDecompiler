# ChunkDecompiler
A Lua Chunk Decompiler for https://github.com/JustAPerson/lbi/blob/master/src/lbi.lua

## How It Works
When JustAPerson's Lua Bytecode Interpreter decodes a chunk, it will decode all the instructions, prototypes, constants, etc.
Using this information if we hook a function onto decode_chunk before it returns the decoded chunk.
We can output the lua bytecode instructions, as good as we can. (Referencing to can't do anything without stack)

## Results

### ChunkDecompiler (Current As Of 9/21/18)
```
 main ([IC: 3]:[PC: 0]:[ADDR: 00AAE980])
1       [12]    add             2 0 1
2       [30]    return          2 2
3       [30]    return          0 1

function ([IC: 12]:[PC: 1]:[ADDR: 00AAE8E0])
1       [1]     loadk           0 0     ; 1.1125369292536e-308
2       [36]    closure         1 0     ; 00AAE980
3       [7]     setglobal       1 1     ; add
4       [23]    eq              0 0 256
5       [22]    jmp             6       ; --> to 12
6       [5]     getglobal       1 2     ; print
7       [5]     getglobal       2 1     ; add
8       [1]     loadk           3 3     ; 2
9       [1]     loadk           4 3     ; 2
10      [28]    call            2 3 0
11      [28]    call            1 0 1
12      [30]    return          0 1
```

### ChunkDecompiler PseudoLua (Current As Of 9/21/18)
```lua
[0]     .function(arg0, arg1)
[1]             .add v0 + v1
[2]             .return
[3]     .end


[0]     .function()
[1]             .local v0 = 1.1125369292536e-308
[2]             .undefined
[3]             .undefined
[4]             .undefined
[5]             .goto line: 12
[6]             .get print
[7]             .get add
[8]             .local v3 = 2
[9]             .local v4 = 2
[10]            .call(2)
[11]            .call(args)
[12]    .end
```
