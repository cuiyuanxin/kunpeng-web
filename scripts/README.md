# Scripts 脚本工具集

本目录包含项目开发和维护过程中使用的各种脚本工具和相关文档。

## 📁 目录结构

```
scripts/
├── README.md                 # 本文档
├── docs/                     # 脚本文档目录
│   └── git-merge-compare.md  # Git代码比较合并工具文档
└── git-tools/                # Git相关工具脚本
    ├── git-merge-compare.sh   # Linux/macOS版本的Git比较合并脚本
    └── git-merge-compare.bat  # Windows版本的Git比较合并脚本
```

## 🛠️ 工具分类

### Git工具 (`git-tools/`)
包含与Git版本控制相关的实用脚本：

- **git-merge-compare** - 用于比较和合并两个Git项目中相同位置代码的通用工具
  - 支持跨平台使用（Linux/macOS/Windows）
  - 提供交互式代码差异比较和合并功能
  - 详细文档：[git-merge-compare.md](./docs/git-merge-compare.md)

## 📖 使用指南

### 快速开始

1. **查看工具文档**：在 `docs/` 目录中找到对应工具的详细说明文档
2. **选择合适版本**：根据操作系统选择对应的脚本文件
3. **添加执行权限**（Linux/macOS）：
   ```bash
   chmod +x scripts/git-tools/*.sh
   ```
4. **运行脚本**：按照文档说明执行相应命令

### 脚本开发规范

当需要添加新的脚本工具时，请遵循以下规范：

#### 📂 目录组织
- 按功能分类创建子目录（如 `git-tools/`、`build-tools/`、`deploy-tools/` 等）
- 相关文档统一放在 `docs/` 目录下
- 保持目录结构清晰，便于维护

#### 📝 命名规范
- 脚本文件使用小写字母和连字符：`tool-name.sh`、`tool-name.bat`
- 文档文件与脚本同名：`tool-name.md`
- 避免使用空格和特殊字符

#### 🔧 脚本要求
- **跨平台支持**：提供Linux/macOS（.sh）和Windows（.bat/.ps1）版本
- **错误处理**：包含完善的错误检查和用户友好的错误提示
- **帮助信息**：支持 `-h`、`--help` 参数显示使用说明
- **注释文档**：代码中包含清晰的注释说明

#### 📋 文档要求
- **功能说明**：清楚描述脚本的用途和功能
- **使用方法**：提供详细的使用示例和参数说明
- **环境要求**：说明运行环境和依赖条件
- **注意事项**：列出重要的使用注意事项和限制

## 🚀 常用脚本

### Git代码比较合并
```bash
# Linux/macOS
./scripts/git-tools/git-merge-compare.sh /path/to/project1 /path/to/project2 src/components

# Windows
scripts\git-tools\git-merge-compare.bat C:\project1 C:\project2 src\components
```

## 🤝 贡献指南

欢迎贡献新的脚本工具！请遵循以下步骤：

1. **创建功能分支**：从主分支创建新的功能分支
2. **添加脚本文件**：按照规范在相应目录下添加脚本
3. **编写文档**：在 `docs/` 目录下创建对应的说明文档
4. **测试验证**：确保脚本在不同环境下正常工作
5. **更新README**：在本文档中添加新工具的说明
6. **提交PR**：创建Pull Request并描述变更内容

## 📞 支持与反馈

如果在使用脚本过程中遇到问题或有改进建议，请：

1. 查看对应的文档说明
2. 检查环境配置和依赖条件
3. 在项目仓库中创建Issue描述问题
4. 或联系项目维护者获取帮助

---

**注意**：使用脚本前请仔细阅读相关文档，确保了解脚本的功能和潜在风险。建议在重要操作前备份相关数据。