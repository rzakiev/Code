//
//  StockViewTableViewController.swift
//  Compound
//
//  Created by Robert Zakiev on 26/08/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import UIKit

class StockViewTableViewController: UITableViewController {
    
    var company: Stock?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = company?.name ?? ""
        fetchMarketCapitalization() //get market capitalization for the second table view section
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UI_USER_INTERFACE_IDIOM() != .pad { self.tabBarController?.tabBar.isHidden = true } //don't hide the tab bar on the iPad
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false //display tab bar when returning to the stock list VC
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if company == nil {return 0}
        else if ConstantsProduction.productionFigures.contains(where: {$0.companyName == company!.name}) { return 3 }
        else { return 2 }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if company == nil { return 0 }
        else {
            switch section {
            case 0:
                return company!.financialIndicators.count
            case 1:
                return 5
            case 2:
                return ConstantsProduction.productionFigures.first(where: {$0.companyName == company!.name})!.production.count
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockViewCell", for: indexPath) as! StockViewCell
        cell.detailTextLabel?.text = ""
        cell.accessoryView = nil
        

        for subview in cell.contentView.subviews {
            if subview.isKind(of: UIView.self)  { subview.removeFromSuperview() }
        }
        
        switch indexPath.section {
        case 0: //The first section contains the financial figures
            if let chartData = company?.financialIndicators {
                cell.prepareCell(indicator: chartData[indexPath.row].indicator, values: chartData[indexPath.row].figures, numberOfChartsWanted: 5, company: company!)
            } else { print("Unable to load data") }
        
        case 1: //The second section contains the company's multipliers
            cell.prepareMultipliersFor(company: company!, cellNumber: indexPath.row)
            
        case 2: //The second section contains production figures
            let productionCellData = ConstantsProduction.productionFigures.first(where: {$0.companyName == company!.name})!
            cell.prepareCell(indicator: productionCellData.production[indexPath.row].produceName, values: productionCellData.production[indexPath.row].produce, numberOfChartsWanted: 5, company: company!)
            
        default:
            print("WHY MORE THAN THREE BRO???")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if company!.hasProductionFigures && (indexPath.section == 0 || indexPath.section == 2) {
            
            switch UI_USER_INTERFACE_IDIOM() {
            case .phone: return (self.tableView.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0)) / 2
            case .pad: return (self.tableView.frame.height / 4)
            default: return UITableView.automaticDimension
            }
            
        } else {
            if indexPath.section == 0 {
                switch UI_USER_INTERFACE_IDIOM() {
                case .phone: return (self.tableView.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0)) / 2
                case .pad: return (self.tableView.frame.height / 4)
                default: return UITableView.automaticDimension
                }
            } else { return UITableView.automaticDimension }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if company!.hasProductionFigures {
            switch section {
            case 0: return "ФИНАНСОВЫЕ ПОКАЗАТЕЛИ (млрд.)"
            case 1: return "Мультипликаторы"
            case 2:
                if let title = ConstantsProduction.productionFigures.first(where: {$0.companyName == company?.name})!.unitOfMeasureMent {
                    return "НАТУРАЛЬНЫЕ ПОКАЗАТЕЛИ (\(title))"
                } else { return "НАТУРАЛЬНЫЕ ПОКАЗАТЕЛИ" }
            default: return ""
            }
            
        } else {
            if section == 0 {  return "ФИНАНСОВЫЕ ПОКАЗАТЕЛИ (млрд.)" }
            else {  return "Мультипликаторы" }
        }
    }
    
    //MARK: - Asynchronously fetching the market captialization of the company
    
    func fetchMarketCapitalization() {
        DispatchQueue.global().async {
            if let company = self.company, let price = company.getPrice(), let shares = company.sharesIssued {
                company.marketCapitalization = price * Double(shares)
                
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1), IndexPath(row: 1, section: 1), IndexPath(row: 2, section: 1)], with: .automatic)
                }
            }
        }
    }

    

}
