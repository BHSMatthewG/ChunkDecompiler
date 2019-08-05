# ChunkDecompiler
A Lua Chunk Decompiler for https://github.com/JustAPerson/lbi/blob/master/src/lbi.lua

## Notice
this project is extremely outdated and is now being updated under red disassembler.
this project will be archived for future reference but will not be maintained.
i reccomend the use of https://github.com/op0x59/reddisassembler instead.

## How It Works
When JustAPerson's Lua Bytecode Interpreter decodes a chunk, it will decode all the instructions, prototypes, constants, etc.
Using this information if we hook a function onto decode_chunk before it returns the decoded chunk.
We can output the lua bytecode instructions, as good as we can. (Referencing to can't do anything without stack)

## Results

### ChunkDecompiler (Current As Of 9/23/18)
```
; Settings:
; HexAddresses: Enabled
;
 main[NUPV 0, NARG 2, PC 0, IC 3, CC 0, FLIN 7]
0x1     [12]    add             2 0 1
0x2     [30]    return          2 2
0x3     [30]    return          0 1

chunk[NUPV 0, NARG 0, PC 0, IC 12, CC 3, FLIN 5]
.constant       'add'
.constant       2
.constant       'print'
.constant       1.1125369292536e-308


0x1     [1]     loadk           0 0     ; 1.1125369292536e-308
0x2     [36]    closure         1 0     ; 00A71288
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

### ChunkDecompiler PseudoLua (Current As Of 9/23/18)
```lua
--[[
-- Settings:
-- HexAddresses: Enabled
--]]

[0x1]   .function f1(arg0, arg1)
[0x2]           .undefined
[0x3]           .return
[0x4]   .end

[0x1]   .function f2()
[0x2]           .local v0 = 1.1125369292536e-308
[0x3]           .pushclosure 00AA1300
[0x4]           .undefined
[0x5]           .undefined
[0x6]           .jump to 0xD
[0x7]           .get print
[0x8]           .get add
[0x9]           .local v3 = 2
[0xA]           .local v4 = 2
[0xB]           .call()
[0xC]           .call()
[0xD]   .end
```

## Latest Development Log Video
[![Development Log #1](http://img.youtube.com/vi/Lsx5oe4gEdg/0.jpg)](http://www.youtube.com/watch?v=Lsx5oe4gEdg)
