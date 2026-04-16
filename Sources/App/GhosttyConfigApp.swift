import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApp.applicationIconImage = AppIconGenerator.makeAppIcon()

        // Ensure the window comes to front
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct GhosttyConfigApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 960, height: 620)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Config Window") {
                    NSApp.sendAction(#selector(NSWindow.newWindowForTab(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .appInfo) {
                Button("About Ghostty Config") {
                    NSApp.orderFrontStandardAboutPanel(options: [
                        .applicationName: "Ghostty Config",
                        .applicationVersion: "1.0",
                        .credits: NSAttributedString(
                            string: "A companion app for managing Ghostty terminal configuration.",
                            attributes: [.font: NSFont.systemFont(ofSize: 11)]
                        ),
                        .applicationIcon: AppIconGenerator.makeAppIcon()
                    ])
                }
            }
        }
    }
}

// MARK: - Programmatic App Icon

enum AppIconGenerator {
    static func makeAppIcon() -> NSImage {
        let size: CGFloat = 512
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        guard let ctx = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }

        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        // --- Rounded-rect background (macOS icon shape) ---
        let cornerRadius: CGFloat = size * 0.22
        let bgPath = CGPath(roundedRect: rect.insetBy(dx: 12, dy: 12),
                            cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                            transform: nil)

        // Gradient: deep indigo to dark purple
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradColors: [CGFloat] = [
            0.14, 0.10, 0.28, 1.0,  // top
            0.08, 0.05, 0.18, 1.0   // bottom
        ]
        if let gradient = CGGradient(colorSpace: colorSpace, colorComponents: gradColors,
                                     locations: [0, 1], count: 2) {
            ctx.saveGState()
            ctx.addPath(bgPath)
            ctx.clip()
            ctx.drawLinearGradient(gradient,
                                   start: CGPoint(x: size / 2, y: size),
                                   end: CGPoint(x: size / 2, y: 0),
                                   options: [])
            ctx.restoreGState()
        }

        // Subtle border
        ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.08))
        ctx.setLineWidth(2)
        ctx.addPath(bgPath)
        ctx.strokePath()

        // --- Ghost body ---
        let cx = size / 2
        let cy = size * 0.52

        ctx.saveGState()

        let ghostW: CGFloat = 180
        let ghostH: CGFloat = 220
        let ghostTop = cy + ghostH * 0.3
        let ghostBot = cy - ghostH * 0.45

        let ghostPath = CGMutablePath()
        ghostPath.move(to: CGPoint(x: cx - ghostW / 2, y: ghostBot))
        let waveCnt = 4
        let waveW = ghostW / CGFloat(waveCnt)
        for i in 0..<waveCnt {
            let startX = cx - ghostW / 2 + waveW * CGFloat(i)
            let midX = startX + waveW / 2
            let endX = startX + waveW
            let yOff: CGFloat = (i % 2 == 0) ? -18 : 0
            ghostPath.addQuadCurve(to: CGPoint(x: midX, y: ghostBot + yOff),
                                   control: CGPoint(x: (startX + midX) / 2, y: ghostBot + yOff / 2))
            ghostPath.addQuadCurve(to: CGPoint(x: endX, y: ghostBot),
                                   control: CGPoint(x: (midX + endX) / 2, y: ghostBot + yOff / 2))
        }
        ghostPath.addLine(to: CGPoint(x: cx + ghostW / 2, y: ghostTop - ghostW / 2))
        ghostPath.addArc(center: CGPoint(x: cx, y: ghostTop - ghostW / 2),
                         radius: ghostW / 2, startAngle: 0, endAngle: .pi, clockwise: false)
        ghostPath.closeSubpath()

        let ghostGrad: [CGFloat] = [
            1.0, 1.0, 1.0, 0.95,
            0.85, 0.82, 0.92, 0.90
        ]
        if let gGrad = CGGradient(colorSpace: colorSpace, colorComponents: ghostGrad,
                                  locations: [0, 1], count: 2) {
            ctx.addPath(ghostPath)
            ctx.clip()
            ctx.drawLinearGradient(gGrad,
                                   start: CGPoint(x: cx, y: ghostTop),
                                   end: CGPoint(x: cx, y: ghostBot),
                                   options: [])
        }
        ctx.restoreGState()

        // --- Eyes ---
        let eyeY = cy + ghostH * 0.05
        let eyeSpacing: CGFloat = 44
        let eyeR: CGFloat = 18
        for dx in [-eyeSpacing, eyeSpacing] {
            let eyeCenter = CGPoint(x: cx + dx, y: eyeY)
            ctx.setFillColor(CGColor(red: 0.15, green: 0.10, blue: 0.30, alpha: 1.0))
            ctx.fillEllipse(in: CGRect(x: eyeCenter.x - eyeR, y: eyeCenter.y - eyeR,
                                       width: eyeR * 2, height: eyeR * 2))
            let pupilR: CGFloat = 6
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
            ctx.fillEllipse(in: CGRect(x: eyeCenter.x - pupilR + 5, y: eyeCenter.y - pupilR + 5,
                                       width: pupilR * 2, height: pupilR * 2))
        }

        // --- Gear overlay (bottom-right of ghost) ---
        drawGear(in: ctx, center: CGPoint(x: cx + 80, y: cy - ghostH * 0.25),
                 outerR: 42, innerR: 28, teeth: 8,
                 color: CGColor(red: 0.55, green: 0.45, blue: 0.95, alpha: 0.9))

        image.unlockFocus()
        return image
    }

    private static func drawGear(in ctx: CGContext, center: CGPoint,
                                 outerR: CGFloat, innerR: CGFloat, teeth: Int,
                                 color: CGColor) {
        ctx.saveGState()
        ctx.setFillColor(color)

        let path = CGMutablePath()
        let toothAngle = (2 * CGFloat.pi) / CGFloat(teeth)
        let halfTooth = toothAngle * 0.3

        for i in 0..<teeth {
            let angle = toothAngle * CGFloat(i) - CGFloat.pi / 2
            let a1 = angle - halfTooth
            let a2 = angle + halfTooth
            let a3 = angle + toothAngle / 2 - halfTooth * 0.4
            let a4 = angle + toothAngle / 2 + halfTooth * 0.4

            let outerP1 = CGPoint(x: center.x + outerR * cos(a1), y: center.y + outerR * sin(a1))
            let outerP2 = CGPoint(x: center.x + outerR * cos(a2), y: center.y + outerR * sin(a2))
            let innerP1 = CGPoint(x: center.x + innerR * cos(a3), y: center.y + innerR * sin(a3))
            let innerP2 = CGPoint(x: center.x + innerR * cos(a4), y: center.y + innerR * sin(a4))

            if i == 0 { path.move(to: outerP1) } else { path.addLine(to: outerP1) }
            path.addLine(to: outerP2)
            path.addLine(to: innerP1)
            path.addLine(to: innerP2)
        }
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()

        ctx.setFillColor(CGColor(red: 0.14, green: 0.10, blue: 0.28, alpha: 1.0))
        ctx.fillEllipse(in: CGRect(x: center.x - innerR * 0.45, y: center.y - innerR * 0.45,
                                   width: innerR * 0.9, height: innerR * 0.9))

        ctx.restoreGState()
    }
}
