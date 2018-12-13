//
//  StockListTableViewController.swift
//  Compound
//
//  Created by Robert Zakiev on 26/08/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import UIKit

class StockListTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    var stockList = Constants.incomeFigures.map({$0.company})
    let stockSections = ConstantIndustries.stockIndustries.keys.sorted()
    
    // MARK: - Inits and VC lifecycle methods
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
        self.tableView.contentInset = adjustForTabbarInsets
        self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = "Акции"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.splitViewController?.preferredDisplayMode = .allVisible
    }
    
   
    
    override func awakeFromNib() {
        splitViewController?.delegate = self //for iPad
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         return ConstantIndustries.stockIndustries.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConstantIndustries.stockIndustries[stockSections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "stockViewSegue", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        cell.textLabel!.text = String(ConstantIndustries.stockIndustries[stockSections[indexPath.section]]!.sorted()[indexPath.row])
        cell.accessibilityIdentifier = "stockListCell\(indexPath.section)\(indexPath.row)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stockSections[section]
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let cell = sender as? UITableViewCell, let svtvc = segue.destination as? StockViewTableViewController {
            svtvc.company = Stock(name: (cell.textLabel?.text)!)
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
   
 

}
