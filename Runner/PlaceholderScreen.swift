import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    let onBackClick: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(title).font(.headline)
                Spacer()
            }
            .padding()
            Spacer()
            Text(title).font(.title)
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}
