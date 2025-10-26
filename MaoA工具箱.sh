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
CURRENT_VERSION="4.9"  # 当前脚本版本

# 默认目录配置
DEFAULT_DIRECTORIES=(
    "/storage/emulated/0/Android/data/org.telegram.messenger.web/cache"
    "/data/media/0/Android/data/org.telegram.messenger.web/cache"
    "/data/user/0/org.telegram.messenger"
    "/data/media/0/Android/data/org.telegram.messenger/cache"
)

# 清屏函数
clear_screen() {
    printf "\033c"
}

# 静默更新函数
silent_update() {
    SCRIPT_PATH=$(get_script_path)
    mkdir -p "$TEMP_DIR"
    
    DOWNLOAD_URL="${GITHUB_RAW_URL}?t=$(date +%s)"
    
    if command -v curl >/dev/null; then
        curl -s -o "$TEMP_SCRIPT" "$DOWNLOAD_URL" || return 1
    elif command -v wget >/dev/null; then
        wget -qO "$TEMP_SCRIPT" "$DOWNLOAD_URL" || return 1
    else
        return 1
    fi
    
    [ ! -s "$TEMP_SCRIPT" ] && return 1
    
    BACKUP_PATH="${SCRIPT_PATH}.bak"
    cp -f "$SCRIPT_PATH" "$BACKUP_PATH"
    
    if cp -f "$TEMP_SCRIPT" "$SCRIPT_PATH"; then
        chmod 755 "$SCRIPT_PATH"
        NEW_VERSION=$(grep -m1 '^CURRENT_VERSION=' "$SCRIPT_PATH" | cut -d'"' -f2)
        [ "$NEW_VERSION" != "$CURRENT_VERSION" ] && exec "$SCRIPT_PATH"
    fi
    
    rm -f "$TEMP_SCRIPT"
    rmdir "$TEMP_DIR" 2>/dev/null
}

# 静默删除备份文件
silent_delete_backup() {
    SCRIPT_PATH=$(get_script_path)
    BACKUP_PATH="${SCRIPT_PATH}.bak"
    [ -f "$BACKUP_PATH" ] && rm -f "$BACKUP_PATH"
}

# 显示标题
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

# 获取脚本路径
get_script_path() {
    if [ -n "$BASH_SOURCE" ]; then
        readlink -f "$BASH_SOURCE"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "${(%):-%x}"
    else
        local pid=$$
        ls -l /proc/$pid/exe | awk '{print $11}'
    fi
}

# 检查root权限
check_root() {
    [ "$(whoami)" = "root" ] || {
        echo -e "${ERROR_COLOR}✗ 权限验证失败: 需要ROOT权限\n终止代码: 0xE12F9A${RESET_COLOR}"
        exit 1
    }
    echo -e "${SUCCESS_COLOR}✓ 权限验证通过: ROOT访问已授权\n${RESET_COLOR}"
}

# 关闭验证功能
disable_verification() {
    echo -e "${INFO_COLOR}▶ 关闭验证功能...${RESET_COLOR}"
    
    if [ -f "$VERIFICATION_LOG" ]; then
        echo -e "${INFO_COLOR}▶ 删除自定义验证文件...${RESET_COLOR}"
        while IFS= read -r file; do
            [ -f "$file" ] && {
                rm -f "$file"
                echo -e "${SUCCESS_COLOR}✓ 已删除: $file${RESET_COLOR}"
                dir_name=$(dirname "$file")
                rmdir "$dir_name" 2>/dev/null && echo -e "${SUCCESS极速版_COLOR}✓ 目录已删除: $dir_name${RESET_COLOR}"
            }
        done < "$VERIFICATION_LOG"
        rm -f "$VERIFICATION_LOG"
    else
        echo -e "${WARNING_COLOR}✗ 未找到验证日志文件${RESET_COLOR}"
    fi
    
    echo -e "${SUCCESS_COLOR}✓ 验证功能已关闭\n${RESET_COLOR}"
}

# 保存目录配置
save_directories() {
    rm -f "$CONFIG_FILE"
    for dir in "$@"; do echo "$dir" >> "$CONFIG_FILE"; done
    echo -e "${SUCCESS_COLOR}✓ 目录配置已保存${RESET_COLOR}"
}

# 加载目录配置
load_directories() {
    if [ -f "$CONFIG_FILE" ]; then
        directories=()
        while IFS= read -r line; do directories+=("$line"); done < "$CONFIG_FILE"
        echo "${directories[@]}"
    else
        echo "${DEFAULT_DIRECTORIES[@]}"
    fi
}

# 获取配置类型
get_config_type() {
    [ ! -f "$CONFIG_FILE" ] && echo "电报默认路径" && return
    
    is_default=true
    for dir in "${DEFAULT_DIRECTORIES[@]}"; do
        grep -q "$dir" "$CONFIG_FILE" || { is_default=false; break; }
    done
    
    [ "$is_default" = true ] && echo "电报默认路径" || echo "自定义路径"
}

# 显示当前配置
show_current_config() {
    config_type=$(get_config_type)
    echo -e "${INFO_COLOR}当前配置类型: $config_type${RESET_COLOR}"
    
    current_dirs=($(load_directories))
    echo -e "${INFO_COLOR}当前配置的目录:${RESET_COLOR}"
    for dir in "${current_dirs[@]}"; do echo "- $dir"; done
    echo
}

