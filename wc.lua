local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local total_lines = 0
local total_words = 0
local total_bytes = 0


local lines = 0
local words = 0
local bytes = 0
local in_word = false
local current_len = 0
local max_len = 0
local max_len_doc = 0

local function print_help()
    local help_text = [[
Kullanım: wc [SEÇENEK]... DOSYA
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  A word is a nonempty sequence of non white
space delimited by white space characters or by start or end of input.

-c, --bytes            bayt sayımını yazdır
-m, --chars            karakter sayımını yazdır

-l, --lines            yenisatır sayımını yazdır

-h, --help
display this help and exit


-v, --version
output version information and exit

    ]]
    unistd.write(unistd.STDOUT_FILENO, help_text)
    os.exit(0)
end



local function process_file(filename)
if filename == "-" then
    fd = unistd.STDIN_FILENO
    else
        fd, err = fcntl.open(filename, fcntl.O_RDONLY)
        if not fd then
            print("wc: Error:" .. err)
            return
            end
            end

local chunk = unistd.read(fd, 4096)


while chunk and #chunk > 0 do
    bytes = bytes + #chunk



    for  i = 1, #chunk do

        local c = string.sub(chunk, i, i)
            if c == "\n" then
                lines = lines + 1
            end

            if c == " " or c == "\t" or c == "\n" then
                in_word = false

                elseif not in_word then
                    words = words + 1
                    in_word = true
                    end

    end

    chunk = unistd.read(fd, 4096)
    end
    if fd ~= unistd.STDIN_FILENO then
    unistd.close(fd)
    end
end

local opt_lines = false
local opt_words = false
local opt_bytes = false
local files = {}

for i = 1, #arg do




    if arg[i] == "-c" or arg[i] == "--bytes" then
        opt_bytes = true

    elseif arg[i] == "-m" or arg[i] == "--chars" then
        opt_words = true

    elseif arg[i] == "-l" or arg[i] == "--lines" then
        opt_lines = true

    elseif arg[i] == "-v" or arg[i] == "--version" then
        unistd.write(unistd.STDOUT_FILENO, "wc:lua v1.0" .. "\n")
        os.exit(0)
    elseif arg[i] == "-h" or arg[i] == "--help" then
    print_help()
    os.exit(0)
    else
        table.insert(files, arg[i])
    end



end
if opt_bytes == false and opt_lines == false and opt_words == false then
    opt_lines = true
    opt_words = true
    opt_bytes = true
    end

for i = 1, #files  do
    lines = 0
    words = 0
    bytes = 0
    in_word = false
    process_file(files[i])





    total_lines = total_lines + lines

    total_words = total_words + words

    total_bytes = total_bytes + bytes


    local output = ""

    if opt_lines == true then

        output = output .. " " .. lines

        end

        if opt_words == true then

            output = output .. " " .. words

            end

            if opt_bytes == true then

                output = output .. " " .. bytes

                end



                output = output .. " " .. files[i] .. "\n"

                unistd.write(unistd.STDOUT_FILENO, output)

                end
local sum = ""
if #files > 1 then
    if opt_lines == true then sum = sum .. " " .. total_lines
        end
    if opt_words == true then sum = sum .. " " .. total_words
        end
    if opt_bytes == true then sum = sum .. " " .. total_bytes
        end
    sum = sum .. " " .. "total\n"
    unistd.write(unistd.STDOUT_FILENO, sum)
end

