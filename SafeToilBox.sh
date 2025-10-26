#!/system/bin/sh

# 配置文件路径
CONFIG_DIR="/sdcard/FileManagerConfig"
DIRS_FILE="$CONFIG_DIR/custom_dirs.conf"
FILES_FILE="$CONFIG_DIR/created_files.conf"

# 当前版本号
CURRENT_VERSION="1.0"

# 更新链接
UPDATE_URL="https://raw.githubusercontent.com/qingmingmayi/-/refs/heads/SafeTool-Box/SafeToilBox.sh"

# 初始化配置
initialize() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        # 设置新的默认路径
        echo "/storage/emulated/0/Android/data/org.telegram.messenger.web/cache/" > "$DIRS_FILE"
        echo "/data/media/0/Android/data/org.telegram.messenger.web/cache/" >> "$DIRS_FILE"
        echo "/data/media/0/Android/data/org.telegram.messenger/cache/" >> "$DIRS_FILE"
        echo "/storage/emulated/0/Android/data/nekox.messenger/files/caches/" >> "$DIRS_FILE"
        touch "$FILES_FILE"
    fi
}

# 清屏函数（兼容安卓）
clear_screen() {
    printf "\033c"  # ANSI转义序列清屏
}

# 检查更新 - 修复版
check_update() {
    clear_screen
    echo "当前版本: v$CURRENT_VERSION"
    echo "正在检查更新..."
    
    # 创建临时文件
    temp_file="/sdcard/SafeToolBox_update_temp.sh"
    
    # 尝试下载更新脚本（增加超时和重试机制）
    if wget -T 15 -t 2 -O "$temp_file" "$UPDATE_URL" >/dev/null 2>&1; then
        # 从下载的脚本中提取版本号
        new_version=$(grep -m1 "CURRENT_VERSION=" "$temp_file" | cut -d'"' -f2)
        
        if [ -z "$new_version" ]; then
            echo "更新检查失败：无法解析版本信息"
            echo "当前版本: v$CURRENT_VERSION"
        elif [ "$new_version" = "$CURRENT_VERSION" ]; then
            echo "当前已是最新版本 (v$CURRENT_VERSION)"
        else
            echo "发现新版本: v$new_version"
            echo "当前版本: v$CURRENT_VERSION"
            echo -n "是否更新？(y/n): "
            read answer
            
            if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
                # 获取当前脚本路径
                script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
                
                # 覆盖当前脚本
                if mv "$temp_file" "$script_path" 2>/dev/null; then
                    echo "更新成功！请重新运行脚本"
                    exit 0
                else
                    echo "更新失败：无法覆盖当前脚本"
                    echo "请手动下载更新：$UPDATE_URL"
                fi
            else
                echo "已取消更新"
            fi
        fi
    else
        echo "更新检查失败：无法连接服务器或下载超时"
        echo "可能原因："
        echo "1. 网络连接问题"
        echo "2. GitHub访问限制"
        echo "3. 脚本URL变更"
        echo ""
        echo "当前版本: v$CURRENT_VERSION"
        echo "请尝试手动下载更新：$UPDATE_URL"
    fi
    
    # 清理临时文件
    rm -f "$temp_file" 2>/dev/null
    sleep 2
}

