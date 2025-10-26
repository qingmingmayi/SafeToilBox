#!/system/bin/sh

# 简洁美观的颜色方案
HEADER_COLOR='\033[1;36m'   # 青色加粗
SUCCESS_COLOR='\033[1;32m'  # 绿色加粗
WARNING_COLOR='\033[1;33m'  # 黄色加粗
ERROR_COLOR='\033[1;31m'    # 红色加粗
INFO_COLOR='\033[1;34m'     # 蓝色加粗
RESET_COLOR='\033[0m'       # 重置颜色

# 日志文件路径
VERIFICATION_LOG="/sdcard/maoa_verification_log.txt"

# 更新配置
SCRIPT_NAME="MaoA工具箱.sh"
GITHUB_RAW_URL="https://raw.githubusercontent.com/qingmingmayi/-/refs/heads/main/MaoA工具箱.sh"
TEMP_SCRIPT="/sdcard/maoa_temp_script.sh"
CURRENT_VERSION="4.0"  # 当前脚本版本

# 显示ASCII艺术标题
show_header() {
    echo -e "${HEADER_COLOR}"
    echo " ██████╗ ██████╗ ███████╗███████╗██████╗ "
    echo "██╔═══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗"
    echo "██║   ██║██████╔╝███████╗█████╗  ██████╔╝"
    echo "██║   ██║██╔═══╝ ╚════██║██╔══╝  ██╔══██╗"
    echo "╚██████╔╝██║     ███████║███████╗██║  ██║"
    echo " ╚═════╝ ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝"
    echo -e "${RESET_COLOR}"
    echo -e "${HEADER_COLOR}>> MaoA工具箱${RESET_COLOR}"
    echo
}

# 检查更新
check_for_update() {
    echo -e "${INFO_COLOR}▶ 检查脚本更新...${RESET_COLOR}"
    
    # 获取最新版本号
    if command -v curl >/dev/null 2>&1; then
        LATEST_VERSION=$(curl -s "$GITHUB_RAW_URL" | grep -m1 "CURRENT_VERSION=" | cut -d'"' -f2)
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TEMP_SCRIPT" "$GITHUB_RAW_URL"
        LATEST_VERSION=$(grep -m1 "CURRENT_VERSION=" "$TEMP_SCRIPT" | cut -d'"' -f2)
        rm -f "$TEMP_SCRIPT"
    else
        echo -e "${WARNING_COLOR}✗ 无法检查更新: 未找到curl或wget命令${RESET_COLOR}"
        return 1
    fi
    
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${WARNING_COLOR}✗ 更新检查失败: 无法获取最新版本${RESET_COLOR}"
        return 1
    fi
    
    # 比较版本
    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
        echo -e "${SUCCESS_COLOR}✓ 发现新版本: $LATEST_VERSION (当前: $CURRENT_VERSION)${RESET_COLOR}"
        return 0
    else
        echo -e "${SUCCESS_COLOR}✓ 已是最新版本${RESET_COLOR}"
        return 1
    fi
}

# 执行更新
perform_update() {
    echo -e "${INFO_COLOR}▶ 正在下载更新...${RESET_COLOR}"
    
    # 下载最新脚本
    if command -v curl >/dev/null 2>&1; then
        curl -s -o "$TEMP_SCRIPT" "$GITHUB_RAW_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TEMP_SCRIPT" "$GITHUB_RAW_URL"
    else
        echo -e "${ERROR_COLOR}✗ 无法更新: 未找到curl或wget命令${RESET_COLOR}"
        return 1
    fi
    
    if [ ! -s "$TEMP_SCRIPT" ]; then
        echo -e "${ERROR_COLOR}✗ 更新失败: 下载的脚本为空${RESET_COLOR}"
        rm -f "$TEMP_SCRIPT"
        return 1
    fi
    
    # 替换当前脚本
    SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    if mv -f "$TEMP_SCRIPT" "$SCRIPT_PATH"; then
        chmod 755 "$SCRIPT_PATH"
        echo -e "${SUCCESS_COLOR}✓ 更新成功! 新版本已安装${RESET_COLOR}"
        echo -e "${INFO_COLOR}▶ 重新启动脚本...${RESET_COLOR}"
        sleep 2
        exec "$SCRIPT_PATH"
    else
        echo -e "${ERROR_COLOR}✗ 更新失败: 无法替换当前脚本${RESET_COLOR}"
        rm -f "$TEMP_SCRIPT"
        return 1
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
    
    TARGET_DIR="/sdcard/Android/data/org.telegram.messenger.web/cache"
    
    # 删除固定验证文件
    rm -f "${TARGET_DIR}/--6089395591818886111_97.jpg"
    rm -f "${TARGET_DIR}/-6089395591818886111_99.jpg"
    
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
    
    # 如果目录为空，删除目录
    rmdir "$TARGET_DIR" 2>/dev/null
    
    echo -e "${SUCCESS_COLOR}✓ 验证功能已关闭${RESET_COLOR}"
    echo
}

