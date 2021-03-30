//
//  VBAcessoriesViewController.swift
//  VoiceBox
//
//  Created by Dmitry on 31.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit
import ReactiveKit

class VBAcessoriesViewController: UITableViewController {
    
    var viewModel: VBAcessoriesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        let color = R.color.mainColor() ?? UIColor.green
        refreshControl?.tintColor = color
        refreshControl?.attributedTitle = NSAttributedString.init(string: NSLocalizedString("Обновление..", comment: ""),
                                                                      attributes: [NSAttributedString.Key.foregroundColor : color as Any])
        
        bind()
        
        refreshData(nil)
    }
    
    private func bind(){
        if let refreshControl = self.refreshControl {
          viewModel.isBusy.bind(to: refreshControl.reactive.refreshing)
        }
        
        viewModel.onAcessoriesUpdated = { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    @objc private func refreshData(_ sender: Any?) {
        viewModel.reload()
    }
    
    @objc func discoverAccessories(sender: UIBarButtonItem) {
      viewModel.discoverAccessories()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.acessoriesCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.acessoryCellID, for: indexPath)!
        let info = viewModel.acessoryInfo(indexPath: indexPath)
        cell.titleLabel?.text  = info.0
        cell.subtitleLabel?.text = info.1
        cell.switchSegment?.selectedSegmentIndex = (info.2 == true ? 1 : 0)
        cell.onChangeState = {[weak self] (state) in
            self?.viewModel.changeState(state: state, indexPath: indexPath)
        }
        return cell
    }
    
    deinit{
         viewModel.onAcessoriesUpdated = nil
    }

}
