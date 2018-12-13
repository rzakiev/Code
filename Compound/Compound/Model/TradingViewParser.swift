//
//  TradingViewParser.swift
//  Compound
//
//  Created by robert on 27/11/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import Foundation

class TVParser {
    
    let baseUrl: String = "https://www.tradingview.com/symbols/"
    let stock: String
    
    
    init(for stock: String) {
        self.stock = stock
    }
    
    func getPrice(for stock: String) -> Double? {
        let ticker = "MOEX-GMKN"
        let url = URL(string: "https://smart-lab.ru/forum/MOEX")
        print(url!)
        let pageContent: String? = try? String(contentsOf: url!, encoding: .utf8)
//        print(pageContent ?? "No content")
        
        if pageContent != nil {
            let filterText = "<span class=\"temp_micex_info_item\">"
            let endFilter = "<span id=\"up\">"
            if let openSpanRange = pageContent!.range(of: filterText)  {
               let firstIrange = pageContent![openSpanRange.upperBound...]
                if let openingIRange = firstIrange.range(of: "<i>"), let closingIrange = firstIrange.range(of: "</i>") {
                    let priceString = String(pageContent![openingIRange.upperBound..<closingIrange.lowerBound])
                    let price: Double? = Double(priceString) ?? nil
                    return price
                }
            }
        }
        
        return nil
    }
    
}