# 显示主菜单
show_main_menu() {
    clear_screen
    echo "=============================="
    echo "|        SafeToilBox        |"
    echo "=============================="
    echo "[1] 验证管理"
    echo "[2] 清理配置"
    echo "[3] 系统信息"
    echo "[4] 检查更新"
    echo "[0] 退出脚本"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示文件管理菜单
show_file_management_menu() {
    clear_screen
    echo "=============================="
    echo "|        文件管理菜单        |"
    echo "=============================="
    echo "[1] 目录管理"
    echo "[2] 快速配置"
    echo "[3] 自建配置"
    echo "[4] 删除配置"
    echo "[0] 返回主页"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示目录管理菜单
show_directory_menu() {
    clear_screen
    echo "当前自定义路径:"
    awk '{print NR ". " $0}' "$DIRS_FILE"
    echo ""
    echo "[1] 添加路径"
    echo "[2] 删除路径"
    echo "[3] 预设路径"
    echo "[0] 返回主页"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示文件删除菜单
show_file_deletion_menu() {
    clear_screen
    echo "已生成的文件列表:"
    awk '{print NR ". " $0}' "$FILES_FILE"
    echo ""
    echo "[1] 删除单个文件"
    echo "[2] 删除全部文件"
    echo "[3] 返回上级主页"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示系统信息子菜单
show_system_info_menu() {
    clear_screen
    echo "=============================="
    echo "|        系统信息菜单        |"
    echo "=============================="
    echo "[1] 基础系统信息"
    echo "[2] 详细硬件信息"
    echo "[3] 存储和内存信息"
    echo "[4] 电池和传感器信息"
    echo "[0] 返回主菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示快速配置菜单
show_quick_config_menu() {
    clear_screen
    echo "=============================="
    echo "|        快速配置菜单        |"
    echo "=============================="
    echo "[1] 王者荣耀"
    echo "[2] 英雄联盟"
    echo "[3] 使命召唤"
    echo "[4] 暗区突围"
    echo "[5] 和平精英"
    echo "[6] 三角洲行动"
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示三角洲行动菜单
show_delta_menu() {
    clear_screen
    echo "=============================="
    echo "|        三角洲行动配置      |"
    echo "=============================="
    echo "[1] 林羽"
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 显示林羽配置菜单
show_linyu_menu() {
    clear_screen
    echo "=============================="
    echo "|          林羽配置         |"
    echo "=============================="
    echo "[1] 开启配置"
    echo "[2] 关闭配置"
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
}

# 主循环
main() {
    initialize
    
    while true; do
        show_main_menu
        read choice
        
        case $choice in
            1) file_management ;;
            2) clear_cache ;;
            3) system_info_menu ;;
            4) check_update ;;
            0) exit 0 ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 文件管理子菜单
file_management() {
    while true; do
        show_file_management_menu
        read choice
        
        case $choice in
            1) directory_management ;;
            2) quick_config ;;
            3) file_generation ;;
            4) file_deletion ;;
            0) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 系统信息子菜单
system_info_menu() {
    while true; do
        show_system_info_menu
        read choice
        
        case $choice in
            1) basic_system_info ;;
            2) detailed_hardware_info ;;
            3) storage_memory_info ;;
            4) battery_sensor_info ;;
            0) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 目录管理
directory_management() {
    while true; do
        show_directory_menu
        read choice
        
        case $choice in
            1) 
                echo -n "输入要添加的路径(用空格分隔多个路径): "
                read paths
                for path in $paths; do
                    echo "$path" >> "$DIRS_FILE"
                done
                echo "路径已添加"; sleep 1
                ;;
            2)
                echo "当前路径列表:"
                awk '{print NR ". " $0}' "$DIRS_FILE"
                echo -n "输入要删除的行号［输入0删除所有］:"
                read line
                
                # 处理删除所有路径的情况
                if [ "$line" -eq 0 ] 2>/dev/null; then
                    echo -n "确定要删除所有路径吗？(y/n): "
                    read confirm
                    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                        > "$DIRS_FILE"  # 清空文件
                        echo "所有路径已删除"
                    else
                        echo "操作已取消"
                    fi
                else
                    # 使用临时文件删除行（兼容安卓）
                    awk -v line=$line 'NR != line' "$DIRS_FILE" > "$DIRS_FILE.tmp"
                    mv "$DIRS_FILE.tmp" "$DIRS_FILE"
                    echo "路径已删除"
                fi
                sleep 1
                ;;
            3)
                # 添加新的预设路径
                echo "/storage/emulated/0/Android/data/org.telegram.messenger.web/cache/" >> "$DIRS_FILE"
                echo "/data/media/0/Android/data/org.telegram.messenger.web/cache/" >> "$DIRS_FILE"
                echo "/data/media/0/Android/data/org.telegram.messenger/cache/" >> "$DIRS_FILE"
                echo "/storage/emulated/0/Android/data/nekox.messenger/files/caches/" >> "$DIRS_FILE"
                echo "预设路径已添加"; sleep 1
                ;;
            0) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 文件生成（改进版：添加返回选项）
