/*
NOTES:
'import Foundation'
    Apple's core framework for non-UI essentials: strings, dates, URLs, networking (URLSession), JSON parsing (JSONDecoder), etc

 guard is an early-exit pattern. It checks a condition and exits early if it fails
 */
import Foundation

//Identifiable lets ForEach track each stock uniquely
struct Stock: Identifiable{
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    
    var changePercent: Double{
        guard price - change != 0 else { return 0.0}
        return (change / (price - change)) * 100
    }
}

let sampleStocks: [Stock] = [
    Stock(symbol: "AAPL", name: "Apple Inc", price: 175.50, change: 2.30),
    Stock(symbol: "MSFT", name: "Microsoft", price: 378.85, change: -1.20)
    ]

