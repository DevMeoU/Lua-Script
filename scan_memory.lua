-- scan_memory.lua
-- Mục đích: Quét bộ nhớ mà một tiến trình cụ thể đang sử dụng, dựa trên PID,
-- và hiển thị thêm các địa chỉ truy cập RAM (memory mappings) cho Linux.
-- Hỗ trợ cả Linux và Windows.

-- Xác định hệ điều hành (Windows hay không)
local is_windows = package.config:sub(1,1) == '\\'

-- Hàm đọc nội dung của một file
local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Không thể mở file " .. path
    end
    local content = file:read("*a")
    file:close()
    return content
end

-- Hàm phân tích nội dung file status thành bảng thông tin (Linux)
local function parse_memory_info(content)
    local memory_info = {}
    for line in content:gmatch("[^\r\n]+") do
        local key, value = line:match("^(%w+):%s+(.*)")
        if key and value then
            memory_info[key] = value
        end
    end
    return memory_info
end

-- Hàm quét thông tin bộ nhớ trên Linux (từ /proc/[PID]/status)
local function scan_memory_linux(pid)
    local path = "/proc/" .. pid .. "/status"
    local content, err = read_file(path)
    if not content then
        print("Lỗi: " .. err)
        return
    end

    local mem_info = parse_memory_info(content)
    print("Thông tin bộ nhớ cho PID " .. pid .. ":")
    if mem_info["VmSize"] then
        print("  VmSize: " .. mem_info["VmSize"])
    end
    if mem_info["VmRSS"] then
        print("  VmRSS: " .. mem_info["VmRSS"])
    end
end

-- Hàm quét địa chỉ truy cập RAM trên Linux (từ /proc/[PID]/maps)
local function scan_memory_addresses_linux(pid)
    local path = "/proc/" .. pid .. "/maps"
    local content, err = read_file(path)
    if not content then
        print("Lỗi khi đọc địa chỉ truy cập RAM: " .. err)
        return
    end

    print("\nĐịa chỉ truy cập RAM (Memory Mappings) cho PID " .. pid .. ":")
    print(content)
end

-- Hàm quét thông tin bộ nhớ trên Windows sử dụng lệnh tasklist
local function scan_memory_windows(pid)
    local command = 'tasklist /FI "PID eq ' .. pid .. '" /FO CSV /NH'
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    if result == "" then
        print("Không tìm thấy tiến trình với PID " .. pid)
        return
    end
    -- Kết quả theo định dạng CSV: "Image Name","PID","Session Name","Session#","Mem Usage"
    local image, pid_str, session_name, session_num, mem_usage = result:match('"(.-)","(.-)","(.-)","(.-)","(.-)"')
    if image then
        print("Thông tin bộ nhớ cho PID " .. pid_str .. ":")
        print("  Image: " .. image)
        print("  Mem Usage: " .. mem_usage)
    else
        print("Không thể phân tích thông tin bộ nhớ: " .. result)
    end

    -- Hiển thị thông báo cho chức năng địa chỉ truy cập RAM
    print("\nChức năng hiển thị địa chỉ truy cập RAM không được hỗ trợ trên Windows.")
end

-- Kiểm tra tham số dòng lệnh (PID)
if #arg < 1 then
    print("Sử dụng: lua scan_memory.lua [PID]")
    os.exit(1)
end

local pid = arg[1]

if is_windows then
    print("Hệ điều hành đang sử dụng: Windows")
    scan_memory_windows(pid)
else
    print("Hệ điều hành đang sử dụng: Linux/Unix")
    scan_memory_linux(pid)
    scan_memory_addresses_linux(pid)
end
