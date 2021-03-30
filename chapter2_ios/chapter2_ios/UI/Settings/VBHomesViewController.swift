//
//  VBHomesViewController.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import HomeKit

class VBHomesViewController: UITableViewController {

    private let _viewModel = VBHomesViewModel()
    
    var selectedHome: HMHome? {
        if let indexPath = tableView?.indexPathForSelectedRow {
           return _viewModel.home(indexPath: indexPath)
        }
        else{
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        let color = R.color.mainColor() ?? UIColor.green
        refreshControl?.tintColor = color
        refreshControl?.attributedTitle = NSAttributedString.init(string: NSLocalizedString("Обновление..", comment: ""),
                                                                      attributes: [NSAttributedString.Key.foregroundColor : color as Any])
        
        _viewModel.onHomesUpdated = { [weak self] in
            self?.reloadHomesTable()
            self?.refreshControl?.endRefreshing()
        }
        
        refreshData(nil)
    }
    
    @objc private func refreshData(_ sender: Any?) {
        _viewModel.reload()
    }
    
    private func reloadHomesTable(){
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.homesCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeCellID, for: indexPath)!
        cell.textLabel?.text = _viewModel.homeTitle(indexPath: indexPath)
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Home Kit"
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! VBAcessoriesViewController
        if let home = self.selectedHome{
            controller.viewModel = VBAcessoriesViewModel(home: home)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == R.segue.vbHomesViewController.acessorySegue.identifier {
            if self.selectedHome == nil {
                return false
            }
        }
        
        return true
    }

    deinit {
        _viewModel.onHomesUpdated = nil
    }
}
