#!/system/bin/sh
# 更新日志开始
# 版本 1.8:
#   - 尝试修复林羽配置问题
#   - 将进度条改为纯白长条形状
#   - 添加进度条百分比显示
#   - 改进文件操作稳定性
# 更新日志结束

CURRENT_VERSION="1.8"

GITHUB_RAW_URL="https://raw.githubusercontent.com/qingmingmayi/SafeToilBox/refs/heads/main/SafeToilBox.sh"
TEMP_DIR="/data/local/tmp/safetoolbox_update"
TEMP_SCRIPT="$TEMP_DIR/safetoolbox_temp_script.sh"

# 清屏函数
clear_screen() {
    printf "\033c"
}

# 获取可靠的脚本路径
get_script_path() {
    if [ -n "$BASH_SOURCE" ]; then
        echo "$(readlink -f "$BASH_SOURCE")"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "${(%):-%x}"
    else
        local pid=$$
        local script_path=$(ls -l /proc/$pid/exe | awk '{print $11}')
        [ -f "$script_path" ] && echo "$script_path" || echo "$0"
    fi
}

# 显示主菜单
show_main_menu() {
    clear_screen
    echo "=============================="
    echo "|        SafeToolBox        |"
    echo "=============================="
    echo "[1] 验证管理"
    echo "[2] 系统信息"
    echo "[3] 检查更新"
    echo "[0] 退出脚本"
    echo "=============================="
    echo -n "请选择操作: "
}

# 显示验证管理菜单
show_verification_menu() {
    clear_screen
    echo "=============================="
    echo "|        验证管理菜单        |"
    echo "=============================="
    echo "[1] 王者荣耀"
    echo "[2] 英雄联盟"
    echo "[3] 和平精英"
    echo "[4] 暗区突围"
    echo "[5] 使命召唤"
    echo "[6] 三角洲行动"
    echo "[0] 返回主页"
    echo "=============================="
    echo -n "请选择游戏: "
}

# 显示三角洲行动菜单
show_delta_menu() {
    clear_screen
    echo "=============================="
    echo "|        三角洲行动配置      |"
    echo "=============================="
    echo "[1] 林羽"
    echo "[0] 返回上级"
    echo "=============================="
    echo -n "请选择配置: "
}

# 显示林羽配置菜单
show_linyu_menu() {
    clear_screen
    echo "=============================="
    echo "|          林羽配置         |"
    echo "=============================="
    echo "[1] 开启配置"
    echo "[2] 关闭配置"
    echo "[0] 返回上级"
    echo "=============================="
    echo -n "请选择操作: "
}

# 显示系统信息菜单
show_system_info_menu() {
    clear_screen
    echo "=============================="
    echo "|        系统信息菜单        |"
    echo "=============================="
    echo "[1] 查看系统信息"
    echo "[2] 返回主菜单"
    echo "=============================="
    echo -n "请选择操作: "
}

# 显示完整的系统信息
show_complete_system_info() {
    clear_screen
    echo "===== 系统信息 ====="
    echo "序列号: $(getprop ro.serialno)"
    echo "设备型号: $(getprop ro.product.model)"
    echo "设备品牌: $(getprop ro.product.brand)"
    echo "设备代号: $(getprop ro.product.device)"
    echo "产品名称: $(getprop ro.product.name)"
    echo "安卓版本: $(getprop ro.build.version.release)"
    echo "安全补丁: $(getprop ro.build.version.security_patch)"
    echo "内核版本: $(uname -r)"
    echo "系统架构: $(getprop ro.product.cpu.abi)"
    echo "构建编号: $(getprop ro.build.display.id)"
    
    echo ""
    echo "===== 电池和传感器信息 ====="
    
    # 电池信息
    if [ -d "/sys/class/power_supply/battery" ]; then
        capacity=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "未知")
        status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "未知")
        health=$(cat /sys/class/power_supply/battery/health 2>/dev/null || echo "未知")
        temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null || echo "0")
        voltage=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null || echo "0")
        technology=$(cat /sys/class/power_supply/battery/technology 2>/dev/null || echo "未知")
        
        echo "电池容量: ${capacity}%"
        echo "电池状态: ${status}"
        echo "电池健康: ${health}"
        
        if [ "$temp" != "0" ]; then
            echo "电池温度: $((temp / 10))°C"
        else
            echo "电池温度: 未知"
        fi
        
        if [ "$voltage" != "0" ]; then
            echo "电池电压: $((voltage / 1000)) mV"
        else
            echo "电池电压: 未知"
        fi
        
        echo "电池技术: ${technology}"
    else
        echo "电池信息: 不可用"
    fi
    
    echo ""
    echo "========================="
    echo -n "按回车键返回上级菜单..."
    read
}

# 林羽配置 - 开启配置
enable_linyu_config() {
    local target_dir="/data/media/0/Android/data/org.telegram.messenger.web/cache/"
    local file1="${target_dir}--6089395591818886111_97.jpg"
    local file2="${target_dir}-6089395591818886111_99.jpg"
    
    echo "正在开启林羽配置..."
    
    # 强制性创建目录
    mkdir -p "$target_dir"
    
    # 纯白长条进度条
    echo "进度："
    echo -n "▕"
    for i in 1 2 3 4 5 6 7 8 9 10; do
        echo -n "█"
        sleep 0.15
    done
    echo "▏ 100%"
    
    # 写入文件内容
    echo "SafeToilBox-LinYu" > "$file1"
    echo "SafeToilBox-LinYu" > "$file2"
    
    if [ -f "$file1" ] && [ -f "$file2" ]; then
        echo "✓ 林羽配置已开启"
    else
        echo "✗ 林羽配置设置失败"
    fi
    
    sleep 2
}

