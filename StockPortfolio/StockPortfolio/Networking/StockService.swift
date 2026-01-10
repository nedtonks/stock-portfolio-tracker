//
//  StockService.swift
//  StockPortfolio
//
//  Created by Ned Tonks on 29/11/2025.
//

//API Key: 99KE1S949RT9TF4E

import Foundation

class StockService{
    private let apiKey = "d52htmpr01qkgn1bo2v0d52htmpr01qkgn1bo2vg" //API key
    private let baseURL = "https://finnhub.io/api/v1/quote"
    
    private func makeURL(for symbol: String) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "token", value: apiKey)
        ]
        return components?.url
    }
    
    func fetchStock(symbol:String) async throws -> Stock {
        //Step 1. Build the URL
        guard let url = makeURL(for: symbol) else { //safely unwraps the optional url
            throw URLError(.badURL) //if URL is invalid, throw error
        }
        
        //step 2: make the network request
        //(data, response) — tuple: data is the JSON, response is HTTP metadata
        let (data, response) = try await URLSession.shared.data(from: url) //makes http request.
        
        if let rawString = String(data: data, encoding: .utf8){
            print("🔍 Response for \(symbol): \(rawString)")
            
            // Check for rate limit
            if rawString.contains("API call frequency") || rawString.contains("limit") {
                throw NSError(domain: "RateLimitError", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded"])
            }
            
            // Check if response is empty or invalid JSON
            if rawString.isEmpty || rawString == "{}" || rawString == "null" {
                throw NSError(domain: "EmptyResponseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned for \(symbol)"])
            }
        }
        
        //step 3: check if HTTP response is OK (status 200)
        // Check HTTP status first
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Check for rate limit (429)
        if httpResponse.statusCode == 429 {
            throw NSError(domain: "RateLimitError", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded (60 calls/minute)"])
        }

        // Check for 200 OK
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(httpResponse.statusCode)"])
        }
        
        //step 4: Parse JSON
        let quote = try JSONDecoder().decode(FinnhubQuote.self, from: data)
     
        //step 5: Convert to Stock model
            return quote.toStock(symbol: symbol)
        }

    struct FinnhubQuote: Codable{ //codable lets JSONdecoder parse it
        let c: Double? // current price
        let d: Double? // change
        let dp: Double? // percent change (optional, can be nil)
    }

    
        //why loop? -> Alpha Vantage requires one request per symbol Note: This is slow for many stocks. You can optimize later with async let or TaskGroup.
    func fetchStocks(symbols: [String]) async throws -> [Stock] {
        var stocks: [Stock] = []
        
        for symbol in symbols {
            let stock = try await fetchStock(symbol: symbol)
            stocks.append(stock)
        }
        return stocks
    }
}
    
extension StockService.FinnhubQuote{
    func toStock(symbol: String) -> Stock{
        Stock(
            symbol: symbol,
            name: symbol,
            price: c ?? 0.0, //if null, use 0.0 instead
            change: d ?? 0.0
        )
    }
}