# 目录设置功能
directory_setup() {
    while :; do
        clear_screen
        show_header
        echo -e "${HEADER_COLOR}===== 目录设置 =====${RESET_COLOR}"
        echo -e "${INFO_COLOR}1. 使用电报默认目录"
        echo "2. 自定义目录"
        echo "3. 返回上级菜单"
        echo -e "${HEADER_COLOR}====================${RESET_COLOR}"
        
        show_current_config
        
        read -p "$(echo -e "${INFO_COLOR}请选择操作: ${RESET_COLOR}")" choice
        
        case $choice in
            1) 
                save_directories "${DEFAULT_DIRECTORIES[@]}"
                echo -e "${SUCCESS_COLOR}✓ 已设置为电报默认目录${RESET_COLOR}"
                sleep 1
                ;;
            2)
                read -p "$(echo -e "${INFO_COLOR}请输入自定义目录路径: ${RESET_COLOR}")" custom_dir
                [ -z "$custom_dir" ] && echo -e "${ERROR_COLOR}✗ 目录不能为空${RESET_COLOR}" || {
                    save_directories "$custom_dir"
                    echo -e "${SUCCESS_COLOR}✓ 自定义目录已保存${RESET_COLOR}"
                }
                sleep 1
                ;;
            3) return ;;
            *) echo -e "${ERROR_COLOR}✗ 无效选择${RESET_COLOR}"; sleep 1 ;;
        esac
    done
}

# 文件生成功能
generate_files() {
    echo -e "${INFO_COLOR}▶ 文件生成功能${RESET_COLOR}"
    
    read -p "$(echo -e "${INFO_COLOR}请输入验证文件名: ${RESET_COLOR}")" FILE_NAME
    [ -z "$FILE_NAME" ] && {
        echo -e "${ERROR_COLOR}✗ 文件名不能为空${RESET_COLOR}"
        return
    }
    
    [[ "$FILE_NAME" != *.jpg ]] && FILE_NAME="${FILE_NAME}.jpg"
    
    directories=($(load_directories))
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        TARGET_FILE="$dir/$FILE_NAME"
        echo "验证文件内容" > "$TARGET_FILE"
        chmod 644 "$TARGET_FILE" 2>/dev/null
        echo "$TARGET_FILE" >> "$VERIFICATION_LOG"
        echo -e "${SUCCESS_COLOR}✓ 文件已生成: $TARGET_FILE${RESET_COLOR}"
    done
    echo
}

# 清理配置功能
clean_config() {
    echo -e "${INFO_COLOR}▶ 清理配置...${RESET_COLOR}"
    rm -f "$CONFIG_FILE" "$VERIFICATION_LOG"
    echo -e "${SUCCESS_COLOR}✓ 所有配置已清理\n${RESET_COLOR}"
}

# 电报验证功能菜单
telegram_verification_menu() {
    while :; do
        clear_screen
        show_header
        echo -e "${HEADER_COLOR}==== 电报验证功能 ====${RESET_COLOR}"
        echo -e "${INFO_COLOR}1. 目录设置"
        echo "2. 文件生成"
        echo "3. 清理配置"
        echo "4. 返回主菜单"
        echo -e "${HEADER_COLOR}======================${RESET_COLOR}"
        
        show_current_config
        
        read -p "$(echo -e "${INFO_COLOR}请选择操作: ${RESET_COLOR}")" choice
        
        case $choice in
            1) directory_setup ;;
            2) 
                generate_files
                read -p "$(echo -e "${INFO_COLOR}按回车键返回...${RESET_COLOR}")"
                ;;
            3) 
                clean_config
                read -p "$(echo -e "${INFO_COLOR}按回车键返回...${RESET_COLOR}")"
                ;;
            4) return ;;
            *) echo -e "${ERROR_COLOR}✗ 无效选择${RESET_COLOR}"; sleep 1 ;;
        esac
    done
}

# 清理缓存功能
clean_cache() {
    echo -e "${INFO_COLOR}▶ 清理缓存文件...${RESET_COLOR}"
    rm -rf "$TEMP_DIR"
    silent_delete_backup
    echo -e "${SUCCESS_COLOR}✓ 所有缓存文件已清理\n${RESET_COLOR}"
}

# 显示主菜单
show_main_menu() {
    show_header
    echo -e "${HEADER_COLOR}========== 主菜单 ==========${RESET_COLOR}"
    echo -e "${INFO_COLOR}1. 电报验证功能"
    echo "2. 关闭验证功能"
    echo "3. 清理缓存文件"
    echo "4. 退出"
    echo -e "${HEADER_COLOR}============================${RESET_COLOR}"
}

# 主程序
main() {
    silent_delete_backup
    silent_update
    check_root
    
    while :; do
        show_main_menu
        read -p "$(echo -e "${INFO_COLOR}请选择操作: ${RESET_COLOR}")" choice
        
        case $choice in
            1) telegram_verification_menu ;;
            2) 
                disable_verification
                read -p "$(echo -e "${INFO_COLOR}按回车键返回主菜单...${RESET_COLOR}")"
                ;;
            3) 
                clean_cache
                read -p "$(echo -e "${INFO_COLOR}按回车键返回主菜单...${RESET_COLOR}")"
                ;;
            4) 
                silent_delete_backup
                echo -e "${SUCCESS_COLOR}✓ 已退出${RESET_COLOR}"
                kill -9 $$ 2>/dev/null
                ;;
            *) 
                echo -e "${ERROR_COLOR}✗ 无效选择${RESET_COLOR}"
                read -p "$(echo -e "${INFO_COLOR}按回车键返回主菜单...${RESET_COLOR}")"
                ;;
        esac
    done
}

# 启动主程序
main
