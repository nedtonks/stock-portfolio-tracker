/*
 NOTES:
 -> ForEach(Array(displayedStocks.enumera.....
    What this does:
    - When the last card appears (user scrolled to bottom
    - If more stocks exist and not already loading
    - Automatically calls loadMoreStocks() to fetch next 30
 
 -> Visual flow:
     User opens app
       ↓
     onAppear triggers
       ↓
     loadStocks() called
       ↓
     isLoading = true
       ↓
     SwiftUI re-renders → Shows ProgressView("Loading stocks...")
       ↓
     API calls happening (async)
       ↓
     Data received, stocks array updated
       ↓
     isLoading = false
       ↓
     SwiftUI re-renders → Shows ScrollView with stock grid
 
 */
// * main page *

import SwiftUI

struct DashboardView: View{
    @State private var selectedFilter = 0
    @State private var stocks: [Stock] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var allSymbols: [String] = [] // All available symbols
    @State private var loadedStocks: [Stock] = [] //Stocks currently displayed
    @State private var isLoadingMore = false //Track if loading next page
    @State private var currentPage = 0
    @State private var stocksPerPage = 30
    @State private var hasMoreStocks = true
    @State private var isRateLimited = false
    @State private var showRateLimitAlert = false
    
    @AppStorage("autoRefreshMinutes") private var autoRefreshMinutes: Int = 0
    
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    let stockService = StockService()
    let popularStockSymbols: [String] = ["AAPL","MSFT","GOOGL","AMZN","NVDA","BRK.B","META","TSLA","JPM","JNJ","V","UNH","HD","PG","MA","BAC","DIS","XOM","VZ","KO","ADBE","CMCSA","NFLX","PFE","T","PEP","INTC","CSCO","MRK","WMT","COST","ABBV","CRM","ACN","CVX","AVGO","ABT","C","TXN","QCOM","MCD","WBA","UPS","NEE","LLY","DHR","RTX","AMD","LIN","PM","HON","LOW","SBUX","MS","AMT","TMO","INTU","CAT","AMGN","AXP","BLK","SPGI","PLD","BK","CME","DE","GE","GS","EL","ISRG","NOW","ADI","ZTS","MO","PNC","BDX","DUK","CCI","SYK","MDT","DG","CI","CL","AON","SO","TJX","USB","NSC","GILD","ITW","CB","MET","BDX","KMB","SHW","TGT","APD","ADP","MMC","BSX","FIS","FISV","ECL","MCO","GM","LMT","EOG","KMI","ALL","ICE","ETN","SCHW","HUM","VRTX","OXY","RMD","TROW","KLAC","ORLY","PPG","PRU","ADM","WM","CNC","REGN","TRV","AFL","MHK","MAR","LRCX","EA","ES","ROP","DOW","KHC","AIG","ELV","ABB","KEYS","ROST","MKTX","NEM","FTNT","DXC","BLL","CZR","GLW","CPRT","BLL","MLM","PNR","SWK","ANET","NOC","CINF","CMS","HCA","WRB","HBAN","LUV","CF","APH","KR","DLR","AVB","RSG","A","EW","PH","AKAM","NVR","CPB","DHI","IRM","RCL","ZBRA","MSI","MLP","MAS","ESS","PKG","CHTR","F","LHX","TDG","CAG","CBOE","HES","SJM","TT","VLO","CNP","PNW","NU","EXC","PGR","D","MMC","UDR","KSU","LVS","NDAQ","TFC","HAS","STT","VAR","WEC","ALLE","TER","XYL","HPQ","NLOK","JBHT","CFRA","SWKS","URI","AVY","OMC","WY","BBY","FLIR","PWR","NTRS","AEE","SNA","WMB","GL","HRL","NUE","KEY","PNC","FITB","MTB","ZION","CFG","TAP","HSY","UHS","CPS","SYY","DOV","ETR","CPG","TRMB","MTD","SRE","MKC","IFF","SIVB","CRL","BBWI","PAYX","MXIM","POOL","EWBC","PNFP","CMA","HBAN","UAA","LB","NCLH","TPR","DRI","VTR","UDR","HII","CINF","FFIV","AVT","PNC","FITB","CWT","PNM","ATO","PNR","KEY","HBNC","IVZ","NDAQ","CORT","HON","MGM","CFRA","DRE"]
    
