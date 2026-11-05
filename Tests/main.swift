import CoreGraphics

var mapper = Remapper()
var checks = 0
func check(_ condition: Bool, _ name: String) {
    precondition(condition, name)
    checks += 1
}
let right = Remapper.rightCommand | CGEventFlags.maskCommand.rawValue
for (key, arrow) in Remapper.arrows {
    check(mapper.translate(code: key, down: true, flags: right, enabled: true) == arrow, "mapping")
    check(mapper.translate(code: key, down: true, flags: 0, enabled: false) == arrow, "repeat preserves decision")
    check(mapper.translate(code: key, down: false, flags: 0, enabled: false) == arrow, "release after Command and pause")
}
check(mapper.translate(code: 4, down: true, flags: 0, enabled: true) == nil, "ordinary h")
check(mapper.translate(code: 4, down: true, flags: right, enabled: true) == nil, "Command pressed after letter")
check(mapper.translate(code: 4, down: false, flags: right, enabled: true) == nil, "ordinary release")
check(mapper.translate(code: 38, down: true, flags: CGEventFlags.maskCommand.rawValue | Remapper.leftCommand, enabled: true) == nil, "left Command")
check(mapper.translate(code: 38, down: false, flags: 0, enabled: true) == nil, "left release")
let shifted = Remapper.arrowFlags(right | CGEventFlags.maskShift.rawValue)
check(!shifted.contains(.maskCommand) && shifted.contains(.maskShift), "Shift retained, right Command removed")
check(Remapper.arrowFlags(right | Remapper.leftCommand).contains(.maskCommand), "left Command retained with both held")
check(mapper.translate(code: 40, down: true, flags: right, enabled: false) == nil, "pause")
print("Passed \(checks) state and modifier checks")
