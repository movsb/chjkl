import Cocoa
import ApplicationServices
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem!
    private var status = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private var toggle = NSMenuItem(title: "", action: #selector(toggleMapping), keyEquivalent: "")
    private var login = NSMenuItem(title: "登录时启动", action: #selector(toggleLogin), keyEquivalent: "")
    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private var timer: Timer?
    private var remapper = Remapper()
    private var enabled = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "右 ⌘ + H J K L → ← ↓ ↑ →", action: nil, keyEquivalent: ""))
        menu.addItem(status)
        menu.addItem(.separator())
        for entry in [toggle,
                      NSMenuItem(title: "授权辅助功能…", action: #selector(openPermissions), keyEquivalent: ""),
                      NSMenuItem(title: "重试监听", action: #selector(retry), keyEquivalent: ""), login,
                      NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")] {
            entry.target = self
            menu.addItem(entry)
        }
        item.menu = menu
        retry()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in self?.retry() }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(retry), name: NSWorkspace.didWakeNotification, object: nil)
    }

    @objc private func retry() {
        if let tap {
            if !CGEvent.tapIsEnabled(tap: tap) { CGEvent.tapEnable(tap: tap, enable: true) }
        } else if AXIsProcessTrusted() {
            let mask = (CGEventMask(1) << CGEventType.keyDown.rawValue) | (CGEventMask(1) << CGEventType.keyUp.rawValue)
            tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
                eventsOfInterest: mask, callback: { _, type, event, context in
                    guard let context else { return Unmanaged.passUnretained(event) }
                    let app = Unmanaged<AppDelegate>.fromOpaque(context).takeUnretainedValue()
                    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                        if let tap = app.tap { CGEvent.tapEnable(tap: tap, enable: true) }
                        return Unmanaged.passUnretained(event)
                    }
                    return app.handle(type, event)
                }, userInfo: Unmanaged.passUnretained(self).toOpaque())
            if let tap {
                source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
                CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
                CGEvent.tapEnable(tap: tap, enable: true)
            }
        }
        refresh()
    }

    private func handle(_ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent> {
        let raw = event.flags.rawValue
        if let target = remapper.translate(code: event.getIntegerValueField(.keyboardEventKeycode),
                                           down: type == .keyDown, flags: raw, enabled: enabled) {
            event.setIntegerValueField(.keyboardEventKeycode, value: target)
            event.keyboardSetUnicodeString(stringLength: 0, unicodeString: nil)
            event.flags = Remapper.arrowFlags(raw)
        }
        return Unmanaged.passUnretained(event)
    }

    private func refresh() {
        let working = tap.map { CGEvent.tapIsEnabled(tap: $0) } ?? false
        item.button?.title = !working ? "⌘!" : enabled ? "⌘↔" : "⌘Ⅱ"
        status.title = !working ? "未监听：请授权辅助功能后重试" : enabled ? "监听已启用" : "映射已暂停"
        toggle.title = enabled ? "暂停映射" : "启用映射"
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc private func toggleMapping() { enabled.toggle(); refresh() }
    @objc private func openPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
            else { try SMAppService.mainApp.register() }
        } catch {
            let alert = NSAlert()
            alert.messageText = "无法更改登录启动"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
        refresh()
    }
    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()
