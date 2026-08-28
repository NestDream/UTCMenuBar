#!/usr/bin/env swift
// Renders the app icon as code so it can be regenerated and diffed.
// Usage: swift scripts/render-icon.swift <output.png> [size]
//
// Design: macOS squircle (824/1024 grid) in deep night-blue, carrying a clock
// dial whose interior is a globe graticule; the prime meridian (Greenwich,
// i.e. UTC itself) is the single accent-colored line. Hands read 10:09.

import AppKit

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write("usage: render-icon.swift <output.png> [size]\n".data(using: .utf8)!)
    exit(2)
}
let outputPath = args[1]
let canvas: CGFloat = args.count >= 3 ? CGFloat(Double(args[2]) ?? 1024) : 1024

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(canvas), pixelsHigh: Int(canvas),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
) else { fatalError("bitmap alloc failed") }

guard let gctx = NSGraphicsContext(bitmapImageRep: rep) else { fatalError("context failed") }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = gctx
let ctx = gctx.cgContext

// Everything below is specified on the 1024 grid and scaled uniformly.
let s = canvas / 1024
ctx.scaleBy(x: s, y: s)

let center = CGPoint(x: 512, y: 512)

// ---- Squircle plate (Apple icon grid: 824x824 centered, ~22.5% radius) ----
let plateSize: CGFloat = 824
let plateRect = CGRect(x: (1024 - plateSize) / 2, y: (1024 - plateSize) / 2, width: plateSize, height: plateSize)
let plate = NSBezierPath(roundedRect: plateRect, xRadius: 185, yRadius: 185)

// Soft drop shadow (baked in, like Apple's template)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: NSColor.black.withAlphaComponent(0.35).cgColor)
color(0x0B1424).setFill()
plate.fill()
ctx.restoreGState()

// Vertical background gradient inside the plate
ctx.saveGState()
plate.addClip()
let bg = NSGradient(colors: [color(0x1A2B4A), color(0x0B1424)])!
bg.draw(in: plateRect, angle: -90)

// Faint top edge light so the plate does not read as a flat sticker
let edge = NSGradient(colors: [NSColor.white.withAlphaComponent(0.12), NSColor.white.withAlphaComponent(0)])!
edge.draw(in: CGRect(x: plateRect.minX, y: plateRect.maxY - 180, width: plateRect.width, height: 180), angle: -90)

// ---- Dial ----
let dialRadius: CGFloat = 312
let dialRect = CGRect(x: center.x - dialRadius, y: center.y - dialRadius, width: dialRadius * 2, height: dialRadius * 2)

// Graticule, clipped to the dial: two longitude ellipses + equator,
// with the prime meridian as the one accent line.
ctx.saveGState()
NSBezierPath(ovalIn: dialRect).addClip()

let graticule = NSColor.white.withAlphaComponent(0.22)
graticule.setStroke()
for rx in [0.42, 0.78] {
    let p = NSBezierPath(ovalIn: CGRect(
        x: center.x - dialRadius * rx, y: center.y - dialRadius,
        width: dialRadius * 2 * rx, height: dialRadius * 2))
    p.lineWidth = 10
    p.stroke()
}
let equator = NSBezierPath()
equator.move(to: CGPoint(x: center.x - dialRadius, y: center.y))
equator.line(to: CGPoint(x: center.x + dialRadius, y: center.y))
equator.lineWidth = 10
equator.stroke()

// Prime meridian: Greenwich, the line UTC is defined by. Stops short of the
// ring so its rounded tips tuck cleanly under the 12/6 ticks.
let meridian = NSBezierPath()
meridian.move(to: CGPoint(x: center.x, y: center.y - dialRadius + 40))
meridian.line(to: CGPoint(x: center.x, y: center.y + dialRadius - 40))
meridian.lineWidth = 16
meridian.lineCapStyle = .round
color(0x53C7F0).setStroke()
meridian.stroke()
ctx.restoreGState()

// Dial ring
let ring = NSBezierPath(ovalIn: dialRect)
ring.lineWidth = 22
NSColor.white.withAlphaComponent(0.92).setStroke()
ring.stroke()

// Quarter-hour ticks (12/3/6/9), inside the ring
NSColor.white.withAlphaComponent(0.85).setStroke()
for angle in stride(from: 0.0, to: 360.0, by: 90.0) {
    let rad = angle * .pi / 180
    let dir = CGPoint(x: sin(rad), y: cos(rad))
    let tick = NSBezierPath()
    tick.move(to: CGPoint(x: center.x + dir.x * (dialRadius - 30), y: center.y + dir.y * (dialRadius - 30)))
    tick.line(to: CGPoint(x: center.x + dir.x * (dialRadius - 78), y: center.y + dir.y * (dialRadius - 78)))
    tick.lineWidth = 20
    tick.lineCapStyle = .round
    tick.stroke()
}

// ---- Hands at 10:09 (classic balanced watch pose) ----
func hand(angleDegrees: Double, length: CGFloat, width: CGFloat) {
    let rad = angleDegrees * .pi / 180
    let dir = CGPoint(x: sin(rad), y: cos(rad))
    let p = NSBezierPath()
    // Start at the center: the hub covers the joint, and counterweight tails
    // would merge into a blob under it at these stroke widths.
    p.move(to: center)
    p.line(to: CGPoint(x: center.x + dir.x * length, y: center.y + dir.y * length))
    p.lineWidth = width
    p.lineCapStyle = .round
    p.stroke()
}

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 14, color: NSColor.black.withAlphaComponent(0.4).cgColor)
NSColor.white.setStroke()
hand(angleDegrees: -55, length: 178, width: 38)   // hour → 10
hand(angleDegrees: 54, length: 258, width: 30)    // minute → ~09
ctx.restoreGState()

// Hub
NSColor.white.setFill()
NSBezierPath(ovalIn: CGRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60)).fill()
color(0x0B1424).setFill()
NSBezierPath(ovalIn: CGRect(x: center.x - 12, y: center.y - 12, width: 24, height: 24)).fill()

ctx.restoreGState() // plate clip

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else { fatalError("png encode failed") }
try! png.write(to: URL(fileURLWithPath: outputPath))
print("wrote \(outputPath) (\(Int(canvas))x\(Int(canvas)))")
