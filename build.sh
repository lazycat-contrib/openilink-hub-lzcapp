#!/bin/bash

# OpenILINK Hub - 懒猫应用发布脚本
# 完整工作流：构建 → 镜像复制 → 更新 manifest → 重新构建 → 发布

set -e

APP_NAME="OpenILINK Hub"
PACKAGE="cloud.lazycat.app.openilink-hub"
MANIFEST_FILE="lzc-manifest.yml"
BUILD_FILE="lzc-build.yml"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必需文件
check_files() {
    print_info "检查必需文件..."

    local missing=0

    if [ ! -f "$MANIFEST_FILE" ]; then
        print_error "缺少：$MANIFEST_FILE"
        missing=1
    fi

    if [ ! -f "$BUILD_FILE" ]; then
        print_error "缺少：$BUILD_FILE"
        missing=1
    fi

    if [ ! -f "icon.png" ]; then
        print_warning "缺少：icon.png (512x512 PNG)"
    fi

    if [ $missing -eq 1 ]; then
        print_error "必需文件不完整，请先创建配置文件"
        exit 1
    fi

    print_success "文件检查通过"
}

# 显示应用信息
show_info() {
    print_info "===== $APP_NAME 应用信息 ====="
    echo ""
    echo "包名：$PACKAGE"
    echo "配置文件：$MANIFEST_FILE"
    echo ""
    echo "数据持久化：/lzcapp/var/data"
    echo "访问端口：9800"
    echo ""
    echo "懒猫访问地址：http://openilink-hub.lzcapp:9800"
    echo ""
}

# 构建应用
build_app() {
    print_info "开始构建应用..."

    if command -v lzc-cli &> /dev/null; then
        lzc-cli project build -o "${PACKAGE//./-}-1.0.0.lpk"
        print_success "构建完成！"
    else
        print_error "未找到 lzc-cli，请先安装懒猫 CLI 工具"
        exit 1
    fi
}

# 复制镜像到懒猫仓库
copy_image() {
    print_info "复制镜像到懒猫仓库..."

    # 检查登录状态
    if ! lzc-cli appstore my-images &> /dev/null 2>&1; then
        print_error "未登录懒猫应用商店"
        print_info "请先执行：lzc-cli appstore login"
        exit 1
    fi

    # 复制镜像
    ORIGINAL_IMAGE="ghcr.io/openilink/openilink-hub:latest"
    print_info "复制镜像：$ORIGINAL_IMAGE"

    result=$(lzc-cli appstore copy-image "$ORIGINAL_IMAGE" 2>&1)
    echo "$result"

    # 提取新镜像地址
    NEW_IMAGE=$(echo "$result" | grep "^uploaded:" | awk '{print $2}')

    if [ -n "$NEW_IMAGE" ]; then
        print_success "镜像已复制到：$NEW_IMAGE"

        # 更新 manifest 文件
        print_info "更新 manifest 文件..."

        # 备份原文件
        cp "$MANIFEST_FILE" "${MANIFEST_FILE}.bak"

        # 更新镜像（保留原镜像为注释）
        sed -i.tmp "/image:.*openilink-hub/ {
            s|^|    # |
            a\\
    image: $NEW_IMAGE
        }" "$MANIFEST_FILE"

        rm -f "${MANIFEST_FILE}.tmp"

        print_success "Manifest 已更新"
        print_info "原镜像配置已保留为注释"
    else
        print_warning "未能提取新镜像地址，可能已存在"
    fi
}

# 发布到应用商店
publish_app() {
    print_info "发布到懒猫应用商店..."

    # 检查登录状态
    if ! lzc-cli appstore my-images &> /dev/null 2>&1; then
        print_error "未登录懒猫应用商店"
        print_info "请先执行：lzc-cli appstore login"
        exit 1
    fi

    # 获取最新的 lpk 文件
    LPK_FILE=$(ls -t "${PACKAGE//./-}"-*.lpk 2>/dev/null | head -1)

    if [ -z "$LPK_FILE" ]; then
        print_error "未找到 LPK 文件，请先构建应用"
        exit 1
    fi

    print_info "发布文件：$LPK_FILE"
    lzc-cli appstore publish "$LPK_FILE"

    print_success "发布成功！等待审核（1-3 个工作日）"
}

# 一键发布
one_click_publish() {
    print_info "===== 一键发布流程 ====="
    echo ""

    # 阶段 1: 初始构建
    print_info "阶段 1: 初始构建（原始镜像）"
    build_app
    echo ""

    # 阶段 2: 镜像复制 + 自动更新
    print_info "阶段 2: 镜像复制（自动更新 manifest）"
    copy_image
    echo ""

    # 阶段 3: 重新构建
    print_info "阶段 3: 重新构建（新镜像）"
    build_app
    echo ""

    # 阶段 4: 发布
    print_info "阶段 4: 发布审核"
    publish_app
    echo ""

    print_success "===== 发布流程完成 ====="
}

# 主菜单
show_menu() {
    echo ""
    echo "===== $APP_NAME 发布工具 ====="
    echo "1. 构建应用"
    echo "2. 镜像复制到懒猫仓库"
    echo "3. 发布到应用商店"
    echo "4. 一键发布（构建 + 镜像复制 + 发布）"
    echo "5. 查看应用信息"
    echo "6. 退出"
    echo ""
    read -p "请选择操作 [1-6]: " choice
}

# 主程序
main() {
    check_files

    while true; do
        show_menu

        case $choice in
            1)
                build_app
                ;;
            2)
                copy_image
                ;;
            3)
                publish_app
                ;;
            4)
                one_click_publish
                ;;
            5)
                show_info
                ;;
            6)
                print_info "退出"
                exit 0
                ;;
            *)
                print_error "无效选择"
                ;;
        esac
    done
}

main
