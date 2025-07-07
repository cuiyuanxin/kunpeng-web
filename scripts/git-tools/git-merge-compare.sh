#!/bin/bash

# Git项目代码比较和合并脚本
# 用法: ./git-merge-compare.sh <源项目路径> <目标项目路径> [相对路径]
# 示例: ./git-merge-compare.sh /path/to/project1 /path/to/project2 src/components

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 显示使用说明
show_usage() {
    echo "Git项目代码比较和合并脚本"
    echo ""
    echo "用法:"
    echo "  $0 <源项目路径> <目标项目路径> [相对路径]"
    echo ""
    echo "参数:"
    echo "  源项目路径    - 源Git项目的根目录路径"
    echo "  目标项目路径  - 目标Git项目的根目录路径"
    echo "  相对路径      - 可选，指定要比较的子目录或文件（相对于项目根目录）"
    echo ""
    echo "示例:"
    echo "  $0 /home/user/project1 /home/user/project2"
    echo "  $0 /home/user/project1 /home/user/project2 src/components"
    echo "  $0 /home/user/project1 /home/user/project2 package.json"
    echo ""
    echo "功能:"
    echo "  1. 检查两个项目的Git状态"
    echo "  2. 比较指定位置的代码差异"
    echo "  3. 提供交互式合并选项"
    echo "  4. 支持文件级别和目录级别的比较"
}

