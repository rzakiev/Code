//
//  Portfolio.swift
//  Compound
//
//  Created by Robert Zakiev on 21/09/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import Foundation

//MARK: - Ancillary Stake Struct
struct Stake: Codable {
    
    let numberOfShares: Int
    let atPrice: Double
    var valuation: Double {
        return Double(numberOfShares) * atPrice
    }
    var markToMarketValuation: Double? = nil
    var stakeCostToMarket: Double? {
        if markToMarketValuation != nil {
            return (1 - valuation / markToMarketValuation!) * 100
        }
        else { return nil }
    }
    
    init(shares: Int, priced: Double) {
        numberOfShares = shares
        atPrice = priced
    }
    
    static func >(lhs: Stake, rhs: Stake) -> Bool {
        return lhs.valuation > rhs.valuation
    }
}

//MARK: - Portfolio Company
struct Security: CustomStringConvertible, Codable {
    
    var description: String {
        return "Stock: \(String(describing: self.name))\n Number of shares: \(self.stakes[0].numberOfShares) priced at: \(self.stakes[0].atPrice)"
    }
    
    let name: String!
    var stakes: [Stake]
    var smartLabLink: String? { return SmartLablinks.allLinks.first(where: {$0.stock == name})?.link}
    
    func securityGrossStakesValuation() -> Double {
        var valuation = 0.0
        for stake in stakes {
            valuation += stake.valuation
        }
        return valuation
    }
    
    func averagePrice() -> Double {
        var numberOfShares = 0
        stakes.map({numberOfShares += $0.numberOfShares})
        return securityGrossStakesValuation() / Double(numberOfShares)
    }
    
    var grossMarketValuation: Double? {
        var valuation = 0.0
        for stake in stakes {
            if stake.markToMarketValuation != nil {
                valuation += stake.markToMarketValuation!
                return valuation
            } else { return nil }
        }
        return nil
    }
    
    static func >(lhs: Security, rhs: Security) -> Bool {
        return lhs.securityGrossStakesValuation() > rhs.securityGrossStakesValuation()
    }
}

//MARK: - Portfolio Class
class Portfolio: Codable {
    
    var securities: [Security] = []// all stocks within a portfolio
    
    var portfolioPrice: Double {
        var portfolioPriceTemp = 0.0
        for security in securities {
            portfolioPriceTemp += security.securityGrossStakesValuation()
        }
        return portfolioPriceTemp
    }
    
    var grossMarketValuation: Double? {
        var valuation = 0.0
        for stock in securities {
            if stock.grossMarketValuation != nil {
                valuation += stock.grossMarketValuation!
                return valuation
            } else { return nil }
        }
        return nil
    }
    
    init() {
        sortStakesAndSecurities()
    }
    //sorting stocks by their valuation
    func sortStakesAndSecurities() {
        for i in 0..<securities.count { securities[i].stakes.sort(by: {$0 > $1}) }
        securities.sort(by: {$0 > $1})
    }
    
    //Saving the portfolio to the local storage for persistence
    func saveToStorage() {
        let url = (try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)).appendingPathComponent("portfolio.json")
        
        let encodedStake = try? JSONEncoder().encode(self)
        
        do { try encodedStake?.write(to: url) }
        catch { print(error) }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let _ = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    //loading the local portfolio from the local storage when launching the app for the first time
    class func loadFromStorage() -> Portfolio? {
        let url = (try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)).appendingPathComponent("portfolio.json")
        if ((try? url.checkResourceIsReachable()) ?? false) {
            let data = try? Data(contentsOf: url)
            if let json = data {
                let portfolio = try! JSONDecoder().decode(Portfolio.self, from: json)
                return portfolio
            }
            
        } else {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                // process files
            } catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
            print("Unable load portfolio")
        }
        return nil
    }
}



extension Security {
    
    func getPrice() -> Double? {
        if let link = smartLabLink {
            let url = URL(string: link)
            let pageContent: String? = try? String(contentsOf: url!, encoding: .utf8)
            
            if pageContent != nil {
                let filterText = "<span class=\"temp_micex_info_item\">"
                if let openSpanRange = pageContent!.range(of: filterText)  {
                    let firstIrange = pageContent![openSpanRange.upperBound...]
                    if let openingIRange = firstIrange.range(of: "<i>"), let closingIrange = firstIrange.range(of: "</i>") {
                        let priceString = String(pageContent![openingIRange.upperBound..<closingIrange.lowerBound])
                        let price: Double? = Double(priceString) ?? nil
                        return price
                    }
                }
            }
        }
        return nil
    }
    
    
}