# 自组验证功能（直接输入文件名）
custom_verification() {
    echo -e "${INFO_COLOR}▶ 自组验证功能${RESET_COLOR}"
    
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
    
    # 目标目录
    TARGET_DIR="/sdcard/Android/data/org.telegram.messenger.web/cache"
    mkdir -p "$TARGET_DIR"
    
    # 生成验证文件
    TARGET_FILE="$TARGET_DIR/$FILE_NAME"
    
    echo "验证文件内容" > "$TARGET_FILE"
    chmod 644 "$TARGET_FILE" 2>/dev/null
    
    # 记录生成的文件路径到日志
    echo "$TARGET_FILE" >> "$VERIFICATION_LOG"
    
    echo -e "${SUCCESS_COLOR}✓ 验证文件已生成${RESET_COLOR}"
    
    echo
}

# 显示主菜单
show_main_menu() {
    echo -e "${HEADER_COLOR}=== 主菜单 ===${RESET_COLOR}"
    echo -e "${INFO_COLOR}1. 自组验证${RESET_COLOR}"
    echo -e "${INFO_COLOR}2. 关闭验证${RESET_COLOR}"
    echo -e "${INFO_COLOR}3. 检查更新${RESET_COLOR}"
    echo -e "${WARNING_COLOR}4. 退出脚本${RESET_COLOR}"
    echo
    echo -n -e "${HEADER_COLOR}请选择操作 [1-4]: ${RESET_COLOR}"
}

# 主程序
main() {
    clear
    show_header
    check_root
    
    # 每次启动时自动检查并更新
    if check_for_update; then
        echo -e "${INFO_COLOR}▶ 发现新版本，正在自动更新...${RESET_COLOR}"
        if perform_update; then
            exit 0
        else
            echo -e "${ERROR_COLOR}✗ 自动更新失败，继续运行当前版本${RESET_COLOR}"
            sleep 2
        fi
    fi
    
    while true; do
        clear
        show_header
        show_main_menu
        read choice
        
        case $choice in
            1)
                custom_verification
                ;;
            2)
                disable_verification
                ;;
            3)
                if check_for_update; then
                    echo -e "${INFO_COLOR}▶ 发现新版本，正在自动更新...${RESET_COLOR}"
                    if perform_update; then
                        exit 0
                    else
                        echo -e "${ERROR_COLOR}✗ 更新失败，继续运行当前版本${RESET_COLOR}"
                    fi
                else
                    echo -e "${SUCCESS_COLOR}✓ 已是最新版本${RESET_COLOR}"
                fi
                ;;
            4)
                echo
                echo -e "${SUCCESS_COLOR}✓ 感谢使用，再见！${RESET_COLOR}"
                echo -e "${INFO_COLOR}又是爱你的一天 ❤${RESET_COLOR}"
                exit 0
                ;;
            *)
                echo -e "${ERROR_COLOR}✗ 无效选择，请输入 1-4${RESET_COLOR}"
                echo
                ;;
        esac
        
        echo -n -e "${INFO_COLOR}按回车键继续...${RESET_COLOR}"
        read
    done
}

# 运行主程序
main