# 检查参数
if [ $# -lt 2 ]; then
    print_error "参数不足"
    show_usage
    exit 1
fi

SOURCE_PROJECT="$1"
TARGET_PROJECT="$2"
RELATIVE_PATH="${3:-}"

# 验证项目路径
validate_project() {
    local project_path="$1"
    local project_name="$2"
    
    if [ ! -d "$project_path" ]; then
        print_error "${project_name}路径不存在: $project_path"
        exit 1
    fi
    
    if [ ! -d "$project_path/.git" ]; then
        print_error "${project_name}不是Git项目: $project_path"
        exit 1
    fi
}

# 检查Git状态
check_git_status() {
    local project_path="$1"
    local project_name="$2"
    
    cd "$project_path"
    
    print_info "检查${project_name}的Git状态..."
    
    # 检查是否有未提交的更改
    if ! git diff-index --quiet HEAD --; then
        print_warning "${project_name}有未提交的更改"
        git status --porcelain
        echo ""
    fi
    
    # 显示当前分支和最新提交
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local latest_commit=$(git log -1 --format="%h %s")
    print_info "${project_name} - 分支: $current_branch, 最新提交: $latest_commit"
}

# 智能合并目录内容
merge_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local direction="$3"  # "source_to_target" 或 "target_to_source"
    
    if [ "$direction" = "source_to_target" ]; then
        print_info "正在将源目录内容合并到目标目录..."
        # 使用rsync进行智能合并，保留目标目录中不冲突的文件
        if command -v rsync > /dev/null 2>&1; then
            rsync -av --progress "$source_dir/" "$target_dir/"
        else
            # 如果没有rsync，使用cp with backup
            cp -r "$source_dir"/* "$target_dir/" 2>/dev/null || {
                # 逐个文件复制以处理冲突
                find "$source_dir" -type f | while read -r file; do
                    rel_path="${file#$source_dir/}"
                    target_file="$target_dir/$rel_path"
                    mkdir -p "$(dirname "$target_file")"
                    cp "$file" "$target_file"
                done
            }
        fi
    else
        print_info "正在将目标目录内容合并到源目录..."
        if command -v rsync > /dev/null 2>&1; then
            rsync -av --progress "$target_dir/" "$source_dir/"
        else
            cp -r "$target_dir"/* "$source_dir/" 2>/dev/null || {
                find "$target_dir" -type f | while read -r file; do
                    rel_path="${file#$target_dir/}"
                    source_file="$source_dir/$rel_path"
                    mkdir -p "$(dirname "$source_file")"
                    cp "$file" "$source_file"
                done
            }
        fi
    fi
}

# 比较文件或目录
compare_paths() {
    local source_path="$SOURCE_PROJECT/$RELATIVE_PATH"
    local target_path="$TARGET_PROJECT/$RELATIVE_PATH"
    
    # 检查路径是否存在
    if [ ! -e "$source_path" ]; then
        print_error "源路径不存在: $source_path"
        return 1
    fi
    
    if [ ! -e "$target_path" ]; then
        print_warning "目标路径不存在: $target_path"
        echo "是否要从源项目复制到目标项目? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if [ -d "$source_path" ]; then
                mkdir -p "$target_path"
                merge_directory "$source_path" "$target_path" "source_to_target"
            else
                cp "$source_path" "$target_path"
            fi
            print_success "已复制 $source_path 到 $target_path"
        fi
        return 0
    fi
    
    print_info "比较路径: $RELATIVE_PATH"
    
    # 检查是文件还是目录
    if [ -f "$source_path" ] && [ -f "$target_path" ]; then
        # 文件比较
        if diff "$source_path" "$target_path" > /dev/null 2>&1; then
            print_success "文件完全相同"
            return 0
        fi
    elif [ -d "$source_path" ] && [ -d "$target_path" ]; then
        # 目录比较
        if diff -r "$source_path" "$target_path" > /dev/null 2>&1; then
            print_success "目录内容完全相同"
            return 0
        fi
    else
        print_error "源和目标的类型不匹配（一个是文件，一个是目录）"
        return 1
    fi
    
    print_warning "发现差异"
    echo ""
    
    # 根据类型显示不同的选项
    if [ -d "$source_path" ]; then
        echo "选择操作:"
        echo "1) 查看详细差异 (diff)"
        echo "2) 使用可视化工具比较 (如果可用)"
        echo "3) 智能合并：将源目录内容合并到目标目录"
        echo "4) 智能合并：将目标目录内容合并到源目录"
        echo "5) 完全覆盖：用源目录完全替换目标目录"
        echo "6) 完全覆盖：用目标目录完全替换源目录"
        echo "7) 跳过"
        echo -n "请选择 (1-7): "
    else
        echo "选择操作:"
        echo "1) 查看详细差异 (diff)"
        echo "2) 使用可视化工具比较 (如果可用)"
        echo "3) 从源覆盖到目标"
        echo "4) 从目标覆盖到源"
        echo "5) 跳过"
        echo -n "请选择 (1-5): "
    fi
    
    read -r choice
    
    case $choice in
        1)
            print_info "显示详细差异:"
            if [ -d "$source_path" ]; then
                diff -ur "$source_path" "$target_path" || true
            else
                diff -u "$source_path" "$target_path" || true
            fi
            ;;
        2)
            # 尝试使用可视化diff工具
            if command -v meld > /dev/null 2>&1; then
                meld "$source_path" "$target_path" &
            elif command -v code > /dev/null 2>&1; then
                code --diff "$source_path" "$target_path"
            elif command -v vimdiff > /dev/null 2>&1; then
                vimdiff "$source_path" "$target_path"
            else
                print_error "未找到可用的可视化diff工具"
                if [ -d "$source_path" ]; then
                    diff -ur "$source_path" "$target_path" || true
                else
                    diff -u "$source_path" "$target_path" || true
                fi
            fi
            ;;
        3)
            if [ -d "$source_path" ]; then
                merge_directory "$source_path" "$target_path" "source_to_target"
                print_success "已将源目录内容智能合并到目标目录"
            else
                cp "$source_path" "$target_path"
                print_success "已从源覆盖到目标"
            fi
            ;;
        4)
            if [ -d "$source_path" ]; then
                merge_directory "$source_path" "$target_path" "target_to_source"
                print_success "已将目标目录内容智能合并到源目录"
            else
                cp "$target_path" "$source_path"
                print_success "已从目标覆盖到源"
            fi
            ;;
        5)
            if [ -d "$source_path" ]; then
                rm -rf "$target_path"
                cp -r "$source_path" "$target_path"
                print_success "已用源目录完全替换目标目录"
            else
                print_info "跳过合并"
            fi
            ;;
        6)
            if [ -d "$source_path" ]; then
                rm -rf "$source_path"
                cp -r "$target_path" "$source_path"
                print_success "已用目标目录完全替换源目录"
            else
                print_error "无效选择"
            fi
            ;;
        7)
            if [ -d "$source_path" ]; then
                print_info "跳过合并"
            else
                print_error "无效选择"
            fi
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
}

# 主函数
main() {
    print_info "开始Git项目代码比较和合并..."
    echo ""
    
    # 验证项目路径
    validate_project "$SOURCE_PROJECT" "源项目"
    validate_project "$TARGET_PROJECT" "目标项目"
    
    print_success "项目路径验证通过"
    echo ""
    
    # 检查Git状态
    check_git_status "$SOURCE_PROJECT" "源项目"
    check_git_status "$TARGET_PROJECT" "目标项目"
    echo ""
    
    # 如果没有指定相对路径，列出可能的比较选项
    if [ -z "$RELATIVE_PATH" ]; then
        print_info "未指定具体路径，显示项目结构对比..."
        echo ""
        echo "源项目结构:"
        ls -la "$SOURCE_PROJECT" | head -20
        echo ""
        echo "目标项目结构:"
        ls -la "$TARGET_PROJECT" | head -20
        echo ""
        echo "请重新运行脚本并指定要比较的相对路径"
        echo "例如: $0 \"$SOURCE_PROJECT\" \"$TARGET_PROJECT\" src"
        return 0
    fi
    
    # 比较指定路径
    compare_paths
    
    print_success "操作完成"
}

# 捕获Ctrl+C
trap 'print_warning "操作被用户中断"; exit 1' INT

# 显示帮助
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# 执行主函数
main