//
//  StockClass.swift
//  Compound
//
//  Created by Robert Zakiev on 02/07/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import Foundation

//MARK: - Ancillary nums and Structs for the Stock class
enum StockType {
    case regular
    case cyclical
    case holding
}

struct FinancialFigure {
    let year: Int
    let value: Double
}

struct FinancialIndicator {
    let indicatorName: String
    let financialIndicators: [FinancialFigure]
}

struct Company {
    let companyName: String
    let financialIndicators: [FinancialIndicator]
}

//MARK: - STOCK CLASS INTERFACE
class Stock {
    
    let name:String //name of the referent company
    var financialIndicators: [(indicator: String, figures: [(year: Int, value: Double)])] = []
    
    let financialStatements: [(year: Int, url: String)] = []
    
    let shareholderStructure = [(shareHolder: String, stake: Double)]()
    let sharesIssued: Int?
    let dividendPolicy: String?
    let businessSustainability: String?
    var marketCapitalization: Double? = nil
    
    
    
    var hasProductionFigures: Bool {
        if ConstantsProduction.productionFigures.first(where: {$0.companyName == self.name}) != nil { return true }
        else { return false }
    }
    
    
    init(name:String) {
        self.name = name
        self.dividendPolicy = ConstantDividend.dividendPolicyList[name] ?? nil
        self.businessSustainability = ConstantsSustainability.businessSustainability.first(where: {$0.company == name})?.sustainability ?? nil
        self.sharesIssued = ConstantsSharesIssued.sharesIssued.first(where: {$0.company == name})?.shares ?? nil
        
        //Load the figures from the constants
        let companyData = Constants.incomeFigures.first(where: {$0.company == name})!.indicators
        
        //adding revenue figures
        if let revenue = companyData.first(where: {$0.indicator == "revenue"}) { financialIndicators.append(revenue) }
        
        //adding ebitda and oibda
        if let ebitda = companyData.first(where: {$0.indicator == "ebitda"}) { financialIndicators.append(ebitda) }
        else if let oibda = companyData.first(where: {$0.indicator == "oibda"}) { financialIndicators.append(oibda)}
        
        //adding profit
        if let profit = companyData.first(where: {$0.indicator == "profit"}) { financialIndicators.append(profit) }
        
        //adding dividend
        if var notAdjustedForTaxDividend = companyData.first(where: {$0.indicator == "dividend"}) {
            for i in 0..<notAdjustedForTaxDividend.figures.count { notAdjustedForTaxDividend.figures[i].value *= 0.87 }
            financialIndicators.append(notAdjustedForTaxDividend)
        }
        
        //Adding debt to ebitda
        if companyData.first(where: {$0.indicator == "debt"}) != nil &&  operatingIncome != nil {
            financialIndicators.append(("debtToOibda", debtToEBITDA()!))
        }
    }
}

//MARK: - CONVENICENCE METHODS AND VARIABLES
extension Stock {
    
    var revenue: (indicator:String, figures: [(year: Int, value: Double)])? {
        return financialIndicators.first(where: {$0.indicator == "revenue"}) ?? nil
    }
    
    var operatingIncome: (indicator:String, figures: [(year: Int, value: Double)])? {
        return financialIndicators.first(where: {$0.indicator == "ebitda"}) ?? financialIndicators.first(where: {$0.indicator == "oibda"}) ?? nil
    }
    
    var profit: (indicator:String, figures: [(year: Int, value: Double)])? {
        return financialIndicators.first(where: {$0.indicator == "profit"}) ?? nil
    }
    
    var dividend:(indicator:String, figures: [(year: Int, value: Double)])? {
        return financialIndicators.first(where: {$0.indicator == "dividend"}) ?? nil
    }
    
    var debt:(indicator: String, figures: [(year: Int, value: Double)])? {
        return financialIndicators.first(where: {$0.indicator == "debt"}) ?? nil
    }

    var estimatedValue: Double? {
        if let profit = self.profit { return profit.figures.last!.value * 10}
        else { return nil }
    }

    func debtToEBITDA() -> [(year: Int, value: Double)]? {
        
        if let ebitda = self.operatingIncome, let debt = Constants.incomeFigures.first(where: {$0.company == name})!.indicators.first(where: {$0.indicator == "debt"}) {
            
            var debtToEbitda = [(year: Int, value: Double)]()
            
            for i in 0..<ebitda.figures.count {
                let value = debt.figures[i].value / ebitda.figures[i].value
                debtToEbitda.append((ebitda.figures[i].year, value))
            }
            
            return debtToEbitda
        } else {
            return nil
        }
    }

    func dividendToProfit() -> [(year: Int, value: Double)]? {
        
        if let dividend = self.dividend, let profit = self.profit {
            
            var dividendToProfit = [(year: Int, value: Double)]()
            
            for i in 0..<dividend.figures.count {
                let value = dividend.figures[i].value / profit.figures[i].value * 100
                dividendToProfit.append((dividend.figures[i].year, value))
            }
            return dividendToProfit
        } else {
            return nil
        }
    }
}

//MARK: - CLASS METHODS FOR FETCHING GROWTH FIGURES AND MARKET CAP
extension Stock {
    
    class func growthRate (figures: [(year: Int, value: Double)]) -> [(year: Int, growth: Double)] {
        
        var growthRate = [(year: Int, growth: Double)]()
        for i in 1..<figures.count {
            growthRate.append((figures[i].year, ((figures[i].value / figures[i-1].value - 1)) * 100))
        }
        return growthRate
    }
    
    class func grossGrowth (figures: [(year: Int, value: Double)]) -> Double? {
        
        let firstNonNegativeFigure = figures.first(where: {$0.value > 0})?.value
        
        if firstNonNegativeFigure != nil {return (figures[figures.count-1].value / firstNonNegativeFigure! - 1) * 100}
        else { return nil }
    }
    
    func getPrice() -> Double? {
        if let link = SmartLablinks.allLinks.first(where: {$0.stock == name})?.link {
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
