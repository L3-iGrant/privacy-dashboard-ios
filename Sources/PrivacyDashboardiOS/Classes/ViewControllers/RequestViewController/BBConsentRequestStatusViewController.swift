//
//  BBConsentRequestStatusViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 18/09/23.
//

import SDStateTableView
import UIKit

class BBConsentRequestStatusViewController: BBConsentBaseViewController, UITableViewDataSource, UITableViewDelegate {
    var orgId: String?
    var histories: [RequestStatus]?
    @IBOutlet var historyListTable: SDStateTableView!
    @IBOutlet var newRequestButton: UIButton!
    var requestHistoryDetails: RequestedStatusHistory?

    override func viewDidLoad() {
        super.viewDidLoad()
        callHistoryListApi()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = Constant.Strings.userRequests.localized
    }
    
    func callHistoryListApi() {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.getRequestedStatus(orgId: orgId ?? "")
    }

    func loadMorehistoryListApi(nextUrl: String) {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.isLoadMore = true
        serviceManager.getRequestedStatusLoadMoreList(url: nextUrl)
    }

    func getDownloadDataStatus() {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.getDownloadDataStatus(orgId: orgId ?? "")
    }

    func getForgetMeStatus() {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.getForgetMeStatus(orgId: orgId ?? "")
    }

    func requestForgetMe() {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.requestForgetMe(orgId: orgId ?? "")
    }

    func requestDownloadData() {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.requestDownloadData(orgId: orgId ?? "")
    }

    func callCancelRequestApi(requestType: RequestType?, requestId: String?) {
        addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.cancelRequest(orgId: orgId ?? "", requestId: requestId ?? "", type: requestType ?? RequestType.DownloadData)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CustomTabelCell.KRequestedStatusCellID, for: indexPath) as! BBConsentRequestStatusTableViewCell
        cell.statusType.text = histories?[indexPath.row].TypeStr
        cell.showDate(dateval: histories?[indexPath.row].RequestedDate ?? "")
        cell.statusDetail.text = histories?[indexPath.row].StateStr
        if indexPath.row == (histories?.count)! - 1 {
            if let url = self.requestHistoryDetails?.links?.next {
                if url.isValidString {
                    loadMorehistoryListApi(nextUrl: url)
                }
            }
        }
        cell.cancelButton.isHidden = !(histories?[indexPath.row].isActiveRequest ?? false)
        cell.cancelButton.tag = indexPath.row
        cell.cancelButton.addTarget(self, action: #selector(cancelButtonAction(sender:)), for: .touchUpInside)
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = self.getDefaultBackgroundColor()
        } else {
            if #available(iOS 11.0, *) {
                cell.contentView.backgroundColor = UIColor(named: "ConsentHistorySecondaryColor")
            } else {
                // Fallback on earlier versions
                cell.contentView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            }
        }
        
        return cell
    }

    func getDefaultBackgroundColor() -> UIColor{
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            // Fallback on earlier versions
            return .white
        }
    }
    
    @objc func cancelButtonAction(sender: UIButton) {
        guard let requestStatus = self.histories?[sender.tag], let id = self.histories?[sender.tag].iD else {return}
                   self.callCancelRequestApi( requestType: requestStatus.type == 2 ? RequestType.DownloadData : RequestType.ForgetMe, requestId: id)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let downloadDataProgressVC = storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.downloadDataProgressVC) as! BBConsentDownloadDataProgressViewController
        downloadDataProgressVC.organisationId = orgId
        downloadDataProgressVC.requestStatus = histories?[indexPath.row]
        downloadDataProgressVC.fromHistory = true
        navigationController?.pushViewController(downloadDataProgressVC, animated: true)
    }

    @IBAction func newRequestAction(_ sender: Any) {
        // Create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Create an action
        let firstAction: UIAlertAction = UIAlertAction(title: Constant.Strings.downloadData.localized, style: .default) { _ -> Void in
            self.getDownloadDataStatus()
        }

        let secondAction: UIAlertAction = UIAlertAction(title: Constant.Strings.deleteData.localized, style: .default) { _ -> Void in
            self.getForgetMeStatus()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: Constant.Strings.cancel.localized, style: .cancel) { _ -> Void in }

        // Add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)

        actionSheetController.popoverPresentationController?.sourceView = newRequestButton // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            debugPrint("option menu presented")
        }
    }
}

