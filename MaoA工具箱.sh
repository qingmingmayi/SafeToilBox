#!/system/bin/sh

# 简洁美观的颜色方案
HEADER_COLOR='\033[1;36m'   # 青色加粗
SUCCESS_COLOR='\033[1;32m'  # 绿色加粗
WARNING_COLOR='\033[1;33m'  # 黄色加粗
ERROR_COLOR='\033[1;31m'    # 红色加粗
INFO_COLOR='\033[1;34m'     # 蓝色加粗
RESET_COLOR='\033[0m'       # 重置颜色

# 配置文件路径
CONFIG_FILE="/sdcard/maoa_config.txt"
VERIFICATION_LOG="/sdcard/maoa_verification_log.txt"

# 更新配置
GITHUB_RAW_URL="https://raw.githubusercontent.com/qingmingmayi/-/refs/heads/main/MaoA工具箱.sh"
TEMP_DIR="/data/local/tmp/maoa_update"
TEMP_SCRIPT="$TEMP_DIR/maoa_temp_script.sh"
CURRENT_VERSION="4.4"  # 当前脚本版本

# 默认目录配置
DEFAULT_DIRECTORIES=(
    "/storage/emulated/0/Android/data/org.telegram.messenger.web/cache"
    "/data/media/0/Android/data/org.telegram.messenger.web/cache"
    "/data/user/0/org.telegram.messenger"
    "/data/media/0/Android/data/org.telegram.messenger/cache"
)

# 清屏函数 - 使用ANSI转义序列
clear_screen() {
    printf "\033c"  # 真正的清屏命令
}

# 静默更新函数 - 修复版
silent_update() {
    # 获取可靠的脚本路径
    SCRIPT_PATH=$(get_script_path)
    
    # 创建临时目录
    mkdir -p "$TEMP_DIR"
    
    # 下载最新脚本 - 添加时间戳避免缓存
    DOWNLOAD_URL="${GITHUB_RAW_URL}?t=$(date +%s)"
    
    # 使用curl或wget下载
    if command -v curl >/dev/null 2>&1; then
        if ! curl -s -o "$TEMP_SCRIPT" "$DOWNLOAD_URL"; then
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -qO "$TEMP_SCRIPT" "$DOWNLOAD_URL"; then
            return 1
        fi
    else
        return 1
    fi
    
    # 检查下载是否成功
    if [ ! -s "$TEMP_SCRIPT" ]; then
        return 1
    fi
    
    # 创建备份
    BACKUP_PATH="${SCRIPT_PATH}.bak"
    cp -f "$SCRIPT_PATH" "$BACKUP_PATH"
    
    # 替换当前脚本
    if cp -f "$TEMP_SCRIPT" "$SCRIPT_PATH"; then
        chmod 755 "$SCRIPT_PATH"
        
        # 验证版本号
        NEW_VERSION=$(grep -m1 '^CURRENT_VERSION=' "$SCRIPT_PATH" | cut -d'"' -f2)
        if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
            # 更新成功，重启脚本
            echo -e "${INFO_COLOR}▶ 检测到新版本 ($NEW_VERSION)，正在重启脚本...${RESET_COLOR}"
            sleep 1
            exec "$SCRIPT_PATH"
        fi
    fi
    
    # 清理临时文件
    rm -f "$TEMP_SCRIPT"
    rmdir "$TEMP_DIR" 2>/dev/null
}

# 删除备份文件
delete_backup() {
    SCRIPT_PATH=$(get_script_path)
    BACKUP_PATH="${SCRIPT_PATH}.bak"
    
    if [ -f "$BACKUP_PATH" ]; then
        echo -e "${INFO_COLOR}▶ 发现备份文件，正在删除...${RESET_COLOR}"
        rm -f "$BACKUP_PATH"
        if [ ! -f "$BACKUP_PATH" ]; then
            echo -e "${SUCCESS_COLOR}✓ 备份文件已删除${RESET_COLOR}"
        else
            echo -e "${WARNING_COLOR}✗ 无法删除备份文件${RESET_COLOR}"
        fi
    fi
}

