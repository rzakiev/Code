//
//  NewPositionTableViewController.swift
//  Compound
//
//  Created by robert on 06/10/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import UIKit
import SafariServices

class NewPositionViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Interface Builder outlets and actions
    @IBOutlet weak var numerOfSharesTextField: UITextField!
    
    @IBAction func didStartEditingNumberOfSharesTextField(_ sender: UITextField) {
    }
    @IBAction func numberOfSharesTextChanged(_ sender: UITextField) {
        if Int(sender.text!) == nil {
            sender.text! = String(sender.text!.dropLast(1))
        }
    }
    
    @IBAction func sharePriceTextChanged(_ sender: UITextField) {
        if Double(sender.text!) == nil {
            sender.text! = String(sender.text!.dropLast(1))
        }
    }
    
    @IBOutlet weak var sharePriceTextField: UITextField!
    @IBOutlet weak var stockPickerView: UIPickerView!
    @IBOutlet weak var brokerageFeePickerView: UIPickerView!
    
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        tableView.endEditing(true)
        processEnteredData()
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Class Properties
    var previousController: PortfolioTableViewController? = nil
    
    var feePickerData = BrokerFees.fees
    let stockNames = Constants.incomeFigures.map({$0.company}).sorted()
    
    //MARK: - VC Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<feePickerData.count { feePickerData[i].fees.sort(by: {$0 > $1}) }
        
        brokerageFeePickerView.dataSource = self
        brokerageFeePickerView.delegate = self
        stockPickerView.dataSource = self
        stockPickerView.delegate = self
        
        let numberOfSharestoolbar = UIToolbar()
        let numberOfSharesdoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(numberOfSharesEntered))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        numberOfSharestoolbar.setItems([flexibleSpace, numberOfSharesdoneButton], animated: true)
        numberOfSharestoolbar.sizeToFit()
        numerOfSharesTextField.inputAccessoryView = numberOfSharestoolbar
        
        let sharePriceToolbar = UIToolbar()
        let sharePricedoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sharePriceEntered))
        sharePriceToolbar.setItems([flexibleSpace, sharePricedoneButton], animated: true)
        sharePriceTextField.inputAccessoryView = sharePriceToolbar
        sharePriceToolbar.sizeToFit()
        
        self.navigationItem.title = "Новая Позиция"

    }
    
    // MARK: - Picker View methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.accessibilityLabel! {
        case "feeLabel": return 2
        case "stockLabel": return 1
        default:
            return 0
        }
        
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.accessibilityLabel! {
        case "feeLabel":
            if component == 0 { return feePickerData.count}
            else {
                return feePickerData[brokerageFeePickerView.selectedRow(inComponent: 0)].fees.count
            }
        case "stockLabel": return stockNames.count
        default:
            return 0
        }
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.accessibilityLabel! {
        case "feeLabel": if component == 0 { return feePickerData[row].broker } else { return String(feePickerData[brokerageFeePickerView.selectedRow(inComponent: 0)].fees[row]) + "%" }
        case "stockLabel": return stockNames[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 { brokerageFeePickerView.reloadComponent(1) }
    }
    
    // MARK: - Handling Keyboard Events
    @objc func numberOfSharesEntered() { sharePriceTextField.becomeFirstResponder() }
    @objc func sharePriceEntered() { tableView.endEditing(true) }
    
    //MARK: - Processing Entered Data

    func processEnteredData() {
        if numerOfSharesTextField.text == "" {
            let alert = UIAlertController(title: "Введите кол-во купленных акций", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if sharePriceTextField.text == "" {
            let alert = UIAlertController(title: "Введите цену купленных акций", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let stockName = stockNames[stockPickerView.selectedRow(inComponent: 0)]
            let numberOfShares = Int(numerOfSharesTextField.text!)!
            var pricedAt = Double(NumberFormatter().number(from: sharePriceTextField.text!)!)
            pricedAt = adjustForBrokerAndExchangeFees(position: pricedAt)
            let newStake = Security(name: stockName, stakes: [Stake(shares: numberOfShares, priced: pricedAt)])
            
            previousController?.addNew(stake: newStake)
            dismiss(animated: true, completion: nil)
        }
    }
    
    //Adjusting the stake for broker fees
    func adjustForBrokerAndExchangeFees(position: Double) -> Double {
        var adjustedNumber = position
        //adjusting for fees when purchasing the position
        adjustedNumber += adjustedNumber * feePickerData[brokerageFeePickerView.selectedRow(inComponent: 0)].fees[brokerageFeePickerView.selectedRow(inComponent: 1)] * 0.01
        adjustedNumber += adjustedNumber * Constants.moexStockFee
        
        //adjusting for fees when selling the position
        adjustedNumber += adjustedNumber * feePickerData[brokerageFeePickerView.selectedRow(inComponent: 0)].fees[brokerageFeePickerView.selectedRow(inComponent: 1)] * 0.01
        adjustedNumber += adjustedNumber * Constants.moexStockFee
        
        return adjustedNumber
    }

}
