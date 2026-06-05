local unistd = require("posix.unistd")
local stat = require("posix.sys.stat")
local dirent = require("posix.dirent")

local opt_verbose = false
local opt_interactive = false
local opt_force = false
local opt_recursive = false


local function print_help()
local help_text =[[
    Kullanım: rm [SEÇENEK]... [DOSYA]...
    DOSYA'(lar)ı kaldır (bağını kopar).

    -f, --force           var olmayan dosyaları/argümanları yok say, asla sorma
    -i                    her kaldırma öncesi sor
    --interactive[=WHEN]
    prompt according to WHEN: never, once (-I), or always (-i);
    without WHEN, prompt always
    -r, -R, --recursive
    remove directories and their contents recursively
    -v, --verbose
    explain what is being done
    --help
    display this help and exit
    --version
    output version information and exit


Öntanımlı olarak, rm dizinleri kaldırmaz. Listelenen her dizini, içeriği ile
birlikte kaldırmak için --recursive (-r veya -R) seçeneğini kullanın.

Any attempt to remove a file whose last file name component is '.' or '..'
is rejected with a diagnostic.

Adı '-' ile başlayan bir dosyayı kaldırmak için, örneğin '-foo',
aşağıdaki komutlardan birini kullanın:
rm -- -foo

rm ./-foo

If you use rm to remove a file, it might be possible to recover
some of its contents, given sufficient expertise and/or time.  For greater
assurance that the contents are unrecoverable, consider using shred(1).


]]

unistd.write(unistd.STDOUT_FILENO, help_text .. "\n")
os.exit(0)
end

local function remove_recursive(path)
    local files, err = dirent.dir(path)
    if not files then
        return false, err
    end

    for _, entry in ipairs(files) do
        if entry ~= "." and entry ~= ".." then
            local full_path = path .. "/" .. entry
            local info = stat.stat(full_path)

            if info then
                if stat.S_ISDIR(info.st_mode) then
                    local success, r_err = remove_recursive(full_path)
                    if not success then return false, r_err end

                else

                    local success, u_err = unistd.unlink(full_path)
                    if not success then return false, u_err end
                        if opt_verbose then
                            unistd.write(unistd.STDOUT_FILENO, "rm: removed file:" .. full_path .. "\n")
                        end
                    end
            end
        end
    end
    local success, rm_err = unistd.rmdir(path)
    if not success then return false, rm_err end
    if opt_verbose then
        unistd.write(unistd.STDOUT_FILENO, "rm: removed directory: '" .. path .. "'\n")
    end
    return true
end
local targets = {}
local i = 1
local letter = ""



while i <= #arg do
    if arg[i] == "--help" then
        print_help()
        os.exit(0)
        elseif arg[i] == "--version" then
            unistd.write(unistd.STDOUT_FILENO, "rm:lua Version 1.0\n")
            os.exit(0)
            elseif arg[i] == "--verbose" then
                opt_verbose = true
                i = i + 1
                elseif arg[i] == "--parents" then
                    opt_parents = true
                    i = i + 1
                    elseif arg[i] == "--interactive"  then
                        opt_interactive = true
                        i = i + 1
                        else
                            if string.sub(arg[i], 1, 1) == "-" and #arg[i] > 1 then
                                for letter in string.gmatch(string.sub(arg[i], 2), ".") do
                                    if letter == "r" or letter == "R" then
                                        opt_recursive = true
                                        elseif letter == "f" then
                                            opt_force = true
                                            elseif letter == "i" then
                                                opt_interactive = true
                                                elseif letter == "v" then
                                                    opt_verbose = true

                                                else
                                                    unistd.write(unistd.STDERR_FILENO, "rm: geçersiz seçenek: -- '" .. letter .. "'\n")
                                                    end
                                                end

                                                i = i + 1
                                else
                                    table.insert(targets, arg[i])
                                    i = i + 1
                                end
                            end

end

if #targets == 0 then
    unistd.write(unistd.STDERR_FILENO, "rm: eksik işlenen\nDaha fazla bilgi için 'rm --help' deneyin.\n")
    os.exit(1)
    end
for i = 1, #targets do
    local info = stat.stat(targets[i])
        if info == nil then
            if not opt_force then
                unistd.write(unistd.STDERR_FILENO, "rm : '" .. targets[i] .. "' cant be removed: No such file or directory" .. "\n")
            end
        else
            local is_dir = stat.S_ISDIR(info.st_mode)
            if is_dir then
                if not opt_recursive then
                    unistd.write(unistd.STDERR_FILENO, "rm: '" .. targets[i] .. "couldnt be removed: Is a directory " .. "\n")

                else

                    local success, err = remove_recursive(targets[i])
                    if not success and not opt_force then
                        unistd.write(unistd.STDERR_FILENO, "rm: '" .. targets[i] .. "' couldnt be removed:" .. err .. "\n")
                    end
                end

                else
                    local success, err = unistd.unlink(targets[i])
                    if success then
                        if opt_verbose then
                            unistd.write(unistd.STDOUT_FILENO, "rm: Removed : '" .. targets[i] .. "'\n")
                                end
                                else
                                    if not opt_force then
                                         unistd.write(unistd.STDERR_FILENO, "rm : '" .. targets[i] .. "' cant be removed" .. err .. "\n")
                                    end
                                end
                end
        end
end