# 显示ASCII艺术标题
show_header() {
    clear_screen
    echo -e "${HEADER_COLOR}"
    echo " ███╗   ███╗ █████╗  ██████╗  █████╗ "
    echo " ████╗ ████║██╔══██╗██╔═══██╗██╔══██╗"
    echo " ██╔████╔██║███████║██║   ██║███████║"
    echo " ██║╚██╔╝██║██╔══██║██║   ██║██╔══██║"
    echo " ██║ ╚═╝ ██║██║  ██║╚██████╔╝██║  ██║"
    echo " ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝"
    echo -e "${RESET_COLOR}"
    echo -e "${HEADER_COLOR}>> MaoA工具箱 v$CURRENT_VERSION${RESET_COLOR}"
    echo
}

# 获取可靠的脚本路径
get_script_path() {
    # 尝试多种方法获取可靠路径
    if [ -n "$BASH_SOURCE" ]; then
        echo "$(readlink -f "$BASH_SOURCE")"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "${(%):-%x}"
    else
        # 回退方法：使用lsof查找进程路径
        local pid=$$
        local script_path=$(ls -l /proc/$pid/exe | awk '{print $11}')
        [ -f "$script_path" ] && echo "$script_path" || echo "$0"
    fi
}

# 检查root权限
check_root() {
    if [ "$(whoami)" != "root" ]; then
        echo -e "${ERROR_COLOR}✗ 权限验证失败: 需要ROOT权限${RESET_COLOR}"
        echo -e "${ERROR_COLOR}终止代码: 0xE12F9A${RESET_COLOR}"
        exit 1
    fi
    echo -e "${SUCCESS_COLOR}✓ 权限验证通过: ROOT访问已授权${RESET_COLOR}"
    echo
}

# 关闭验证功能
disable_verification() {
    echo -e "${INFO_COLOR}▶ 关闭验证功能...${RESET_COLOR}"
    
    # 读取配置文件中的目录
    if [ -f "$CONFIG_FILE" ]; then
        while IFS= read -r dir; do
            # 删除固定验证文件
            rm -f "${dir}/--6089395591818886111_97.jpg"
            rm -f "${dir}/-6089395591818886111_99.jpg"
            
            # 如果目录为空，删除目录
            rmdir "$dir" 2>/dev/null
        done < "$CONFIG_FILE"
    else
        # 使用默认目录
        for dir in "${DEFAULT_DIRECTORIES[@]}"; do
            rm -f "${dir}/--6089395591818886111_97.jpg"
            rm -f "${dir}/-6089395591818886111_99.jpg"
            rmdir "$dir" 2>/dev/null
        done
    fi
    
    # 删除自定义验证文件（如果存在日志）
    if [ -f "$VERIFICATION_LOG" ]; then
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                rm -f "$file"
                echo -e "${SUCCESS_COLOR}已删除自定义文件: $(basename "$file")${RESET_COLOR}"
            fi
        done < "$VERIFICATION_LOG"
        # 删除日志文件
        rm -f "$VERIFICATION_LOG"
    fi
    
    echo -e "${SUCCESS_COLOR}✓ 验证功能已关闭${RESET_COLOR}"
    echo
}

# 保存目录配置
save_directories() {
    # 删除旧配置文件
    rm -f "$CONFIG_FILE"
    
    # 写入新配置
    for dir in "$@"; do
        echo "$dir" >> "$CONFIG_FILE"
    done
    
    echo -e "${SUCCESS_COLOR}✓ 目录配置已保存${RESET_COLOR}"
}

# 加载目录配置 (兼容Android shell)
load_directories() {
    if [ -f "$CONFIG_FILE" ]; then
        # 使用while循环替代mapfile
        directories=()
        while IFS= read -r line; do
            directories+=("$line")
        done < "$CONFIG_FILE"
        echo "${directories[@]}"
    else
        echo "${DEFAULT_DIRECTORIES[@]}"
    fi
}