file_generation() {
    clear_screen
    echo "可用路径列表:"
    awk '{print NR ". " $0}' "$DIRS_FILE"
    echo ""
    
    # 获取路径数量
    dir_count=$(wc -l < "$DIRS_FILE")
    
    # 获取用户选择的路径序号
    while true; do
        echo -n "请选择路径序号 (1-$dir_count, 输入0返回): "
        read dir_num
        
        # 检查输入是否有效
        if [ "$dir_num" -eq 0 ] 2>/dev/null; then
            echo "返回文件管理菜单"
            return
        elif [ "$dir_num" -ge 1 ] && [ "$dir_num" -le "$dir_count" ] 2>/dev/null; then
            break
        else
            echo "无效的序号，请重新输入"
        fi
    done
    
    # 获取选择的路径
    target_dir=$(awk -v line=$dir_num 'NR == line' "$DIRS_FILE")
    
    # 输入文件名
    while true; do
        echo -n "输入文件名(输入0返回): "
        read filename
        
        if [ "$filename" = "0" ]; then
            echo "返回文件管理菜单"
            return
        elif [ -n "$filename" ]; then
            break
        else
            echo "文件名不能为空"
        fi
    done
    
    # 输入文件后缀
    while true; do
        echo -n "输入文件后缀(如 txt/jpg/zip, 输入0返回): "
        read extension
        
        if [ "$extension" = "0" ]; then
            echo "返回文件管理菜单"
            return
        elif [ -n "$extension" ]; then
            break
        else
            echo "文件后缀不能为空"
        fi
    done
    
    # 创建目录（如果不存在）
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # 创建文件
    full_path="${target_dir}/${filename}.${extension}"
    touch "$full_path"
    echo "$full_path" >> "$FILES_FILE"
    
    echo "文件已生成: $full_path"
    sleep 2
}

# 文件删除（改进版：使用序号选择文件）
file_deletion() {
    while true; do
        show_file_deletion_menu
        read choice
        
        case $choice in
            1)
                # 获取文件数量
                file_count=$(wc -l < "$FILES_FILE")
                if [ "$file_count" -eq 0 ]; then
                    echo "没有可删除的文件！"
                    sleep 1
                    continue
                fi
                
                # 获取用户选择的文件序号
                while true; do
                    echo -n "请选择要删除的文件序号 (1-$file_count, 输入0返回): "
                    read file_num
                    
                    # 检查输入是否有效
                    if [ "$file_num" -eq 0 ] 2>/dev/null; then
                        echo "返回文件删除菜单"
                        break 2
                    elif [ "$file_num" -ge 1 ] && [ "$file_num" -le "$file_count" ] 2>/dev/null; then
                        break
                    elif [ -z "$file_num" ]; then
                        echo "输入为空，返回上级菜单"
                        break 2
                    else
                        echo "无效的序号，请重新输入"
                    fi
                done
                
                # 如果输入为空，已经跳出循环
                [ -z "$file_num" ] && continue
                
                # 获取并删除文件
                file_to_delete=$(awk -v line=$file_num 'NR == line' "$FILES_FILE")
                rm -f "$file_to_delete"
                
                # 从文件列表中删除
                awk -v line=$file_num 'NR != line' "$FILES_FILE" > "$FILES_FILE.tmp"
                mv "$FILES_FILE.tmp" "$FILES_FILE"
                
                echo "文件已删除: $file_to_delete"
                sleep 1
                ;;
            2)
                # 获取文件数量
                file_count=$(wc -l < "$FILES_FILE")
                if [ "$file_count" -eq 0 ]; then
                    echo "没有可删除的文件！"
                    sleep 1
                    continue
                fi
                
                # 删除所有文件
                while IFS= read -r file; do
                    rm -f "$file"
                done < "$FILES_FILE"
                
                # 清空文件列表
                > "$FILES_FILE"
                
                echo "所有文件已删除"
                sleep 1
                ;;
            3) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 快速配置菜单
quick_config() {
    while true; do
        show_quick_config_menu
        read choice
        
        case $choice in
            1) honor_of_kings ;;
            2) league_of_legends ;;
            3) call_of_duty ;;
            4) dark_zone ;;
            5) peace_elite ;;
            6) delta_action ;;
            0) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 王者荣耀配置
honor_of_kings() {
    clear_screen
    echo "王者荣耀配置"
    echo "功能开发中..."
    echo ""
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
    read choice
    if [ "$choice" = "0" ]; then
        return
    fi
}

# 英雄联盟配置
league_of_legends() {
    clear_screen
    echo "英雄联盟配置"
    echo "功能开发中..."
    echo ""
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
    read choice
    if [ "$choice" = "0" ]; then
        return
    fi
}

# 使命召唤配置
call_of_duty() {
    clear_screen
    echo "使命召唤配置"
    echo "功能开发中..."
    echo ""
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
    read choice
    if [ "$choice" = "0" ]; then
        return
    fi
}

# 暗区突围配置
dark_zone() {
    clear_screen
    echo "暗区突围配置"
    echo "功能开发中..."
    echo ""
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
    read choice
    if [ "$choice" = "0" ]; then
        return
    fi
}

