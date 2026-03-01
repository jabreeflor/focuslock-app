import SwiftUI

struct NetworkLinesView: View {
    var body: some View {
        Canvas { context, size in
            // Draw subtle network dots and lines
            let points = generatePoints(in: size, count: 30)
            
            for i in 0..<points.count {
                for j in (i+1)..<points.count {
                    let distance = hypot(points[i].x - points[j].x, points[i].y - points[j].y)
                    if distance < 150 {
                        let opacity = (1 - distance / 150) * 0.08
                        var path = Path()
                        path.move(to: points[i])
                        path.addLine(to: points[j])
                        context.stroke(
                            path,
                            with: .color(.white.opacity(opacity)),
                            lineWidth: 0.5
                        )
                    }
                }
                
                // Draw dots
                let dotRect = CGRect(
                    x: points[i].x - 1.5,
                    y: points[i].y - 1.5,
                    width: 3, height: 3
                )
                context.fill(
                    Path(ellipseIn: dotRect),
                    with: .color(.white.opacity(0.15))
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func generatePoints(in size: CGSize, count: Int) -> [CGPoint] {
        // Deterministic pseudo-random using seed
        var points: [CGPoint] = []
        for i in 0..<count {
            let seed = Double(i)
            let x = ((sin(seed * 12.9898 + 78.233) * 43758.5453).truncatingRemainder(dividingBy: 1.0)).magnitude * size.width
            let y = ((sin(seed * 93.9898 + 16.233) * 23421.6312).truncatingRemainder(dividingBy: 1.0)).magnitude * size.height
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
}

// MARK: - Sparkle Effect

struct SparkleView: View {
    let count: Int
    
    var body: some View {
        Canvas { context, size in
            for i in 0..<count {
                let seed = Double(i)
                let x = ((sin(seed * 45.123 + 12.456) * 98765.4321).truncatingRemainder(dividingBy: 1.0)).magnitude * size.width
                let y = ((sin(seed * 67.890 + 34.567) * 54321.9876).truncatingRemainder(dividingBy: 1.0)).magnitude * size.height
                let sparkleSize = 2.0 + (sin(seed * 3.14) + 1) * 2
                
                // Cross shape sparkle
                var hLine = Path()
                hLine.move(to: CGPoint(x: x - sparkleSize, y: y))
                hLine.addLine(to: CGPoint(x: x + sparkleSize, y: y))
                
                var vLine = Path()
                vLine.move(to: CGPoint(x: x, y: y - sparkleSize))
                vLine.addLine(to: CGPoint(x: x, y: y + sparkleSize))
                
                let opacity = 0.2 + sin(seed) * 0.15
                context.stroke(hLine, with: .color(.white.opacity(opacity)), lineWidth: 0.5)
                context.stroke(vLine, with: .color(.white.opacity(opacity)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }
}
