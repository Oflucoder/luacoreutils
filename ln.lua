local unistd = require("posix.unistd")

local opt_symbolic = false
local opt_verbose = false
local opt_force = false
local current_dir = ""

local function print_help()
local help_text =[[
Kullanım: ln [SEÇENEK]... HEDEF
   veya:  ln [SEÇENEK]... HEDEF... DİZİN
   Birinci biçimde, HEDEF'e BAĞ_ADI olan bir bağ oluştur.
   İkinci biçimde, HEDEF'e geçerli dizinde bir bağ oluştur.
   Üçüncü ve dördüncü biçimlerde, DİZİN'deki her bir HEDEF'e bağlar oluştur.
   Öntanımlı olarak sabit bağlar, --symbolic eklenirse sembolik bağlar oluştur.
   Öntanımlı olarak, her hedef (bağ adı) halihazırda var olmamalıdır.
   Sabit bağlar oluştururken her HEDEF var olmalıdır. Sembolik bağlar, isteğe
   bağlı metinler tutabilir; daha sonra çözülürse bir göreli bağ onun üst
   dizini ile ilişkisine göre yorumlanır.

   -f, --force                 önceden var olan hedef dosyaları siler
   -s, --symbolic              sabit bağlar yerine sembolik bağlar oluştur
   -v, --verbose               her bağlantılanan dosyanın adını yazdır
   --help
   display this help and exit
   --version
   output version information and exit
]]


unistd.write(unistd.STDOUT_FILENO, help_text .. "\n")
os.exit(0)
end

local lnargs = {}
local i = 1
local letter = ""

while i <= #arg do
    if arg[i] == "--help" then
        print_help()
        os.exit(0)
        elseif arg[i] == "--version" then
            unistd.write(unistd.STDOUT_FILENO, "ln:lua Version 1.0\n")
            os.exit(0)
            elseif arg[i] == "--verbose" then
                opt_verbose = true
                i = i + 1
                elseif arg[i] == "--symbolic" then
                    opt_symbolic = true
                    i = i + 1
                    elseif arg[i] == "--force"  then
                        opt_force = true
                        i = i + 1
                        else
                            if string.sub(arg[i], 1, 1) == "-" and #arg[i] > 1 then
                                for letter in string.gmatch(string.sub(arg[i], 2), ".") do
                                    if letter == "s" then
                                        opt_symbolic = true
                                        elseif letter == "f" then
                                            opt_force = true
                                            elseif letter == "v" then
                                                opt_verbose = true

                                                    else
                                                        unistd.write(unistd.STDERR_FILENO, "ln: geçersiz seçenek: -- '" .. letter .. "'\n")
                                                        end
                                                        end

                                                        i = i + 1
                                                        else
                                                            table.insert(lnargs, arg[i])
                                                            i = i + 1
                                                            end
                                                            end

                                                            end

if #lnargs == 0 then
    unistd.write(unistd.STDERR_FILENO, "ln: eksik işlenen\nDaha fazla bilgi için 'ln --help' deneyin.\n")
    os.exit(1)
    end

local source = ""
local target = ""

if #lnargs == 1 then
    source = lnargs[1]
    target = lnargs[1]
elseif #lnargs == 2 then
    source = lnargs[1]
    target = lnargs[2]
else
    unistd.write(unistd.STDERR_FILENO, "ln: Too much arguements. (link targets > 2 = WIP)")
    os.exit(1)
end

if opt_force then
    unistd.unlink(target)
end

local success, err = unistd.link(source, target, opt_symbolic)

if not success then
    unistd.write(unistd.STDERR_FILENO, "ln: Error: " .. err .. "\n")
    os.exit(1)
elseif opt_verbose then
    if opt_symbolic then
        unistd.write(unistd.STDOUT_FILENO, "ln: Symbolic link created : " .. source .. target .. "\n")
        else
        unistd.write(unistd.STDOUT_FILENO, "ln: Static link created: " .. source .. target .. "\n")
    end
end
