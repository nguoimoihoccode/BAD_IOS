import SwiftUI

struct ResponsiveContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        GeometryReader { geo in
            content
                .frame(maxWidth: min(geo.size.width, 1050))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
