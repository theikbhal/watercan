import AppKit

let size = CGSize(width: 1024, height: 1024)
let img = NSImage(size: size)
img.lockFocus()
let rect = CGRect(origin: .zero, size: size).insetBy(dx: 40, dy: 40)
let path = NSBezierPath(roundedRect: rect, xRadius: 200, yRadius: 200)
NSGradient(colors: [
    NSColor(red: 0.20, green: 0.75, blue: 0.50, alpha: 1),
    NSColor(red: 0.10, green: 0.40, blue: 0.85, alpha: 1)
])!.draw(in: path, angle: -90)
let s = NSAttributedString(string: "🪴", attributes: [.font: NSFont.systemFont(ofSize: 620)])
let sz = s.size()
s.draw(at: CGPoint(x: (size.width - sz.width) / 2, y: (size.height - sz.height) / 2))
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!
    .write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
