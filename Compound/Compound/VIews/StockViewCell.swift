//
//  StockChartView.swift
//  Compound
//
//  Created by Robert Zakiev on 25/08/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import UIKit

class StockViewCell: UITableViewCell {
    
    //for multipliers
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var company: Stock? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Analyzes the provided data and then draws the charts based on the data
    func prepareCell(indicator: String, values: [(year: Int, value: Double)], numberOfChartsWanted: Int, company: Stock) {
        self.textLabel?.text = nil
        
        let cellHeight = self.bounds.height
        let cellWidth = self.bounds.width
        
        let testLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        testLabel.text = "(+47%)"
        testLabel.sizeToFit()
    
        let chartWidth = testLabel.bounds.width
        let maxChartHeight = cellHeight * 0.7
        let topBottmoMargin = cellHeight * 0.15
        let maxFigure = values.max {a, b in a.value < b.value}!
        
        let numberOfChartsAvailable = numberOfChartsWanted > values.count ? 0 : values.count - numberOfChartsWanted
        let properIndicators = values.suffix(from: numberOfChartsAvailable)
        let interChartInterval = (cellWidth - chartWidth*5)/6
        var xOffset = interChartInterval - chartWidth
        
        let growthRate = Stock.growthRate(figures: values)
        
        var counter = 0
        for tuple in properIndicators {
            
            let height = tuple.value <= 0 ? 15 : maxChartHeight * abs(CGFloat(tuple.value / maxFigure.value))
            let chartSize = CGSize(width: chartWidth, height: height)
            let y = topBottmoMargin + maxChartHeight - chartSize.height
    
            let chartOrigin = CGPoint(x: self.bounds.minX + xOffset + chartWidth, y: y)
            
            let chart = UIView(frame: CGRect(origin: chartOrigin, size: chartSize))

            //PREPARING THE YEAR LABEL
            let yearLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            yearLabel.text = "\(tuple.year)"
            yearLabel.sizeToFit()
            yearLabel.center.x = chart.center.x
            yearLabel.center.y = cellHeight - (cellHeight - chart.frame.maxY) / 2
            
            //PREPARING THE VALUE LABEL
            let valueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            valueLabel.text = ("\(String(format: "%.1f", tuple.value))")
            if valueLabel.text!.hasSuffix(".0") { valueLabel.text = String(valueLabel.text!.dropLast(2)) }
            valueLabel.sizeToFit()
            valueLabel.center.y = chart.center.y
            valueLabel.center.x = chart.center.x
            
            if counter == 0 && tuple.value > 0 && valueLabel.bounds.height < chart.bounds.height { chart.backgroundColor = UIColor.green }
            //PREPARING THE GROWTH LABELS AND COLORING THE CHART
            let growthLabel = UILabel(frame: CGRect(x: valueLabel.frame.minX, y: valueLabel.frame.maxY + 2, width: chart.bounds.width, height: 20))
            if counter > 0 {
                if tuple.value > 0 { chart.backgroundColor = values[counter].value >= values[counter-1].value ? UIColor.green : UIColor.red }
                
                let growthNumber = ((growthRate[counter-1].growth).isNaN || (growthRate[counter-1].growth).isInfinite) ? 0.0 : growthRate[counter-1].growth
                
                if growthNumber >= 100 && values[counter].value > 0 && values[counter-1].value > 0 { growthLabel.text = "(x\(String(format: "%.1f", growthNumber/100 + 1)))" }
                else {
                    if values[counter].value > 0 && values[counter-1].value > 0 {
                        growthLabel.text = ("(\(growthNumber > 0 ? "+" : "")\(String(format: "%.0f", growthNumber))%)")
                    }
                }
                growthLabel.sizeToFit()

                growthLabel.center.x = valueLabel.center.x
            }
            
            //Moving the value label upward if the chart cannot fit it
            if  valueLabel.bounds.height*3 > chart.bounds.height && counter > 0 && tuple.value > 0 {
                valueLabel.frame.origin.y -= valueLabel.bounds.height*3
                growthLabel.frame.origin.y -= valueLabel.bounds.height*3
            }


            //ADDING SUBVIEWS
            self.contentView.addSubview(chart)
            self.contentView.addSubview(yearLabel)
            self.contentView.addSubview(valueLabel)
            if growthLabel.text != nil { self.contentView.addSubview(growthLabel) }
            
            xOffset += interChartInterval + chartWidth
            counter += 1
        }
        
        // PREPARING THE INDICATOR LABEL
        let growthNumber = Stock.grossGrowth(figures: Array(properIndicators))
        let indicatorLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.minY + 10, width: 20, height: 20))
        let text: String
        
        //Simplifying the growth number
        if let number = growthNumber {
            if number >= 100 { text = "(x\(String(format: "%.1f", number/100 + 1)))" }
            else { text = "(\(number > 0 ? "+" : "")\(String(format: "%.0f", number))%)" }
        } else {text = ""}
        
        switch indicator {
        case "revenue" : indicatorLabel.text = "Выручка "
        case "oibda" : indicatorLabel.text = "OIBDA "
        case "ebitda" : indicatorLabel.text = "EBITDA "
        case "profit" : indicatorLabel.text = "Чистая прибыль "
        case "dividend" : indicatorLabel.text = "Дивиденды "
        case "debtToOibda" : indicatorLabel.text = "Чистый долг / EBITDA "
        default:
            indicatorLabel.text = indicator + " "
        }
        indicatorLabel.text?.append(text)
        indicatorLabel.sizeToFit()
        indicatorLabel.center.x = self.bounds.midX
        self.contentView.addSubview(indicatorLabel)
    }
    
    
    //Preparing multipliers for the second section
    func prepareMultipliersFor(company: Stock, cellNumber:Int) {
        self.company = company
    
        //Adding acitivty indicators while the market cap is being fetched
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.center.y = self.contentView.center.y
        activityIndicator.center.x = self.contentView.bounds.maxX - 20
        
        //To determine if the market cap can be fetched
        let isPublic = SmartLablinks.allLinks.first(where: {$0.stock == company.name})?.link != nil && company.sharesIssued != nil
        
        //Configuring the cell's text labels
        switch cellNumber {
        case 0:
            self.textLabel?.text = "Капитализация"
            if !isPublic { self.detailTextLabel?.text = "—" }
            else { self.accessoryView = activityIndicator }
        case 1:
            self.textLabel?.text = "Прибыль / Капит-я"
            if !isPublic { self.detailTextLabel?.text = "—" }
            else { self.accessoryView = activityIndicator }
        case 2:
            self.textLabel?.text = "Див. доходность"
            if !isPublic {
                self.detailTextLabel?.text = "— "
            }
            else { self.accessoryView = activityIndicator }
        case 3:
            self.textLabel?.text = "Устойчивость бизнеса"
            self.detailTextLabel?.text = company.businessSustainability ?? "—"
        case 4:
            self.textLabel?.text = "Финансовая Отчетность"
            addFinancialReportInfoButton()
            
        default:
            print("The indexpath.row exceeds 4 for some reason")
        }
        
        if company.marketCapitalization != nil && [0,1,2].contains(cellNumber) {
            self.detailTextLabel?.text = String(getTextForDetailLabel(in: cellNumber, for: company))
            if cellNumber == 2 {  //the dividend cell (2) needs an info button to display the dividend policy
                addDividendPolicyInfoButton()
                self.detailTextLabel?.text = self.detailTextLabel!.text! + " "
            }
            else { self.accessoryView = nil }
        }
    }
    
    
    func getTextForDetailLabel (in row: Int, for company: Stock) -> String {
        
        switch row {
        case 0: //market cap
            var finalString: String
            switch company.marketCapitalization! {
            case 1000..<1000000: finalString = "\(String(format: "%.1f",company.marketCapitalization!/1000)) K"
            case 1000000..<1_000_000_000: finalString = "\(String(format: "%.3f",company.marketCapitalization!/1000000)) M"
            case 1_000_000_000..<1_000_000_000_000 : finalString = "\(String(format: "%.2f",company.marketCapitalization!/1000000000)) B"
            case 1_000_000_000_000... : finalString = "\(String(format: "%.3f",company.marketCapitalization!/1000000000000)) T"
            default:
                finalString = String(format: "%.1f", company.marketCapitalization!)
            }
            
            if finalString.hasSuffix(".0") { finalString.removeSubrange(finalString.range(of: ".0")!) }
            return finalString
            
        case 1: //earnings / market capitalization
            if let lastProfit = company.profit?.figures.last?.value {
                let earningsDividedByMarketCap = lastProfit * 1_000_000_000 / company.marketCapitalization! * 100
                return String(format: "%.1f", earningsDividedByMarketCap) + " %"
            }
        case 2: //dividend yield
            if let lastDividend = company.dividend?.figures.last?.value {
                let dividendDividedByMarketCap = lastDividend * 1_000_000_000 / company.marketCapitalization! * 100
                return String(format: "%.1f", dividendDividedByMarketCap) + " %"
            }
        default:
            print("Fetching detail labels for row: \(row)")
        }
        return "Fetching detail labels for row: \(row)"
    }
    
    
    //MARK: - FINANCIAL REPORT DETAIL BUTTON METHODS
    func addFinancialReportInfoButton() {
        let infoButton = UIButton(type: .infoLight)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (displayFinancialReportActionSheet))
        tapRecognizer.numberOfTouchesRequired = 1
        infoButton.addGestureRecognizer(tapRecognizer)
        infoButton.isUserInteractionEnabled = true
        self.accessoryView = infoButton
    }
    
    @objc func displayFinancialReportActionSheet() {
        let actionSheet = UIAlertController(title: "Финансовая отчётность", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "2015", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "2016", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "2017", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - DIVIDENT POLICY DETAIL BUTTON METHODS
    func addDividendPolicyInfoButton() {
        let infoButton = UIButton(type: .infoLight)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (displayDividendPolicyReport))
        tapRecognizer.numberOfTouchesRequired = 1
        infoButton.addGestureRecognizer(tapRecognizer)
        infoButton.isUserInteractionEnabled = true
        self.accessoryView = infoButton
        
        self.accessoryView!.layoutMargins = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
    }
    
    @objc func displayDividendPolicyReport() {
        let actionSheet = UIAlertController(title: "Дивидендная Политика", message: company!.dividendPolicy ?? nil, preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
}