# 获取配置类型
get_config_type() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "电报默认路径"
        return
    fi
    
    # 检查是否使用默认配置
    is_default=true
    for dir in "${DEFAULT_DIRECTORIES[@]}"; do
        if ! grep -q "$dir" "$CONFIG_FILE"; then
            is_default=false
            break
        fi
    done
    
    if [ "$is_default" = true ]; then
        echo "电报默认路径"
    else
        echo "自定义路径"
    fi
}

# 目录设置功能
directory_setup() {
    while true; do
        clear_screen
        show_header
        echo -e "${HEADER_COLOR}===== 目录设置 =====${RESET_COLOR}"
        echo -e "${INFO_COLOR}1. 使用电报默认目录${RESET_COLOR}"
        echo -e "${INFO_COLOR}2. 自定义目录${RESET_COLOR}"
        echo -e "${INFO_COLOR}3. 返回上级菜单${RESET_COLOR}"
        echo -e "${HEADER_COLOR}====================${RESET_COLOR}"
        
        # 显示当前配置类型
        config_type=$(get_config_type)
        echo -e "${INFO_COLOR}当前配置类型: $config_type${RESET_COLOR}"
        
        # 显示当前配置的目录
        current_dirs=($(load_directories))
        echo -e "${INFO_COLOR}当前配置的目录:${RESET_COLOR}"
        for dir in "${current_dirs[@]}"; do
            echo "- $dir"
        done
        echo
        
        echo -n -e "${INFO_COLOR}请选择操作: ${RESET_COLOR}"
        read choice
        
        case $choice in
            1)
                # 使用电报默认目录
                save_directories "${DEFAULT_DIRECTORIES[@]}"
                echo -e "${SUCCESS_COLOR}✓ 已设置为电报默认目录${RESET_COLOR}"
                sleep 1
                ;;
            2)
                # 自定义目录
                echo -n -e "${INFO_COLOR}请输入自定义目录路径: ${RESET_COLOR}"
                read custom_dir
                
                if [ -z "$custom_dir" ]; then
                    echo -e "${ERROR_COLOR}✗ 目录不能为空${RESET_COLOR}"
                else
                    save_directories "$custom_dir"
                    echo -e "${SUCCESS_COLOR}✓ 自定义目录已保存${RESET_COLOR}"
                fi
                sleep 1
                ;;
            3)
                # 返回上级菜单
                return
                ;;
            *)
                echo -e "${ERROR_COLOR}✗ 无效选择${RESET_COLOR}"
                sleep 1
                ;;
        esac
    done
}

# 文件生成功能
generate_files() {
    echo -e "${INFO_COLOR}▶ 文件生成功能${RESET_COLOR}"
    
    # 提示用户输入文件名
    echo -n -e "${INFO_COLOR}请输入验证文件名: ${RESET_COLOR}"
    read FILE_NAME
    
    # 检查输入是否为空
    if [ -z "$FILE_NAME" ]; then
        echo -e "${ERROR_COLOR}✗ 文件名不能为空${RESET_COLOR}"
        return
    fi
    
    # 确保文件名以.jpg结尾
    if [ "${FILE_NAME%.jpg}" = "$FILE_NAME" ]; then
        FILE_NAME="${FILE_NAME}.jpg"
    fi
    
    # 获取配置的目录
    directories=($(load_directories))
    
    # 生成验证文件
    for dir in "${directories[@]}"; do
        # 创建目录（如果不存在）
        mkdir -p "$dir"
        
        # 生成验证文件
        TARGET_FILE="$dir/$FILE_NAME"
        echo "验证文件内容" > "$TARGET_FILE"
        chmod 644 "$TARGET_FILE" 2>/dev/null
        
        # 记录生成的文件路径到日志
        echo "$TARGET_FILE" >> "$VERIFICATION_LOG"
        
        echo -e "${SUCCESS_COLOR}✓ 文件已生成: $TARGET_FILE${RESET_COLOR}"
    done
    
    echo
}

