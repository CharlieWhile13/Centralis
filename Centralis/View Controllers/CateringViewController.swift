//
//  CateringViewController.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import UIKit

class CateringViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let catering = EduLink_Catering()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title()
    }
    
    private func title() {
        if let balance = EduLinkAPI.shared.catering.balance {
            self.title = "Balance: \(self.formatPrice(balance))"
        }
    }
    
    private func setup() {
        self.tableView.backgroundColor = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "Centralis.TextViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.catering.catering()
        NotificationCenter.default.addObserver(self, selector: #selector(cateringResponse), name: .SuccesfulCatering, object: nil)
    }
    
    @objc private func cateringResponse() {
        DispatchQueue.main.async {
            self.title()
            self.tableView.reloadData()
        }
    }
    
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
}

extension CateringViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CateringViewController : UITableViewDataSource {
    
    //This is just meant to be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EduLinkAPI.shared.catering.transactions.count
    }

    //This is what handles all the images and text etc, using the class mainScreenTableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TextViewCell", for: indexPath) as! TextViewCell
        let transaction = EduLinkAPI.shared.catering.transactions[indexPath.row]
        cell.att = NSMutableAttributedString()
        cell.addPair(bold: "Date & Time: ", normal: transaction.date)
        cell.addPair(bold: "\nItems & Amount: \n", normal: "")
        for (index, item) in transaction.items.enumerated() {
            let ext: String = ((index == transaction.items.count - 1) ? "" : "\n")
            cell.addPair(bold: "", normal: "\(item.item!): \(self.formatPrice(item.price))\(ext)")
        }

        cell.transactionsView.attributedText = cell.att
        cell.transactionsView.textColor = .label
        
        return cell
    }
}