# 和平精英配置
peace_elite() {
    clear_screen
    echo "和平精英配置"
    echo "功能开发中..."
    echo ""
    echo "[0] 返回上级菜单"
    echo "=============================="
    echo -n "请输入选项数字: "
    read choice
    if [ "$choice" = "0" ]; then
        return
    fi
}

# 三角洲行动配置
delta_action() {
    while true; do
        show_delta_menu
        read choice
        
        case $choice in
            1) linyu_config ;;
            0) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 林羽配置
linyu_config() {
    while true; do
        show_linyu_menu
        read choice
        
        case $choice in
            1) enable_linyu ;;
            2) disable_linyu ;;
            0) return ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 启用林羽配置
enable_linyu() {
    # 默认路径
    target_dir="/data/media/0/Android/data/org.telegram.messenger.web/cache/"
    
    # 创建目录（如果不存在）
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # 创建文件
    file1="${target_dir}--6089395591818886111_97.jpg"
    file2="${target_dir}-6089395591818886111_99.jpg"
    
    touch "$file1"
    touch "$file2"
    
    # 添加到文件列表
    echo "$file1" >> "$FILES_FILE"
    echo "$file2" >> "$FILES_FILE"
    
    echo "林羽配置已开启"
    sleep 1
}

# 禁用林羽配置
disable_linyu() {
    # 默认路径
    target_dir="/data/media/0/Android/data/org.telegram.messenger.web/cache/"
    
    # 文件路径
    file1="${target_dir}--6089395591818886111_97.jpg"
    file2="${target_dir}-6089395591818886111_99.jpg"
    
    # 删除文件
    rm -f "$file1"
    rm -f "$file2"
    
    # 从文件列表中移除
    grep -v "$file1" "$FILES_FILE" > "$FILES_FILE.tmp"
    mv "$FILES_FILE.tmp" "$FILES_FILE"
    
    grep -v "$file2" "$FILES_FILE" > "$FILES_FILE.tmp"
    mv "$FILES_FILE.tmp" "$FILES_FILE"
    
    echo "林羽配置已关闭"
    sleep 1
}

# 清理缓存
clear_cache() {
    rm -rf "$CONFIG_DIR"
    echo "所有配置和缓存已清除"
    sleep 1
}

# 基础系统信息
basic_system_info() {
    clear_screen
    echo "===== 基础系统信息 ====="
    echo "设备型号: $(getprop ro.product.model)"
    echo "设备品牌: $(getprop ro.product.brand)"
    echo "设备代号: $(getprop ro.product.device)"
    echo "制造商: $(getprop ro.product.manufacturer)"
    echo "产品名称: $(getprop ro.product.name)"
    echo "安卓版本: $(getprop ro.build.version.release)"
    echo "API级别: $(getprop ro.build.version.sdk)"
    echo "安全补丁: $(getprop ro.build.version.security_patch)"
    echo "内核版本: $(uname -r)"
    echo "系统架构: $(getprop ro.product.cpu.abi)"
    echo "构建编号: $(getprop ro.build.display.id)"
    echo "构建类型: $(getprop ro.build.type)"
    echo "构建用户: $(getprop ro.build.user)"
    echo "构建时间: $(getprop ro.build.date)"
    echo "序列号: $(getprop ro.serialno)"
    echo "开机时间: $(uptime -s)"
    echo "运行时间: $(uptime | cut -d' ' -f4- | sed 's/,.*//')"
    echo "========================="
    echo -n "按回车键返回..."
    read
}

# 详细硬件信息
detailed_hardware_info() {
    clear_screen
    echo "===== 详细硬件信息 ====="
    
    # CPU信息
    echo "CPU架构: $(getprop ro.product.cpu.abi)"
    echo "CPU核心数: $(grep -c processor /proc/cpuinfo)"
    echo "CPU型号: $(grep 'Hardware' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')"
    echo "CPU频率: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null | awk '{print $1/1000 " MHz"}' || echo "未知")"
    echo "CPU温度: $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000 "°C"}' || echo "未知")"
    
    # GPU信息
    echo "GPU渲染器: $(getprop ro.hardware)"
    echo "GPU供应商: $(getprop ro.opengles.version)"
    
    # 内存控制器
    echo "内存控制器: $(getprop ro.chipname)"
    
    # 硬件特性
    echo "硬件特性: $(getprop ro.hardware.features)"
    
    # 屏幕信息
    if [ -f "/sys/class/graphics/fb0/virtual_size" ]; then
        screen_size=$(cat /sys/class/graphics/fb0/virtual_size)
        echo "屏幕分辨率: ${screen_size//,/x}"
    fi
    
    if [ -f "/sys/class/graphics/fb0/physical_size" ]; then
        physical_size=$(cat /sys/class/graphics/fb0/physical_size)
        echo "物理尺寸: ${physical_size//,/x} mm"
    fi
    
    # 触摸屏信息
    if [ -d "/proc/bus/input/devices" ]; then
        touchscreen=$(grep -A5 -i touchscreen /proc/bus/input/devices | grep -i name | head -1 | cut -d'=' -f2)
        echo "触摸屏: $touchscreen"
    fi
    
    echo "========================="
    echo -n "按回车键返回..."
    read
}

