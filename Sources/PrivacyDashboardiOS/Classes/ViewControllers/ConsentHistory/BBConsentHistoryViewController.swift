
//
//  BBConsentHistoryViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 11/09/23.
//

import UIKit
import SDStateTableView
import SwiftEntryKit

enum ConsentHistoryFilterMode {
    case ViewAll
    case ByOrg
    case SortByDate
}

class BBConsentHistoryViewController: BBConsentBaseViewController {
    @IBOutlet weak var historyListTable: SDStateTableView!
    var consentHistoryDetails: ConsentHistoryData?
    var histories: [ConsentHistory]?
    var orgId: String?
    var orgList:[Organization] = []
    var offset = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyListTable.dataSource = self
        historyListTable.delegate = self
        callHistoryListApi(orgID: self.orgId ?? "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = Constant.Strings.consentHistory.localized
    }
    

    func callHistoryListApi(orgID: String, isLoadMore: Bool = false) {
        self.addLoadingIndicator()
        let serviceManager = NotificationServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.isLoadMore = isLoadMore
        serviceManager.getConsentHistoryList(offset: self.offset)
    }
}

extension BBConsentHistoryViewController: WebServiceTaskManagerProtocol {
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:String?)) {
        self.removeLoadingIndicator()
        
        if response.error != nil {
            self.showErrorAlert(message: (response.error)!)
            return
        }
        
        if let serviceManager = manager as? NotificationServiceManager {
            if serviceManager.serviceType == .ConsentHistoryList {
                if let data = response.data?.responseModel as? ConsentHistoryData {
                    self.consentHistoryDetails = data
                    if self.histories == nil {
                        self.histories = [ConsentHistory]()
                    }
                    if serviceManager.isLoadMore {
                        self.histories?.append(contentsOf: data.consentHistory ?? [])
                        serviceManager.isLoadMore = false
                    } else {
                        self.histories = data.consentHistory
                        if (self.histories?.count ?? 0) < 1 {
                            self.historyListTable.setState(.withImage(image: nil, title: "", message: Constant.Strings.noHistoryAbailable.localized))
                        }
                    }
                    self.historyListTable.reloadData()
                }
            }
        }
    }
}

extension BBConsentHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:Constant.CustomTabelCell.KEventCellID,for: indexPath) as! BBConsentHistoryListTableViewCell
        cell.timeLbl.text = self.histories?[indexPath.row].timeStamp
        cell.history = self.histories?[indexPath.row]
        cell.showData()
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = .white
        } else {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (histories?.count ?? 0) - 1 {
            offset += 10
            callHistoryListApi(orgID: self.orgId ?? "", isLoadMore: true)
        }
    }
}
