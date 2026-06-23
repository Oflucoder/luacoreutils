local ffi = require(ffi)

ffi.cdef[[
    typedef long ssize_t;

    int open(const char *pathname, int flags, ...)
    ssize_t read(int fd, void *buf, ssize_t count)
    int close(int fd);
    int unlink(const char *pathname)
]]

local O_RDONLY = 0
local O_WRONLY = 1
local O_CREAT = 64
local O_TRUNC = 512
local S_IRUSR_IWUSR = 384

