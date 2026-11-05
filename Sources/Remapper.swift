import CoreGraphics

/// Retain each down's decision until its up, even if Command is released first.
struct Remapper {
    static let rightCommand: UInt64 = 0x10
    static let leftCommand: UInt64 = 0x08
    static let arrows: [Int64: Int64] = [4: 123, 38: 125, 40: 126, 37: 124]
    private var held: [Int64: Int64] = [:]

    mutating func translate(code: Int64, down: Bool, flags: UInt64, enabled: Bool) -> Int64? {
        if !down { return held.removeValue(forKey: code).flatMap { $0 == code ? nil : $0 } }
        if let previous = held[code] { return previous == code ? nil : previous }
        let target = enabled && flags & Self.rightCommand != 0 ? Self.arrows[code] : nil
        held[code] = target ?? code
        return target
    }

    static func arrowFlags(_ raw: UInt64) -> CGEventFlags {
        var flags = CGEventFlags(rawValue: raw & ~rightCommand)
        if raw & leftCommand == 0 { flags.remove(.maskCommand) }
        flags.insert(.maskSecondaryFn)
        flags.insert(.maskNumericPad)
        return flags
    }
}
