/* * touch point when user clicks on stock *
 NOTES:
 - Content to show:
    > Ticker + company name
    > Price and daily change (colour green/red)
    > Realtime graph
 
 alignment: .leading = left-align
 spacing: 12 = space between VStack children
 specifier: "%.2f" = format to 2 decimal places
 stock.change >= 0 ? .green : .red = ternary operator (if positive green, else red)
 

 */
//

import SwiftUI

struct StockCardView: View {
    let stock: Stock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            VStack(alignment: .leading, spacing: 4){
                Text(stock.symbol)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(stock.name)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text("$\(stock.price, specifier: "%.2f")")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                // Change (green if positive, red if negative)
                HStack {
                    Text("\(stock.change >= 0 ? "+" : "")$\(stock.change, specifier: "%.2f")")
                        .foregroundColor(stock.change >= 0 ? .green : .red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // Makes card fill width
        .padding()  // Inside padding
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
