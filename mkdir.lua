local stat = require("posix.sys.stat")
local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local default_mode = "0o755"
local mode = 0

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
    unistd.write(unistd.STDOUT_FILENO, help_text)
    os.exit(0)
    end
local dirs = {}
local i = 1

while i <= #arg do
    if arg[i] == "-h" or arg[i] == "--help" then
        print_help()
        os.exit(0)
        elseif arg[i] == "-v" or arg[i] == "--version" then
            unistd.write(unistd.STDOUT_FILENO, "mkdir:lua Version1.0")
            os.exit(0)
                elseif arg[i] == "-m" or arg[i] == "--mode" then
                    mode = tonumber(arg[i+1], 8)
                    i = i + 2
                    else

                        table.insert(dirs, arg[i])
                        i = i + 1
                        end
                        end
if mode == 0 then
    mode = default_mode
end

for


