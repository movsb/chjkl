# Chjkl

**用右 ⌘ + H J K L 移动光标，手不用离开键盘主区。**

Chjkl 是一款 macOS 菜单栏工具，把 Vim 的方向键手感带到日常应用里。编辑文字、在 Finder 里浏览文件，或在终端里修改命令时，按住右 Command 就能用 H、J、K、L 代替方向键。

**[下载 Chjkl for macOS](https://github.com/movsb/chjkl/releases/latest)** · Apple Silicon · macOS 13 或更新版本

## 四个键，四个方向

| 按住右 ⌘，再按 | H | J | K | L |
| :--- | :---: | :---: | :---: | :---: |
| 方向 | ← 左 | ↓ 下 | ↑ 上 | → 右 |

- **长按连续移动。** 按住组合键，沿用系统的按键重复。
- **配合修饰键使用。** 保留 Shift、Option 和 Control。例如，在文本编辑器里按右 ⌘ + Shift + L，可向右选中文字。
- **照常使用 Command 快捷键。** 左 ⌘ 保持原有行为，右 ⌘ 仍可用于 H、J、K、L 以外的快捷键。
- **随时暂停。** 在菜单栏暂停或恢复映射，也可以启用「登录时启动」。

## 安装与使用

1. 在 [GitHub Releases](https://github.com/movsb/chjkl/releases) 的 Assets 中下载 `Chjkl-v版本号-macOS-arm64.zip`，解压后把 `Chjkl.app` 拖到「应用程序」并打开。
2. 点击菜单栏的 `⌘!` →「授权辅助功能…」，在「系统设置 → 隐私与安全性 → 辅助功能」中启用 Chjkl。如果列表里没有 Chjkl，点击「+」添加。
3. 回到菜单栏点击「重试监听」。看到 `⌘↔` 后，在文本编辑器里试试 **右 ⌘ + L**。

Chjkl 通过 macOS 的辅助功能权限监听并转换按键，无需安装键盘驱动。下载包使用临时签名且未经 Apple 公证。如果 macOS 拦截首次打开，可到「系统设置 → 隐私与安全性」查看是否提供「仍要打开」。

## 遇到问题

- **更新后按键没反应。** 在「辅助功能」中移除旧的 Chjkl 条目，重新添加「应用程序」里的 Chjkl，再点「重试监听」。
- **在密码框里无法使用。** macOS 的安全输入可能阻止 Chjkl 接收按键。如果离开密码框或唤醒后映射异常，退出并重新打开 Chjkl。
- **与其他改键工具冲突。** 如果 Karabiner 等工具也在处理右 ⌘ + H/J/K/L，请关闭其中对应的规则。

<details>
<summary>从源码构建与发布</summary>

```sh
./scripts/test.sh
./scripts/build.sh
open build/Chjkl.app
```

本地构建使用当前机器架构。重编译后如需清除 Chjkl 的辅助功能授权记录，可先退出 App，再运行 `./scripts/reset-accessibility.sh`，然后在系统设置中重新授权。若有固定的签名证书，可通过 `CHJKL_SIGN_IDENTITY` 指定签名身份。

推送指向待发布提交的 `vx.y.z` 标签会触发 GitHub Actions。测试和构建通过后，工作流会创建 Release，并上传 Apple Silicon ZIP 和 `SHA256SUMS.txt`。

</details>
