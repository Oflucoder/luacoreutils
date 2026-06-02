local fcntl = require("posix.fcntl")
local unistd = require("posix.unistd")
local global_buffer = ""
local line_num = 1
local number_lines = false
local show_ends = false
local last_line_blank = false
local squeeze_blank = false
local number_nonblank = false
local show_tabs = false
local files_given = false

local function print_help()
local help_text = [[
    Kullanım: cat.lua [SEÇENEK]... [DOSYA]...
    DOSYA(lar)ı standart çıktıya yaz.

    -E, --show-ends          her satırın sonuna $ ekler
    -n, --number             tüm çıktı satırlarını numarala
    -s, --squeeze-blank      arka arkaya gelen boş satırları bire indirge
    -h, --help               bu yardımı gösterir ve çıkar
    -v, --version            sürüm bilgisini gösterir ve çıkar
    -b  --number-noblank     boş olmayan çıktı satırlarını numaralar. (-n yi geçersiz kılar.)
    -T, --show-tabs          TAB karakterlerini ^I olarak gösterir

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
            print("cat.lua: Error:" .. err)
            return
            end
    end
    local chunk = unistd.read(fd, 1024)
    while chunk and #chunk > 0 do
        chunk = global_buffer .. chunk
        global_buffer = ""
        local current_pos = 1
        while true do

            local start_idx, end_idx = string.find(chunk, "\n", current_pos, true)
            if start_idx == nil then
                global_buffer = string.sub(chunk, current_pos)
                break
                else
                    local line = string.sub(chunk, current_pos, start_idx - 1)
                    local skip_line = false

                    if squeeze_blank and last_line_blank and #line == 0 then
                        skip_line = true
                    end

                    if not skip_line then
                    local print_num = false
                        if show_tabs then
                            line = string.gsub(line, "\t", "^I")
                        end
                        if number_nonblank and #line > 0 then
                            print_num = true
                                elseif number_lines then
                                    print_num = true
                                    end
                        if print_num and show_ends then
                        unistd.write(unistd.STDOUT_FILENO, line_num .. "  " .. line .. "$\n")
                        elseif print_num then
                        unistd.write(unistd.STDOUT_FILENO, line_num .. "  " .. line .. "\n")
                        elseif show_ends then
                        unistd.write(unistd.STDOUT_FILENO, line .. "$\n")
                        else
                        unistd.write(unistd.STDOUT_FILENO, line .. "\n")

                    end
                    if print_num then
                        line_num = line_num +1
                    end

                    end
                    current_pos = end_idx + 1
                    last_line_blank = (#line == 0)
                    end

        chunk = unistd.read(fd, 1024)
    end
    if #global_buffer > 0 then
    local print_num = false
        if show_tabs then
            global_buffer = string.gsub(global_buffer, "\t", "^I")
            end
        if number_nonblank then
            if #global_buffer > 0 then
                print_num = true
                end
        elseif number_lines then
            print_num = true
        end

        if print_num and show_ends then
            unistd.write(unistd.STDOUT_FILENO, line_num .. "  " .. global_buffer .. "$\n")
            elseif print_num then
                unistd.write(unistd.STDOUT_FILENO, line_num .. "  " .. global_buffer .. "\n")
                elseif show_ends then
                    unistd.write(unistd.STDOUT_FILENO, global_buffer .. "$\n")
                    else
                        unistd.write(unistd.STDOUT_FILENO, global_buffer .. "\n")
                        end
                        global_buffer = ""
                        end
 end
 unistd.close(fd)

end


for i = 1, #arg do
    if arg[i] == "-v" then
        print("cat.lua Version 1.0")
        os.exit(0)
        elseif arg[i] == "-n" or arg[i] == "--number" then
            number_lines = true
        elseif arg[i] == "-E" or arg[i] == "--show-ends" then
            show_ends = true
        elseif arg[i] == "-s" or arg[i] == "--squeeze-blank" then
            squeeze_blank = true
        elseif arg[i] == "-b" or arg[i] == "--number-nonblank" then
            number_nonblank = true
        elseif arg[i] == "-T" or arg[i] == "--show-tabs" then
            show_tabs = true
        elseif arg[i] == "-h" or arg[i] == "--help" then
            print_help()
    else
        files_given = true
        process_file(arg[i])
    end
end

if not files_given then
    process_file("-")
end