# 存储和内存信息
storage_memory_info() {
    clear_screen
    echo "===== 存储和内存信息 ====="
    
    # 内存详细信息
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    mem_buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
    mem_cached=$(grep -w Cached /proc/meminfo | awk '{print $2}')
    
    echo "内存总量: $((mem_total / 1024)) MB"
    echo "空闲内存: $((mem_free / 1024)) MB"
    echo "可用内存: $((mem_avail / 1024)) MB"
    echo "缓冲区: $((mem_buffers / 1024)) MB"
    echo "缓存: $((mem_cached / 1024)) MB"
    echo "内存使用率: $(( (mem_total - mem_avail) * 100 / mem_total ))%"
    
    # 交换空间
    swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    if [ "$swap_total" -gt 0 ]; then
        echo "交换空间: $((swap_total / 1024)) MB"
        echo "空闲交换: $((swap_free / 1024)) MB"
    fi
    
    echo ""
    echo "=== 存储空间信息 ==="
    
    # 各分区信息
    partitions="system data cache sdcard"
    for part in $partitions; do
        case $part in
            system) path="/system" ;;
            data) path="/data" ;;
            cache) path="/cache" ;;
            sdcard) path="/sdcard" ;;
        esac
        
        if mount | grep -q " on $path "; then
            df -h $path 2>/dev/null | while read device size used avail percent mount; do
                if [ "$mount" = "$path" ]; then
                    echo "$part: $used/$size ($percent)"
                fi
            done
        fi
    done
    
    # 内部存储详细信息
    echo ""
    echo "=== 内部存储 ==="
    df -h /data | tail -1 | awk '{print "总空间: " $2 ", 已用: " $3 ", 可用: " $4 ", 使用率: " $5}'
    
    # SD卡信息
    if mount | grep -q " on /sdcard "; then
        echo ""
        echo "=== SD卡存储 ==="
        df -h /sdcard | tail -1 | awk '{print "总空间: " $2 ", 已用: " $3 ", 可用: " $4 ", 使用率: " $5}'
    fi
    
    echo "========================="
    echo -n "按回车键返回..."
    read
}

# 电池和传感器信息
battery_sensor_info() {
    clear_screen
    echo "===== 电池和传感器信息 ====="
    
    # 电池信息
    if [ -d "/sys/class/power_supply/battery" ]; then
        capacity=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
        status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
        health=$(cat /sys/class/power_supply/battery/health 2>/dev/null)
        temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
        voltage=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)
        technology=$(cat /sys/class/power_supply/battery/technology 2>/dev/null)
        
        echo "电池容量: ${capacity}%"
        echo "电池状态: ${status}"
        echo "电池健康: ${health}"
        echo "电池温度: $((temp / 10))°C"
        echo "电池电压: $((voltage / 1000)) mV"
        echo "电池技术: ${technology}"
    else
        echo "电池信息: 不可用"
    fi
    
    # 传感器信息
    echo ""
    echo "=== 可用传感器 ==="
    if [ -d "/sys/class/sensors" ]; then
        ls /sys/class/sensors/ | while read sensor; do
            echo "- $sensor"
        done
    else
        dumpsys sensorservice 2>/dev/null | grep -A5 "Active sensors:" | tail -5
    fi
    
    # 温度传感器
    echo ""
    echo "=== 温度传感器 ==="
    find /sys/class/thermal/ -name "temp" 2>/dev/null | while read temp_file; do
        temp=$(cat $temp_file 2>/dev/null)
        if [ -n "$temp" ]; then
            sensor_name=$(echo $temp_file | cut -d'/' -f5)
            echo "$sensor_name: $((temp / 1000))°C"
        fi
    done
    
    echo "========================="
    echo -n "按回车键返回..."
    read
}

# 启动主循环
main
