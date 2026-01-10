# Stock Portfolio Tracker

An iOS app built with SwiftUI that tracks stock prices in real-time using the Finnhub API

## Features
- Real-time stock price tracking
- Filter by Gainers (stocks with +2% growth) and Fallers (stocks with +2% decline)
- Light/Dark mode support (default system settings)
- Clean, minimalistic UI to remove unnecessary information/clutter
- Load more stocks button, to not overload the system but still allow the user to browse more options

## Tech Stack
- **Language:** Swift
- **UI Framework:** SwiftUI
- **API:** Finnhub (stock market data)
- **Platform:** iOS

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Finnhub API key (free tier available)

## Setup

1. Clone this repository
2. Open `StockPortfolio.xcodeproj` in Xcode
3. Add Finnhub API key in `StockService.swift`
    API KEY: 'd52htmpr01qkgn1bo2v0d52htmpr01qkgn1bo2vg'
4. Build and run on simulator or device

## API Rate Limits

Finnhub free tier: 60 API calls per minute. The app handles rate limiting with user-friendly error messages.

## Author

**Ned Tonks**
- Email: nedtonks@gmail.com
- LinkedIn: [Ned Tonks](https://www.linkedin.com/in/ned-tonks-355936221/)
- GitHub: [@nedtonks](https://github.com/nedtonks)

## License

This project is for educational purposes.

## Acknowledgments

- Stock data provided by [Finnhub](https://finnhub.io)
