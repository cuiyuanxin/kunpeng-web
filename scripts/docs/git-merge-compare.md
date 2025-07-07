# Git项目代码比较和合并工具

这是一个用于比较和合并两个Git项目中相同位置代码的通用脚本工具集。支持Linux/macOS（Shell脚本）和Windows（批处理文件）两个版本。

## 文件说明

- `git-merge-compare.sh` - Linux/macOS版本的Shell脚本
- `git-merge-compare.bat` - Windows版本的批处理脚本
- `README-git-merge-compare.md` - 本说明文档

## 功能特性

### 🔍 核心功能
- **项目验证**: 自动验证两个项目路径是否为有效的Git仓库
- **状态检查**: 显示两个项目的Git状态、当前分支和最新提交信息
- **差异比较**: 支持文件级别和目录级别的代码差异比较
- **智能合并**: 根据文件/目录类型提供不同的合并策略
  - **文件处理**: 直接覆盖或跳过
  - **目录处理**: 智能合并（保留不冲突文件）或完全替换
- **交互式合并**: 提供多种合并选项，用户可根据需要选择操作
- **类型匹配验证**: 确保源和目标路径类型一致（都是文件或都是目录）
- **可视化支持**: 自动检测并使用可用的可视化diff工具

### 🛠️ 支持的操作

#### 文件比较操作（1-5）：
1. **查看详细差异** - 显示文件的具体差异内容
2. **可视化比较** - 使用外部工具进行可视化比较
3. **源到目标覆盖** - 将源项目的文件覆盖到目标项目
4. **目标到源覆盖** - 将目标项目的文件覆盖到源项目
5. **跳过操作** - 不进行任何合并操作

#### 目录比较操作（1-7）：
1. **查看详细差异** - 显示目录结构和文件的具体差异内容
2. **可视化比较** - 使用外部工具进行可视化比较
3. **智能合并：源到目标** - 将源目录内容合并到目标目录（保留目标中不冲突的文件）
4. **智能合并：目标到源** - 将目标目录内容合并到源目录（保留源中不冲突的文件）
5. **完全覆盖：源替换目标** - 删除目标目录，用源目录完全替换
6. **完全覆盖：目标替换源** - 删除源目录，用目标目录完全替换
7. **跳过操作** - 不进行任何合并操作

### 🎨 用户体验
- **彩色输出**: 使用不同颜色区分信息类型（信息/成功/警告/错误）
- **友好提示**: 清晰的操作指引和错误提示
- **中断处理**: 支持Ctrl+C优雅中断
- **帮助文档**: 内置详细的使用说明

## 使用方法

### Linux/macOS 使用方法

#### 1. 添加执行权限
```bash
chmod +x git-merge-compare.sh
```

#### 2. 基本用法
```bash
# 比较两个项目的根目录
./git-merge-compare.sh /path/to/project1 /path/to/project2

# 比较特定的子目录
./git-merge-compare.sh /path/to/project1 /path/to/project2 src/components

# 比较特定文件
./git-merge-compare.sh /path/to/project1 /path/to/project2 package.json
```

#### 3. 查看帮助
```bash
./git-merge-compare.sh --help
```

### Windows 使用方法

#### 1. 基本用法
```cmd
REM 比较两个项目的根目录
git-merge-compare.bat C:\project1 C:\project2

REM 比较特定的子目录
git-merge-compare.bat C:\project1 C:\project2 src\components

REM 比较特定文件
git-merge-compare.bat C:\project1 C:\project2 package.json
```

#### 2. 查看帮助
```cmd
git-merge-compare.bat /?
git-merge-compare.bat --help
```

## 参数说明

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| 源项目路径 | 字符串 | 是 | 源Git项目的根目录绝对路径 |
| 目标项目路径 | 字符串 | 是 | 目标Git项目的根目录绝对路径 |
| 相对路径 | 字符串 | 否 | 要比较的子目录或文件相对路径 |

## 使用场景

### 1. 项目迁移
当需要将一个项目的某些功能迁移到另一个项目时：
```bash
./git-merge-compare.sh /old-project /new-project src/utils
```

### 2. 配置文件同步
同步两个项目的配置文件：
```bash
./git-merge-compare.sh /project1 /project2 .eslintrc.js
./git-merge-compare.sh /project1 /project2 tsconfig.json
```

### 3. 组件库更新
更新共享组件：
```bash
./git-merge-compare.sh /component-lib /main-project src/components/common
```

### 4. 构建脚本同步
同步构建相关文件：
```bash
./git-merge-compare.sh /template-project /new-project build
./git-merge-compare.sh /template-project /new-project package.json
```

## 支持的可视化工具

### Linux/macOS
- **Meld** - 图形化diff工具
- **VS Code** - 使用 `code --diff` 命令
- **Vimdiff** - Vim的diff模式

### Windows
- **VS Code** - 使用 `code --diff` 命令
- **WinMerge** - Windows专用的文件比较工具

## 注意事项

### ⚠️ 重要提醒
1. **备份数据**: 在执行任何覆盖或替换操作前，建议先备份重要数据
2. **智能合并 vs 完全替换**:
   - **智能合并**: 保留目标中不冲突的文件，适合增量更新
   - **完全替换**: 删除目标后重新创建，适合完全同步
3. **Git状态**: 脚本会检查Git状态，建议在操作前提交或暂存未完成的更改
4. **类型匹配**: 源和目标路径必须是相同类型（都是文件或都是目录）
5. **路径格式**:
   - Linux/macOS: 使用正斜杠 `/`
   - Windows: 使用反斜杠 `\` 或正斜杠 `/`
6. **权限要求**: 确保对两个项目目录都有读写权限
7. **rsync 优化**: Linux/macOS 版本优先使用 rsync 进行更高效的目录合并

### 🔧 环境要求
- **Git**: 必须安装Git并可在命令行中使用
- **Shell环境**:
  - Linux/macOS: Bash shell
  - Windows: CMD或PowerShell

## 错误处理

脚本包含完善的错误处理机制：

- **路径验证**: 检查项目路径是否存在且为Git仓库
- **权限检查**: 验证文件读写权限
- **用户中断**: 支持Ctrl+C优雅退出
- **工具检测**: 自动检测可用的diff工具

## 扩展建议

### 可能的增强功能
1. **配置文件支持**: 支持配置文件定义常用的项目对比组合
2. **批量操作**: 支持一次比较多个文件或目录
3. **历史记录**: 记录比较和合并操作的历史
4. **自动化模式**: 支持非交互式的自动合并模式
5. **冲突解决**: 更智能的冲突检测和解决机制

### 集成建议
- 可以将脚本添加到Git hooks中实现自动化
- 集成到CI/CD流水线中进行自动化代码同步
- 作为IDE插件或扩展的后端工具

## 许可证

本工具遵循MIT许可证，可自由使用、修改和分发。

---

**提示**: 如果在使用过程中遇到问题，请检查Git是否正确安装，以及是否有足够的文件系统权限。
