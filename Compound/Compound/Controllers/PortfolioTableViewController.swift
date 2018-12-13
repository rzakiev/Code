//
//  PortfolioTableViewController.swift
//  Compound
//
//  Created by robert on 02/10/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import UIKit


class PortfolioTableViewController: UITableViewController {
    
    var portfolio = Portfolio()
    
    override func viewWillAppear(_ animated: Bool) {
        updatePrices()
    }
    

    override func viewDidLoad() {
        //EXPERIMENT
        tableView.allowsSelection = false
        
        self.navigationItem.title = "Портфолио"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        if portfolio.securities.count == 0 , let localPortfolio = Portfolio.loadFromStorage() { //check if there's a portfolio in the local storage
            portfolio = localPortfolio
            tableView.reloadData()
        } else {
            print("Didn't load portfolio! Securities: \(portfolio.securities.count) ")
        }
        
        updatePrices()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ((segue.destination as! UINavigationController).children[0] as! NewPositionViewController).previousController = self
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return portfolio.securities.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return portfolio.securities[section].stakes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var securityName = "\(portfolio.securities[section].name!) "
        securityName.append(String(format: "%.1f", portfolio.securities[section].securityGrossStakesValuation()/portfolio.portfolioPrice*100))
        securityName.append("%")
        securityName.append(" (₽\(simplify(number:portfolio.securities[section].securityGrossStakesValuation())))")
        securityName.append(" (Ср. цена: \(simplify(number: portfolio.securities[section].averagePrice())))")
//        securityName.append(" \()")
        return securityName
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        //STAKE COST
        let cellText = simplify(number: Double (portfolio.securities[indexPath.section].stakes[indexPath.row].numberOfShares))
        cell.textLabel?.text = "\(cellText) акций по ₽\(String(format: "%0.02f",portfolio.securities[indexPath.section].stakes[indexPath.row].atPrice)) (₽\(simplify(number: portfolio.securities[indexPath.section].stakes[indexPath.row].valuation)))"
        
        //STAKE MARK-TO-MARKET VALUATION
        var cellDetailText = simplify (number: portfolio.securities[indexPath.section].stakes[indexPath.row].markToMarketValuation ?? 0)
        cellDetailText.append(" (\(String(format: "%.3f", portfolio.securities[indexPath.section].stakes[indexPath.row].stakeCostToMarket ?? ""))%)")
        cell.detailTextLabel?.text = "Рыночная Стоимость: ₽\(cellDetailText)"

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            print(portfolio.securities[indexPath.section].stakes.remove(at: indexPath.row))
            
            UIView.animate(withDuration: 0.3, delay: 0,
                                       options: [], animations: {
                                       
                                        tableView.beginUpdates()
                                        tableView.deleteRows(at: [indexPath], with: .right)
                                        
                                        if self.portfolio.securities[indexPath.section].stakes.count == 0 {
                                            self.portfolio.securities.remove(at: indexPath.section)
                                            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .right)
                                        }
                                        tableView.endUpdates()
                                        self.portfolio.sortStakesAndSecurities()
                                        self.portfolio.saveToStorage()
            }, completion: { _ in
                    tableView.reloadData()})
            
            if self.portfolio.securities.count == 0 {
                let alert = UIAlertController(title: "Удачи с бондами :)", message: "В долгосрочной перспективе акции дают наибольшую доходность!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Долой волатильность!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    //MARK: - Adding a new stake and updating prices
    
    func addNew(stake: Security) {
        var didFind = false
        for i in 0..<portfolio.securities.count {
            if portfolio.securities[i].name == stake.name {
                portfolio.securities[i].stakes.append(Stake(shares: stake.stakes[0].numberOfShares, priced: stake.stakes[0].atPrice))
                didFind = true
            }
        }
        if !didFind { portfolio.securities.append(Security(name: stake.name, stakes: [Stake(shares: stake.stakes[0].numberOfShares, priced: stake.stakes[0].atPrice)])) }
        portfolio.sortStakesAndSecurities()
        portfolio.saveToStorage()
        tableView.reloadData()
        updatePrices()
    }
    
    func updatePrices() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator) //indicate to the user that the prices are being updated
        
        DispatchQueue.global().async { //asynchronously update the prices for each stake
            for i in 0..<self.portfolio.securities.count {
                for j in 0..<self.portfolio.securities[i].stakes.count {
                    if let price = self.portfolio.securities[i].getPrice() {
                    self.portfolio.securities[i].stakes[j].markToMarketValuation = price * Double(self.portfolio.securities[i].stakes[j].numberOfShares)
                    }
                }
            }
            
            DispatchQueue.main.async { //hide the activity indicator and update the table with freshly fetched prices
                activityIndicator.stopAnimating()
                self.navigationItem.leftBarButtonItem = self.editButtonItem
                self.tableView.reloadData()
            }
        }
    }
    
   
}
