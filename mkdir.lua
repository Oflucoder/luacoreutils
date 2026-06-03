local stat = require("posix.sys.stat")
local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local errno = require("posix.errno")
local default_mode = 493
local mode = 0
local opt_verbose = false
local opt_parents = false
local function print_help()
    local help_text =[[
        Kullanım: mkdir [SEÇENEK]... DİZİN...
        Halihazırda yoklarsa DİZİN'(ler)i oluştur.

        Uzun seçeneklere olan gerekli argümanlar kısa seçenekler için de geçerlidir.
        -m, --mode=KİP    dosya kipini ayarla (chmod gibi), a=rwx - umask değil
        -p, --parents
        no error if existing, make parent directories as needed,
        with their file modes unaffected by any -m option
        -v, --verbose     her oluşturulan dizin için bir ileti yazdır

        --help
        display this help and exit
        --version
        output version information and exit
    ]]
    unistd.write(unistd.STDOUT_FILENO, help_text .. "\n")
    os.exit(0)
    end

local dirs = {}
local i = 1

while i <= #arg do
    if arg[i] == "-h" or arg[i] == "--help" then
        print_help()
        os.exit(0)
        elseif arg[i] == "--version" then
            unistd.write(unistd.STDOUT_FILENO, "mkdir:lua Version 1.0\n")
            os.exit(0)
                elseif arg[i] == "-m" or arg[i] == "--mode" then
                    mode = tonumber(arg[i+1], 8)
                        i = i + 2
                    elseif arg[i] == "-v" or arg[i] == "--verbose" then
                        opt_verbose = true
                        i = i + 1
                        elseif arg[i] == "-p" or arg[i] == "--parents" then
                            opt_parents = true
                            i = i + 1
                    else

                        table.insert(dirs, arg[i])
                        i = i + 1
                        end
                        end

if #dirs == 0 then
    unistd.write(unistd.STDERR_FILENO, "mkdir: eksik işlenen\nDaha fazla bilgi için 'mkdir --help' deneyin.\n")
    os.exit(1)
    end
if mode == 0 then
    mode = default_mode
    end

for i = 1, #dirs do
   if opt_parents then
        local current_path = ""

        if string.sub(dirs[i], 1, 1) == "/" then
            current_path = ""
        end


        for part in string.gmatch(dirs[i], "[^/]+") do
            if current_path == "" and string.sub(dirs[i], 1, 1) ~= "/" then
                current_path = part
            else
                current_path = current_path .. "/" .. part
            end

            local success,err,errnum = stat.mkdir(current_path, mode)
            if success then
                if opt_verbose then
                    unistd.write(unistd.STDOUT_FILENO, "mkdir: created directory: " .. current_path .. "\n")
                end
            else
                if errnum ~= errno.EEXIT then
                    unistd.write(unistd.STDOUT_FILENO, "mkdir: Error:" .. " " .. err .. "\n")
                    break

                end
            end
        end
        else
            local success,err,errnum = stat.mkdir(dirs[i], mode)
                if not success then
                    unistd.write(unistd.STDERR_FILENO, "mkdir: Error:" .. " " .. err .. "\n")
                else
                    if opt_verbose then
                        unistd.write(unistd.STDOUT_FILENO, "mkdir: created directory: " .. dirs[i] .. "\n")
                    end
                end
        end
        end
