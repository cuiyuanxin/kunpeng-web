@echo off
setlocal enabledelayedexpansion

REM Git项目代码比较和合并脚本 (Windows版本)
REM 用法: git-merge-compare.bat <源项目路径> <目标项目路径> [相对路径]
REM 示例: git-merge-compare.bat C:\project1 C:\project2 src\components

REM 颜色定义 (Windows CMD)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 打印带颜色的消息
:print_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM 显示使用说明
:show_usage
echo Git项目代码比较和合并脚本 (Windows版本)
echo.
echo 用法:
echo   %~nx0 ^<源项目路径^> ^<目标项目路径^> [相对路径]
echo.
echo 参数:
echo   源项目路径    - 源Git项目的根目录路径
echo   目标项目路径  - 目标Git项目的根目录路径
echo   相对路径      - 可选，指定要比较的子目录或文件（相对于项目根目录）
echo.
echo 示例:
echo   %~nx0 C:\Users\user\project1 C:\Users\user\project2
echo   %~nx0 C:\Users\user\project1 C:\Users\user\project2 src\components
echo   %~nx0 C:\Users\user\project1 C:\Users\user\project2 package.json
echo.
echo 功能:
echo   1. 检查两个项目的Git状态
echo   2. 比较指定位置的代码差异
echo   3. 提供交互式合并选项
echo   4. 支持文件级别和目录级别的比较
echo.
echo 注意: 需要安装Git for Windows
goto :eof

REM 检查参数
if "%~2"=="" (
    call :print_error "参数不足"
    call :show_usage
    exit /b 1
)

set "SOURCE_PROJECT=%~1"
set "TARGET_PROJECT=%~2"
set "RELATIVE_PATH=%~3"

REM 检查帮助参数
if "%~1"=="-h" goto show_usage
if "%~1"=="--help" goto show_usage
if "%~1"=="/?" goto show_usage

REM 验证项目路径
:validate_project
set "project_path=%~1"
set "project_name=%~2"

if not exist "%project_path%" (
    call :print_error "%project_name%路径不存在: %project_path%"
    exit /b 1
)

if not exist "%project_path%\.git" (
    call :print_error "%project_name%不是Git项目: %project_path%"
    exit /b 1
)
goto :eof

REM 检查Git状态
:check_git_status
set "project_path=%~1"
set "project_name=%~2"

pushd "%project_path%"

call :print_info "检查%project_name%的Git状态..."

REM 检查是否有未提交的更改
git diff-index --quiet HEAD -- >nul 2>&1
if errorlevel 1 (
    call :print_warning "%project_name%有未提交的更改"
    git status --porcelain
    echo.
)

REM 显示当前分支和最新提交
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set "current_branch=%%i"
for /f "tokens=*" %%i in ('git log -1 --format="%%h %%s"') do set "latest_commit=%%i"
call :print_info "%project_name% - 分支: !current_branch!, 最新提交: !latest_commit!"

popd
goto :eof

REM 智能合并目录内容
:merge_directory
set "source_dir=%~1"
set "target_dir=%~2"
set "direction=%~3"

if "%direction%"=="source_to_target" (
    call :print_info "正在将源目录内容合并到目标目录..."
    REM 使用robocopy进行智能合并
    robocopy "%source_dir%" "%target_dir%" /E /XO /R:0 /W:0 >nul
) else (
    call :print_info "正在将目标目录内容合并到源目录..."
    robocopy "%target_dir%" "%source_dir%" /E /XO /R:0 /W:0 >nul
)
goto :eof

REM 比较文件或目录
:compare_paths
if "%RELATIVE_PATH%"=="" (
    set "source_path=%SOURCE_PROJECT%"
    set "target_path=%TARGET_PROJECT%"
) else (
    set "source_path=%SOURCE_PROJECT%\%RELATIVE_PATH%"
    set "target_path=%TARGET_PROJECT%\%RELATIVE_PATH%"
)

REM 检查路径是否存在
if not exist "%source_path%" (
    call :print_error "源路径不存在: %source_path%"
    exit /b 1
)

if not exist "%target_path%" (
    call :print_warning "目标路径不存在: %target_path%"
    set /p "response=是否要从源项目复制到目标项目? (y/n): "
    if /i "!response!"=="y" (
        if exist "%source_path%\*" (
            if not exist "%target_path%" mkdir "%target_path%"
            call :merge_directory "%source_path%" "%target_path%" "source_to_target"
        ) else (
            copy "%source_path%" "%target_path%" >nul
        )
        call :print_success "已复制 %source_path% 到 %target_path%"
    )
    goto :eof
)

call :print_info "比较路径: %RELATIVE_PATH%"

