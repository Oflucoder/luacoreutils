local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local stat = require("posix.sys.stat")
local atimechgonly = false
local nocreate = false
local mtimechgonly = false

local function print_help()
local help_text =[[
    Kullanım: touch [SEÇENEK]... DOSYA...
    DOSYA'nın erişim ve değiştirilme zamanlarını geçerli zamana güncelle.

    Var olmayan bir DOSYA argümanı boş oluşturulur, -c verilmemişse.

    Bir - DOSYA argümanı dizisine özel olarak davranılır ve touch'ın standar
    çıktı ile ilişkilendirilmiş dosyanın zamanını değiştirmesine neden olur.

    Uzun seçeneklere olan gerekli argümanlar kısa seçenekler için de geçerlidir.
    -a                     yalnızca erişim zamanını değiştir
    -c, --no-create        hiçbir dosya oluşturma
    -m                     yalnızca değiştirilme zamanını değiştir

--help
display this help and exit
--version
output version information and exit
]]
unistd.write(unistd.STDOUT_FILENO, help_text .. "\n")
os.exit(0)
end

local files = {}
local i = 1

while i <= #arg do
    if arg[i] == "-h" or arg[i] == "--help" then
        print_help()
        os.exit(0)
        elseif arg[i] == "--version" then
            unistd.write(unistd.STDOUT_FILENO, "touch:lua Version 1.0\n")
            os.exit(0)
            elseif arg[i] == "-a" then
               atimechgonly = true
                i = i + 1
                elseif arg[i] == "-m"  then
                    mtimechgonly = true
                    i = i + 1
                    elseif arg[i] == "-c" or arg[i] == "--no-create" then
                        nocreate = true
                        i = i + 1
                        else

                            if string.sub(arg[i], 1, 1) == "-" and #arg[i] > 1 then
                                unistd.write(unistd.STDERR_FILENO, "touch: geçersiz seçenek -- '" .. arg[i] .. "'\n")
                                unistd.write(unistd.STDERR_FILENO, "Daha fazla bilgi için 'touch --help' deneyin.\n")
                                os.exit(1)
                                else
                                    table.insert(files, arg[i])
                                    i = i + 1
                        end
end
end

for i = 1, #files do
    local info = stat.stat(files[i])

            if info == nil then
                if not nocreate then
                local fd, err, errnum = fcntl.open(files[i], fcntl.O_CREAT + fcntl.O_WRONLY, 438)
                    if fd then unistd.close(fd) end
                            else
                                unistd.write(unistd.STDERR_FILENO, "touch: '" .. files[i] .. "' Error: File couldnt be created. " .. err .. "\n")
                                end
                                end

    if info then
        local current_time = os.time()
        local success, err, errnum

        if atimechgonly and not mtimechgonly then
            success, err, errnum = stat.utimes(files[i], {
                atime = { tv_sec = current_time, tv_usec = 0},
                mtime = { tv_sec = info.st_mtime , tv_usec = 0}
            })
        elseif mtimechgonly and not atimechgonly then
            success, err, errnum = stat.utimes(files[i], {
                atime = { tv_sec = info.st_atime, tv_usec = 0},
                mtime = { tv_sec = current_time, tv_usec = 0 }
            })
        else
            success, err, errnum = stat.utimes(files[i], nil)
        end
        if not success then
            unistd.write(unistd.STDERR_FILENO, "touch: '" .. files[i] .. "' Time couldnt be updated: " .. err .. "\n")

        end
end
end
