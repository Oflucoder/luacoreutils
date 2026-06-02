local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local inputstring = ""
local start_idx = 1
local append_newline = true

local function printing()
    for i = start_idx, #arg do
        unistd.write(unistd.STDOUT_FILENO, arg[i] .. " " .. "\n")

    end
    if append_newline == true then
        unistd.write(unistd.STDOUT_FILENO, "\n")
    end
end
if arg[1] == "-n" then
    start_idx = 2
    append_newline = false
    printing()
else
    printing()
end