    var body: some View {
        NavigationStack{
            VStack{
                VStack{
                    Picker("Filter", selection: $selectedFilter){
                        Text("All").tag(0)
                        Text("Gainers").tag(1)
                        Text("Fallers").tag(2)
                        Text("Settings").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    if selectedFilter == 1 || selectedFilter == 2 {
                        Text(selectedFilter == 1
                             ? "Showing stocks with 2% or more growth today"
                             : "Showing stocks with 2% or more decline today")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.top, 8)
                    }
                }
                .background(Color(UIColor.systemBackground))
                
                if selectedFilter == 3 {
                    SettingsView() //show settings when Settings tab is selected
                } else {
                    if isLoading {
                        Spacer()
                        ProgressView("Fetching live stock data...")
                        Spacer()
                    } else if let error = errorMessage {
                        Text(error)
                    } else {
                        ScrollView{
                            VStack{
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(displayedStocks) { stock in
                                        StockCardView(stock: stock)
                                    }
                                }
                                .padding()
                                
                                Button{
                                    Task{
                                        await loadMoreStocks()
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        if isLoadingMore {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                                .transition(.scale.combined(with: .opacity))
                                        } else {
                                            Image(systemName: "arrow.clockwise")
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                        Text(isLoadingMore ? "Loading more stocks..." : "Load More Stocks")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isLoadingMore ? Color.blue.opacity(0.7) : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .animation(.easeInOut(duration: 0.2), value: isLoadingMore)
                                }
                                .disabled(isLoadingMore)
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
            }
            .alert("⏱️ Rate Limit Reached", isPresented: $showRateLimitAlert){
                Button("OK", role: .cancel) {
                    isRateLimited = false //reset flag
                }
            } message: {
                Text("You've reached the API rate limit (60 calls/minute). Please wait 1 minute before loading more stocks.")
            }
            .onAppear {
                if allSymbols.isEmpty {
                    allSymbols = popularStockSymbols
                }
                Task {
                    await loadStocks()
                }
            }
        }
    }
    
    func loadStocks() async {
            isLoading = true //shows loading spinner
            errorMessage = nil // clears any errors
            currentPage = 0 // resets page to 0
            
            do {
                //get the first batch of symbols (first 30)
                let startIndex = currentPage * stocksPerPage //0*30=0
                let endIndex = min(startIndex + stocksPerPage, allSymbols.count)// min(0 + 30, 200) = 30
                
                //check it we have more symbols to load
                hasMoreStocks = endIndex < allSymbols.count
                
                // get the symbols for this page
                let symbolsToLoad = Array(allSymbols[startIndex..<endIndex])
                
                //fetch the stocks
                let fetchedStocks = try await stockService.fetchStocks(symbols: symbolsToLoad)
                
                //append to loadedStocks (or replace if it's the first load)
                if currentPage == 0 {
                    loadedStocks = fetchedStocks
                } else {
                    loadedStocks.append(contentsOf: fetchedStocks)
                }
                
                //update stocks array (used by displayedStocks)
                stocks = loadedStocks
                
                //increment page for next load
                currentPage += 1
                
            } catch {
                // Check if it's a rate limit error
                if let nsError = error as NSError?, nsError.code == 429 {
                    errorMessage = "Rate limit reached! Finnhub allows 60 API calls per minute. Please wait 1 minute before loading more stocks."
                } else {
                    errorMessage = "Failed to load stocks: \(error.localizedDescription)"
                }
            }
            
            isLoading = false //hide loading spinner
        }
        
        func loadMoreStocks() async {
            guard hasMoreStocks && !isLoadingMore else { return } //only run if more stocks exist and not already loading
            
            isLoadingMore = true
            errorMessage = nil
            isRateLimited = false
            
            do{
                //get next batch
                let startIndex = currentPage * stocksPerPage // 1 * 30 = 30 (next 30 symbols)
                let endIndex = min(startIndex + stocksPerPage, allSymbols.count) // min(30 + 30, 200) = 60
                
                //check it we have more symbols to load
                hasMoreStocks = endIndex < allSymbols.count // 60 < 200 = true
                
                // get the symbols for this page
                let symbolsToLoad = Array(allSymbols[startIndex..<endIndex])
                
                //fetch the stocks
                let fetchedStocks = try await stockService.fetchStocks(symbols: symbolsToLoad)
                
                //append to loadedStocks
                loadedStocks.append(contentsOf: fetchedStocks)
                
                //update stocks array (used by displayedStocks)
                stocks = loadedStocks
                
                //increment page for next load
                currentPage += 1
                
            } catch {
                if let nsError = error as NSError?, nsError.code == 429 {
                    isRateLimited = true
                    showRateLimitAlert = true
                } else {
                    isRateLimited = false
                    errorMessage = "Failed to load stocks: \(error.localizedDescription)"
                }
            }
            
            isLoadingMore = false
        }
        
        var displayedStocks: [Stock] {
            switch selectedFilter {
            case 0: //All
                return stocks
            case 1: //Gainers
                return stocks.filter { $0.changePercent >= 2.0}
                    .sorted { $0.changePercent > $1.changePercent } //highest gain first
            case 2: //Fallers
                return stocks.filter { $0.changePercent <= -2.0}
                    .sorted { $0.changePercent < $1.changePercent } //biggest drop first
            case 3: //settings
                return []
            default:
                return stocks
            }
        }
}

#Preview {
    DashboardView()
}