# 清理配置功能
clean_config() {
    echo -e "${INFO_COLOR}▶ 清理配置...${RESET_COLOR}"
    
    # 删除配置文件
    rm -f "$CONFIG_FILE"
    
    # 删除验证日志
    rm -f "$VERIFICATION_LOG"
    
    echo -e "${SUCCESS_COLOR}✓ 所有配置已清理${RESET_COLOR}"
    echo
}

# 电报验证功能菜单
telegram_verification_menu() {
    while true; do
        clear_screen
        show_header
        echo -e "${HEADER_COLOR}==== 电报验证功能 ====${RESET_COLOR}"
        echo -e "${INFO_COLOR}1. 目录设置${RESET_COLOR}"
        echo -e "${INFO_COLOR}2. 文件生成${RESET_COLOR}"
        echo -e "${INFO_COLOR}3. 清理配置${RESET_COLOR}"
        echo -e "${INFO_COLOR}4. 返回主菜单${RESET_COLOR}"
        echo -e "${HEADER_COLOR}======================${RESET_COLOR}"
        
        # 显示当前配置类型
        config_type=$(get_config_type)
        echo -e "${INFO_COLOR}当前配置类型: $config_type${RESET_COLOR}"
        
        # 显示当前配置的目录
        current_dirs=($(load_directories))
        echo -e "${INFO_COLOR}当前配置的目录:${RESET_COLOR}"
        for dir in "${current_dirs[@]}"; do
            echo "- $dir"
        done
        echo
        
        echo -n -e "${INFO_COLOR}请选择操作: ${RESET_COLOR}"
        read choice
        
        case $choice in
            1)
                directory_setup
                ;;
            2)
                generate_files
                echo -n -e "${INFO_COLOR}按回车键返回...${RESET_COLOR}"
                read
                ;;
            3)
                clean_config
                echo -n -e "${INFO_COLOR}按回车键返回...${RESET_COLOR}"
                read
                ;;
            4)
                # 返回主菜单
                return
                ;;
            *)
                echo -e "${ERROR_COLOR}✗ 无效选择${RESET_COLOR}"
                sleep 1
                ;;
        esac
    done
}

# 清理缓存功能
clean_cache() {
    echo -e "${INFO_COLOR}▶ 清理缓存文件...${RESET_COLOR}"
    
    # 清理临时更新文件
    rm -rf "$TEMP_DIR"
    
    # 清理备份文件
    delete_backup
    
    echo -e "${SUCCESS_COLOR}✓ 所有缓存文件已清理${RESET_COLOR}"
    echo
}

# 显示主菜单
show_main_menu() {
    show_header
    echo -e "${HEADER_COLOR}========== 主菜单 ==========${RESET_COLOR}"
    echo -e "${INFO_COLOR}1. 电报验证功能${RESET_COLOR}"
    echo -e "${INFO_COLOR}2. 关闭验证功能${RESET_COLOR}"
    echo -e "${INFO_COLOR}3. 清理缓存文件${RESET_COLOR}"
    echo -e "${INFO_COLOR}4. 退出${RESET_COLOR}"
    echo -e "${HEADER_COLOR}============================${RESET_COLOR}"
}

# 等待用户按键
wait_for_key() {
    echo -n -e "${INFO_COLOR}按回车键返回主菜单...${RESET_COLOR}"
    read
}

# 主程序
main() {
    # 删除可能存在的备份文件
    delete_backup
    
    # 尝试静默更新
    silent_update
    
    # 检查root权限
    check_root
    
    while true; do
        show_main_menu
        echo -n -e "${INFO_COLOR}请选择操作: ${RESET_COLOR}"
        read choice
        
        case $choice in
            1)
                telegram_verification_menu
                ;;
            2)
                disable_verification
                wait_for_key
                ;;
            3)
                clean_cache
                wait_for_key
                ;;
            4)
                echo -e "${SUCCESS_COLOR}✓ 已退出${RESET_COLOR}"
                exit 0
                ;;
            *)
                echo -e "${ERROR_COLOR}✗ 无效选择${RESET_COLOR}"
                wait_for_key
                ;;
        esac
    done
}

# 启动主程序
main
