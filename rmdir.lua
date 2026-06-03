local stat = require("posix.sys.stat")
local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local errno = require("posix.errno")

local opt_verbose = false
local opt_parents = false
local ignore_fail = false

local function print_help()
local help_text =[[
    Kullanım: rmdir [SEÇENEK]... DİZİN...
    Boşlarsa DİZİN(LER)'i kaldır.

    --ignore-fail-on-non-empty
    ignore each failure to remove a non-empty directory
    -p, --parents
    remove DIRECTORY and its ancestors;
    e.g., 'rmdir -p a/b' is similar to 'rmdir a/b a'
    -v, --verbose
    output a diagnostic for every directory processed
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
                unistd.write(unistd.STDOUT_FILENO, "rmdir:lua Version 1.0\n")
                os.exit(0)
                elseif arg[i] == "-v" or arg[i] == "--verbose" then
                    opt_verbose = true
                    i = i + 1
                    elseif arg[i] == "-p" or arg[i] == "--parents" then
                    opt_parents = true
                        i = i + 1
                        elseif arg[i] == "--ignore-fail-on-non-empty" then
                            ignore_fail = true
                            i  = i + 1
                        else
                                if string.sub(arg[i], 1, 1) == "-" and #arg[i] > 1 then
                                    unistd.write(unistd.STDERR_FILENO, "rmdir: geçersiz seçenek -- '" .. arg[i] .. "'\n")
                                    unistd.write(unistd.STDERR_FILENO, "Daha fazla bilgi için 'rmdir --help' deneyin.\n")
                                    os.exit(1)
                                else
                                table.insert(dirs, arg[i])
                                i = i + 1
                                end
                                end
                                end

if #dirs == 0 then
    unistd.write(unistd.STDERR_FILENO, "rmdir: eksik işlenen\nDaha fazla bilgi için 'rmdir --help' deneyin.\n")
    os.exit(1)
    end

    for i = 1, #dirs do
        if opt_parents then
            local current_path = dirs[i]
                while current_path ~= nil and current_path ~= "" and current_path ~= "/" do
                    local success,err,errnum = unistd.rmdir(current_path)

                        if success then
                            if opt_verbose then
                                unistd.write(unistd.STDOUT_FILENO, "rmdir: removed directory: " .. current_path .. "\n")
                                end
                        else
                                    if  ignore_fail and errnum == errno.ENOTEMPTY then
                                        break
                                        else
                                        unistd.write(unistd.STDERR_FILENO, "rmdir: Error:" .. " " .. err .. "\n")

                                        break


                                    end
                        end
                                     current_path = string.match(current_path, "(.+)/[^/]+$")
                 end

                                            else
                                                local success,err,errnum = unistd.rmdir(dirs[i])
                                                if not success then
                                                    if not (ignore_fail and errnum == errno.ENOTEMPTY) then
                                                    unistd.write(unistd.STDERR_FILENO, "rmdir: Error:" .. " " .. err .. "\n")
                                                    end

                                                    else

                                                        if opt_verbose then
                                                            unistd.write(unistd.STDOUT_FILENO, "rmdir: removed directory: " .. dirs[i] .. "\n")
                                                            end
                                                            end
end
end
