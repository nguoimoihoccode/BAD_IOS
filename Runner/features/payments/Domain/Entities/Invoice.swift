import Foundation

struct Invoice: Identifiable {
    let id: String
    let title: String
    var date: String
    let courtInfo: String
    let amount: Double
    var status: String // "PENDING", "PAID"
}