# 林羽配置 - 关闭配置
disable_linyu_config() {
    local target_dir="/data/media/0/Android/data/org.telegram.messenger.web/cache/"
    local file1="${target_dir}--6089395591818886111_97.jpg"
    local file2="${target_dir}-6089395591818886111_99.jpg"
    
    echo "正在关闭林羽配置..."
    
    # 纯白长条进度条
    echo "进度："
    echo -n "▕"
    for i in 1 2 3 4 5 6 7 8 9 10; do
        echo -n "█"
        sleep 0.15
    done
    echo "▏ 100%"
    
    # 删除文件
    if [ -f "$file1" ]; then
        rm -f "$file1"
    fi
    
    if [ -f "$file2" ]; then
        rm -f "$file2"
    fi
    
    echo "✓ 林羽配置已关闭"
    sleep 2
}

# 检查更新函数
check_update() {
    clear_screen
    
    SCRIPT_PATH=$(get_script_path)
    mkdir -p "$TEMP_DIR"
    
    DOWNLOAD_URL="${GITHUB_RAW_URL}?t=$(date +%s)"
    
    # 下载最新脚本
    if command -v curl >/dev/null 2>&1; then
        if ! curl -s -o "$TEMP_SCRIPT" "$DOWNLOAD_URL"; then
            echo "✗ 下载失败: 无法连接服务器"
            sleep 2
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -qO "$TEMP_SCRIPT" "$DOWNLOAD_URL"; then
            echo "✗ 下载失败: 无法连接服务器"
            sleep 2
            return 1
        fi
    else
        echo "✗ 未找到下载工具"
        sleep 2
        return 1
    fi
    
    if [ ! -s "$TEMP_SCRIPT" ]; then
        echo "✗ 下载的文件为空"
        return 1
    fi
    
    NEW_VERSION=$(grep -m1 '^CURRENT_VERSION=' "$TEMP_SCRIPT" | cut -d'"' -f2)
    
    if [ -z "$NEW_VERSION" ]; then
        echo "✗ 无法解析版本信息"
        return 1
    fi
    
    echo "┌────────────────────────┐"
    echo "│        版本检查        │"
    echo "├────────────────────────┤"
    echo "│ 当前版本: v$CURRENT_VERSION  │"
    echo "│ 最新版本: v$NEW_VERSION  │"
    echo "└────────────────────────┘"
    
    if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
        echo ""
        echo "发现新版本 v$NEW_VERSION"
        echo "更新内容:"
        echo "────────────────────────"
        sed -n '/^# 更新日志开始/,/^# 更新日志结束/p' "$TEMP_SCRIPT" | sed '1d;$d'
        echo "────────────────────────"
        echo ""
        
        while true; do
            echo -n "是否更新？(y/n): "
            read answer
            case $answer in
                y|Y) break ;;
                n|N) 
                    echo "更新已取消"
                    rm -f "$TEMP_SCRIPT"
                    return 0
                    ;;
                *) echo "请输入 y 或 n" ;;
            esac
        done
        
        BACKUP_PATH="${SCRIPT_PATH}.bak"
        if cp -f "$SCRIPT_PATH" "$BACKUP_PATH" 2>/dev/null; then
            echo "✓ 已创建备份"
        fi
        
        if cp -f "$TEMP_SCRIPT" "$SCRIPT_PATH"; then
            chmod 755 "$SCRIPT_PATH"
            echo "✓ 更新成功！"
            echo "正在重启脚本..."
            sleep 2
            exec "$SCRIPT_PATH"
        else
            echo "✗ 更新失败"
            echo "请手动更新脚本文件"
        fi
    else
        echo "当前已是最新版本"
        sleep 2
    fi
    
    rm -f "$TEMP_SCRIPT" 2>/dev/null
}

# 验证管理菜单处理
verification_management() {
    while true; do
        show_verification_menu
        read choice
        
        case $choice in
            1|2|3|4|5) 
                clear_screen
                case $choice in
                    1) echo "王者荣耀配置";;
                    2) echo "英雄联盟配置";;
                    3) echo "和平精英配置";;
                    4) echo "暗区突围配置";;
                    5) echo "使命召唤配置";;
                esac
                echo "功能开发中..."
                echo ""
                echo "按回车键返回..."
                read
                ;;
            6) delta_action ;;
            0) return ;;
            *) 
                echo "无效选项，请重新选择"
                sleep 1 
                ;;
        esac
    done
}

# 三角洲行动菜单处理
delta_action() {
    while true; do
        show_delta_menu
        read choice
        
        case $choice in
            1) linyu_config ;;
            0) return ;;
            *) 
                echo "无效选项，请重新选择"
                sleep 1 
                ;;
        esac
    done
}

# 林羽配置菜单处理
linyu_config() {
    while true; do
        show_linyu_menu
        read choice
        
        case $choice in
            1) enable_linyu_config ;;
            2) disable_linyu_config ;;
            0) return ;;
            *) 
                echo "无效选项，请重新选择"
                sleep 1 
                ;;
        esac
    done
}

# 系统信息菜单处理
system_info_menu() {
    while true; do
        show_system_info_menu
        read choice
        
        case $choice in
            1) show_complete_system_info ;;
            2) return ;;
            *) 
                echo "无效选项，请重新选择"
                sleep 1 
                ;;
        esac
    done
}

# 主循环
main() {
    while true; do
        show_main_menu
        read choice
        
        case $choice in
            1) verification_management ;;
            2) system_info_menu ;;
            3) check_update ;;
            0) 
                echo "感谢使用 SafeToolBox，再见！"
                exit 0 
                ;;
            *) 
                echo "无效选项，请重新选择"
                sleep 1 
                ;;
        esac
    done
}

# 启动脚本
main