REM 检查是文件还是目录
if exist "%source_path%\*" (
    if exist "%target_path%\*" (
        REM 都是目录
        robocopy "%source_path%" "%target_path%" /L /NJH /NJS /NDL /NC >nul 2>&1
        if not errorlevel 1 (
            call :print_success "目录内容完全相同"
            goto :eof
        )
    ) else (
        call :print_error "源和目标的类型不匹配（一个是文件，一个是目录）"
        exit /b 1
    )
) else (
    if not exist "%target_path%\*" (
        REM 都是文件
        fc /B "%source_path%" "%target_path%" >nul 2>&1
        if not errorlevel 1 (
            call :print_success "文件完全相同"
            goto :eof
        )
    ) else (
        call :print_error "源和目标的类型不匹配（一个是文件，一个是目录）"
        exit /b 1
    )
)

call :print_warning "发现差异"
echo.

REM 根据类型显示不同的选项
if exist "%source_path%\*" (
    echo 选择操作:
    echo 1^) 查看详细差异
    echo 2^) 使用可视化工具比较 ^(如果可用^)
    echo 3^) 智能合并：将源目录内容合并到目标目录
    echo 4^) 智能合并：将目标目录内容合并到源目录
    echo 5^) 完全覆盖：用源目录完全替换目标目录
    echo 6^) 完全覆盖：用目标目录完全替换源目录
    echo 7^) 跳过
    set /p "choice=请选择 (1-7): "
) else (
    echo 选择操作:
    echo 1^) 查看详细差异
    echo 2^) 使用可视化工具比较 ^(如果可用^)
    echo 3^) 从源覆盖到目标
    echo 4^) 从目标覆盖到源
    echo 5^) 跳过
    set /p "choice=请选择 (1-5): "
)

if "!choice!"=="1" (
    call :print_info "显示详细差异:"
    if exist "%source_path%\*" (
        echo 目录差异比较:
        robocopy "%source_path%" "%target_path%" /L /NJH /NJS
    ) else (
        fc "%source_path%" "%target_path%"
    )
) else if "!choice!"=="2" (
    REM 尝试使用可视化diff工具
    where code >nul 2>&1
    if not errorlevel 1 (
        code --diff "%source_path%" "%target_path%"
    ) else (
        where winmerge >nul 2>&1
        if not errorlevel 1 (
            winmerge "%source_path%" "%target_path%"
        ) else (
            call :print_error "未找到可用的可视化diff工具 ^(VS Code, WinMerge^)"
            if exist "%source_path%\*" (
                robocopy "%source_path%" "%target_path%" /L /NJH /NJS
            ) else (
                fc "%source_path%" "%target_path%"
            )
        )
    )
) else if "!choice!"=="3" (
    if exist "%source_path%\*" (
        call :merge_directory "%source_path%" "%target_path%" "source_to_target"
        call :print_success "已将源目录内容智能合并到目标目录"
    ) else (
        copy "%source_path%" "%target_path%" /Y >nul
        call :print_success "已从源覆盖到目标"
    )
) else if "!choice!"=="4" (
    if exist "%source_path%\*" (
        call :merge_directory "%source_path%" "%target_path%" "target_to_source"
        call :print_success "已将目标目录内容智能合并到源目录"
    ) else (
        copy "%target_path%" "%source_path%" /Y >nul
        call :print_success "已从目标覆盖到源"
    )
) else if "!choice!"=="5" (
    if exist "%source_path%\*" (
        rmdir /S /Q "%target_path%" >nul 2>&1
        xcopy "%source_path%" "%target_path%" /E /I /Y >nul
        call :print_success "已用源目录完全替换目标目录"
    ) else (
        call :print_info "跳过合并"
    )
) else if "!choice!"=="6" (
    if exist "%source_path%\*" (
        rmdir /S /Q "%source_path%" >nul 2>&1
        xcopy "%target_path%" "%source_path%" /E /I /Y >nul
        call :print_success "已用目标目录完全替换源目录"
    ) else (
        call :print_error "无效选择"
    )
) else if "!choice!"=="7" (
    if exist "%source_path%\*" (
        call :print_info "跳过合并"
    ) else (
        call :print_error "无效选择"
    )
) else (
    call :print_error "无效选择"
)
goto :eof

REM 主函数
:main
call :print_info "开始Git项目代码比较和合并..."
echo.

REM 验证项目路径
call :validate_project "%SOURCE_PROJECT%" "源项目"
call :validate_project "%TARGET_PROJECT%" "目标项目"

call :print_success "项目路径验证通过"
echo.

REM 检查Git状态
call :check_git_status "%SOURCE_PROJECT%" "源项目"
call :check_git_status "%TARGET_PROJECT%" "目标项目"
echo.

REM 如果没有指定相对路径，列出可能的比较选项
if "%RELATIVE_PATH%"=="" (
    call :print_info "未指定具体路径，显示项目结构对比..."
    echo.
    echo 源项目结构:
    dir "%SOURCE_PROJECT%" /B | more
    echo.
    echo 目标项目结构:
    dir "%TARGET_PROJECT%" /B | more
    echo.
    echo 请重新运行脚本并指定要比较的相对路径
    echo 例如: %~nx0 "%SOURCE_PROJECT%" "%TARGET_PROJECT%" src
    goto :eof
)

REM 比较指定路径
call :compare_paths

call :print_success "操作完成"
goto :eof

REM 执行主函数
call :main