# Chjkl

macOS 13+ 菜单栏改键工具：右 Command + H/J/K/L → 左/下/上/右。
使用系统 CGEventTap，无需虚拟键盘驱动。左 Command 保持原有行为；Shift、Option、Control 修饰保留，同时按左右 Command 时保留左 Command。

## 构建和运行

```sh
./scripts/build.sh
open build/Chjkl.app
```

点击菜单栏 `⌘!` →「授权辅助功能…」，在系统设置 → 隐私与安全性 → 辅助功能中启用 Chjkl。如列表没有出现，使用 + 添加此 App。返回菜单点击「重试监听」；程序也会每 3 秒自动重试。`⌘↔` 表示事件监听已启用，`⌘Ⅱ` 表示映射暂停。

建议将构建后的 App 复制到固定位置（如 ~/Applications）再授权和启用「登录时启动」。移动或重新构建采用临时签名的 App 后，系统可能要求重新授权。当前构建为本机架构，未公证。

## 行为和验证

- 长按保留系统自动重复；每个按键从按下到释放使用同一个映射决定。
- 右 Command 仍能用于其他快捷键。
- 暂停时，已经映射的按键仍会正确处理后续重复和释放。
- 监听被系统禁用后尝试恢复；唤醒及定时检查会重试监听。
- 「监听已启用」仅说明事件 tap 正常，无法保证安全输入场景能收到键盘事件。密码框等安全输入场景可能不可用。休眠或安全输入期间若丢失释放事件，退出并重启 App。
- 与 Karabiner 同时处理相同组合键会影响验证，试用时请先关闭其中对应规则。

```sh
./scripts/test.sh
```

自动检查覆盖四键映射、自动重复、Command 提前释放、暂停时释放、左 Command、双 Command、Shift 保留和字母先按的行为。需要在真实桌面补充验证：TextEdit、终端、浏览器、Finder 中四键和长按；Shift 选区；右 Command 与字母不同释放顺序；睡眠唤醒；权限撤销后恢复。自动检查不能替代这些交互验证。

实现参考：[Apple CGEvent 文档](https://developer.apple.com/documentation/coregraphics/cgevent)。

## 重编译后辅助功能失效

先退出旧进程，再仅重置 Chjkl 的辅助功能记录并打开新版本：

```sh
./scripts/reset-accessibility.sh
```

在系统设置中重新授权。如果旧条目仍在，使用 − 移除，再用 + 添加当前 `build/Chjkl.app`。若仍无法生效，退出并重新打开 Chjkl。此脚本不会授予权限，授权必须由你在系统设置中完成。

默认构建使用 ad-hoc 临时签名，二进制变化后可能需要重复上述步骤。若有固定的代码签名证书，可以指定同一个身份：

```sh
CHJKL_SIGN_IDENTITY='你的代码签名证书名称或 SHA-1' ./scripts/build.sh
```

用 `security find-identity -v -p codesigning` 查看可用身份。切换到证书签名后首次仍需重新授权；之后保持相同证书、Bundle ID 和安装位置。固定证书能改善身份连续性，但不能保证系统永不要求重新授权。