extension BBConsentRequestStatusViewController: WebServiceTaskManagerProtocol {
    func didFinishTask(from manager: AnyObject, response: (data: RestResponse?, error: String?)) {
        removeLoadingIndicator()
        if response.error != nil {
            showErrorAlert(message: (response.error)!)
            return
        }
        if let serviceManager = manager as? OrganisationWebServiceManager {
            if serviceManager.serviceType == .getRequestedStatus {
                if let data = response.data?.responseModel as? RequestedStatusHistory {
                    if histories == nil {
                        histories = [RequestStatus]()
                    }
                    requestHistoryDetails = data
                    if serviceManager.isLoadMore {
                        histories?.append(contentsOf: data.DataRequests ?? [])
                    } else {
                        histories = data.DataRequests
                        if (histories?.count ?? 0) < 1 {
                            historyListTable.setState(.withImage(image: nil, title: "", message: Constant.Strings.noHistoryAbailable.localized))
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.historyListTable.reloadData()
                }
            } else if serviceManager.serviceType == .requestDownloadData {
                let downloadDataProgressVC = storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.downloadDataProgressVC) as! BBConsentDownloadDataProgressViewController
                downloadDataProgressVC.organisationId = orgId ?? ""
                downloadDataProgressVC.requestType = RequestType.DownloadData
                self.histories?.removeAll()
                self.callHistoryListApi()
                navigationController?.pushViewController(downloadDataProgressVC, animated: true)
            } else if serviceManager.serviceType == .requestForgetMe {
                let downloadDataProgressVC = storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.downloadDataProgressVC) as! BBConsentDownloadDataProgressViewController
                downloadDataProgressVC.organisationId = orgId ?? ""
                downloadDataProgressVC.requestType = RequestType.ForgetMe
                self.histories?.removeAll()
                self.callHistoryListApi()
                navigationController?.pushViewController(downloadDataProgressVC, animated: true)
            } else if serviceManager.serviceType == .getDownloadDataStatus {
                if let data = response.data?.responseModel as? RequestStatus {
                    if data.RequestOngoing ?? false {
                        let downloadDataProgressVC = storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.downloadDataProgressVC) as! BBConsentDownloadDataProgressViewController
                        downloadDataProgressVC.organisationId = orgId ?? ""
                        downloadDataProgressVC.requestType = RequestType.DownloadData
                        downloadDataProgressVC.requestStatus = data
                        navigationController?.pushViewController(downloadDataProgressVC, animated: true)
                    } else {
                        requestDownloadData()
                    }
                }
            } else if serviceManager.serviceType == .getForgetMeStatus {
                if let data = response.data?.responseModel as? RequestStatus {
                    if data.RequestOngoing ?? false {
                        let downloadDataProgressVC = storyboard?.instantiateViewController(withIdentifier: Constant.ViewControllerID.downloadDataProgressVC) as! BBConsentDownloadDataProgressViewController
                        downloadDataProgressVC.organisationId = orgId ?? ""
                        downloadDataProgressVC.requestType = RequestType.ForgetMe
                        downloadDataProgressVC.requestStatus = data
                        navigationController?.pushViewController(downloadDataProgressVC, animated: true)
                    } else {
                        requestForgetMe()
                    }
                }
            } else if serviceManager.serviceType == .cancelRequest {
                let alert = UIAlertController(title: Constant.Alert.cancelRequest, message: Constant.Alert.yourRequestCancelled, preferredStyle: UIAlertController.Style.alert)

                // Add an action (button)
                alert.addAction(UIAlertAction(title: Constant.Alert.OK, style: UIAlertAction.Style.default, handler: { _ in
                    self.histories?.removeAll()
                    self.callHistoryListApi()
                    alert.dismiss(animated: true, completion: nil)
                }))

                // Show the alert
                present(alert, animated: true, completion: nil)
            }
        }
    }
}
