-- show_full_info.lua
-- Script này hiển thị đầy đủ thông tin của các tiến trình trên hệ thống.
-- Trên Windows: sử dụng lệnh "tasklist /FO CSV /V"
-- Trên Linux/Unix: sử dụng lệnh "ps -eo pid,ppid,user,pcpu,pmem,stime,tty,time,cmd"

-- Xác định hệ điều hành (nếu phân cách đường dẫn là "\\" thì là Windows)
local is_windows = package.config:sub(1,1) == "\\"

if is_windows then
    -- Windows: sử dụng lệnh tasklist với định dạng CSV và chế độ chi tiết (/V)
    local handle = io.popen('tasklist /FO CSV /V')
    if not handle then
        print("Lỗi: Không thể chạy lệnh tasklist.")
        os.exit(1)
    end

    print("Thông tin đầy đủ của các tiến trình trên Windows:\n")
    local headerPrinted = false
    for line in handle:lines() do
        -- Mỗi dòng ở định dạng CSV: "Image Name","PID","Session Name","Session#","Mem Usage","Status","User Name","CPU Time","Window Title"
        local fields = {}
        for field in line:gmatch('"(.-)"') do
            table.insert(fields, field)
        end

        if not headerPrinted then
            print("Headers:")
            print("Image Name, PID, Session Name, Session#, Mem Usage, Status, User Name, CPU Time, Window Title")
            print("--------------------------------------------------------------------------")
            headerPrinted = true
        else
            print("Image Name:   " .. fields[1])
            print("PID:          " .. fields[2])
            print("Session Name: " .. fields[3])
            print("Session#:     " .. fields[4])
            print("Mem Usage:    " .. fields[5])
            print("Status:       " .. fields[6])
            print("User Name:    " .. fields[7])
            print("CPU Time:     " .. fields[8])
            print("Window Title: " .. fields[9])
            print("--------------------------------------------------------------------------")
        end
    end
    handle:close()
else
    -- Linux/Unix: sử dụng lệnh ps để hiển thị các cột thông tin chi tiết
    local cmd = "ps -eo pid,ppid,user,pcpu,pmem,stime,tty,time,cmd"
    local handle = io.popen(cmd)
    if not handle then
        print("Lỗi: Không thể chạy lệnh ps.")
        os.exit(1)
    end

    print("Thông tin đầy đủ của các tiến trình trên Linux/Unix:\n")
    for line in handle:lines() do
        print(line)
    end
    handle:close()
end
