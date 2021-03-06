//
//  InfoTabelViewController.swift
//  WordCounter
//
//  Created by Arefly on 6/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation
import StoreKit
import MessageUI
import MBProgressHUD

class InfoTabelViewController: UITableViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate, MFMailComposeViewControllerDelegate {

    // MARK: - Basic var
    let defaults = UserDefaults.standard

    // MARK: - Table Content var
    var tableContent = [[String]]()
    var headerContent = [String]()
    var footerContent = [String]()

    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        print("準備加載 Info Tabel View Controller 之 viewDidLoad")

        self.title = NSLocalizedString("About.NavBar.Title", comment: "About")

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemGroupedBackground
        }


        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String

        let versionText = String.localizedStringWithFormat(NSLocalizedString("About.Title.Text.Version", comment: "Version %@"), version)
        let buildText = String.localizedStringWithFormat(NSLocalizedString("About.Subtitle.Text.Build", comment: "Build %@"), build)

        tableContent.append(NSLocalizedString("About.Table.Section0.Content", comment: "Section 0 Content").components(separatedBy: "--"))
        tableContent.append(String.localizedStringWithFormat(NSLocalizedString("About.Table.Section1.Content", comment: "Section 1 Content"), versionText, buildText).components(separatedBy: "--"))


        headerContent = NSLocalizedString("About.Table.Header.Content", comment: "Header Content").components(separatedBy: "--")


        let startYear = 2015
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())

        var copyrightYears = "\(startYear)"
        if currentYear > startYear {
            copyrightYears = "\(startYear)-\(currentYear)"
        }

        footerContent = String.localizedStringWithFormat(NSLocalizedString("About.Table.Footer.Content", comment: "Footer Content"), copyrightYears).components(separatedBy: "--")


        SKPaymentQueue.default().add(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("準備加載 Info Table View Controller 之 viewWillAppear")
    }

    // MARK: - Table func
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent[section].count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableContent.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerContent[section]
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footerContent[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = tableContent[indexPath.section][indexPath.row].components(separatedBy: "||")

        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        cell.textLabel?.text = cellContent[0]
        cell.detailTextLabel?.text = cellContent[1]

        if #available(iOS 13.0, *) {
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.textColor = .label
        }

        if indexPath.section == 0 {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                print("用戶已按下分享按鈕")

                let textToShare = NSLocalizedString("Global.Text.ShareMessage", comment: "Hi! Still counting words one by one? Get Word Counter Tool on App Store today!")

                if let appStoreURL = BasicConfig.appStoreShortUrl {
                    let objectsToShare = [textToShare, appStoreURL] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    DispatchQueue.main.async {
                        self.present(activityVC, animated: true, completion: nil)
                    }

                    if let popView = activityVC.popoverPresentationController {
                        print("須使用 popView")
                        popView.sourceView = tableView
                        popView.sourceRect = tableView.cellForRow(at: indexPath)!.frame
                    }
                }

                break
            case 1:
                print("用戶已按下評分按鈕")

                UIApplication.shared.openURL(BasicConfig.appStoreReviewUrl! as URL)

                break
            case 2:
                print("用戶已按下查看其它Apps按鈕")

                UIApplication.shared.openURL(BasicConfig.otherAppsByMe! as URL)

                break
            case 3:
                print("用戶已按下捐款按鈕")

                let donateValues = [1, 5, 10, 25, 100]

                let donateAlert = UIAlertController(
                    title: NSLocalizedString("About.Alert.Donate.Title", comment: ""),
                    message: NSLocalizedString("About.Alert.Donate.Content", comment: ""),
                    preferredStyle: .alert)

                for donateValue in donateValues {
                    donateAlert.addAction(UIAlertAction(title: String.localizedStringWithFormat(NSLocalizedString("About.Alert.Donate.Button.Donate", comment: "Donate US $%d!"), donateValue), style: .default, handler: { (action: UIAlertAction) in
                        self.donateMoney(donateValue)
                    }))
                }
                donateAlert.addAction(UIAlertAction(title: NSLocalizedString("About.Alert.Donate.Button.Restore", comment: "(Restore purchases)"), style: .default, handler: { (action: UIAlertAction) in
                    self.restoreDonate()
                }))
                donateAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: { (action: UIAlertAction) in
                    print("用戶已按下取消按鈕")
                }))

                DispatchQueue.main.async {
                    self.present(donateAlert, animated: true, completion: nil)
                }

                break
            default:
                //DO NOTHING
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                //DO NOTHING
                break
            case 1:
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self

                mailComposerVC.setToRecipients(["yifei@hesyifei.com"])
                mailComposerVC.setSubject("About Word Counter Tool")
                mailComposerVC.setMessageBody("", isHTML: false)

                if MFMailComposeViewController.canSendMail() {
                    DispatchQueue.main.async {
                        self.present(mailComposerVC, animated: true, completion: nil)
                    }
                }

                break
            case 2:
                UIApplication.shared.openURL(URL(string: "https://www.hesyifei.com/")!)

                break
            case 3:
                let showGithubAlert = UIAlertController(
                    title: NSLocalizedString("About.Alert.ShowGithub.Title", comment: "You are now a developer!"),
                    message: NSLocalizedString("About.Alert.ShowGithub.Content", comment: "Open the repository of Word Counter Tool on GitHub?"),
                    preferredStyle: .alert)

                showGithubAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Yes", comment: "Yes"), style: .default, handler: { (action: UIAlertAction) in
                    print("用戶已按下確定打開Github按鈕")
                    UIApplication.shared.openURL(URL(string: "https://github.com/hesyifei/word-counter")!)
                }))

                showGithubAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: { (action: UIAlertAction) in
                    print("用戶已按下取消按鈕")
                }))

                DispatchQueue.main.async {
                    self.present(showGithubAlert, animated: true, completion: nil)
                }

                break
            default:
                //DO NOTHING
                break
            }
            break
        default:
            //DO NOTHING
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }


    // MARK: - IAP Related func
    func showError(message: String, error: Error? = nil) {
        var errorMessage = message
        errorMessage = "\(errorMessage)\n\nPlease make sure you are connected to the Internet.\n\nIf the error persists, please contact the developer."
        if (error != nil) {
            errorMessage = "\(errorMessage)\n\nError description: \(error?.localizedDescription ?? "UNKNOWN ERROR")"
        }

        let alert = UIAlertController(title: "Donation Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func donateMoney(_ amount: Int) {
        print("準備加載 donateMoney(\(amount))")
        print("即：準備獲取產品信息")

        print("用戶canMakePayments()值爲 \(SKPaymentQueue.canMakePayments())")

        if (SKPaymentQueue.canMakePayments()){
            getProductInfo("WordCounter.Donation.\(amount)")
        } else {
            alertPlzEnableIAP()
        }
    }

    func getProductInfo(_ id: String) {
        print("準備加載 getProductInfo(\(id))")
        print("即：準備獲取產品信息")

        switchHudWithoutTitle(true)


        let request = SKProductsRequest(productIdentifiers: [id])

        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("準備加載 productsRequest: didReceiveResponse")
        print("即：已獲取蘋果回覆內購產品信息")

        switchHudWithoutTitle(false)

        let count: Int = response.products.count
        if (count > 0) {
            //var validProducts = response.products
            let validProduct: SKProduct = response.products[0]
            print("已獲取內購產品信息：")
            print("產品ID：\(validProduct.productIdentifier)")
            print("本地化標題：\(validProduct.localizedTitle)")
            print("本地化描述：\(validProduct.localizedDescription)")
            print("價格：\(validProduct.price)")
            buyProduct(validProduct)
        } else {
            print("請求信息失敗")
            showError(message: "Products request count is 0! :(")
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("準備加載 request: didFailWithError")
        print("即：無法獲取蘋果回覆內購產品信息：\(error.localizedDescription)")

        switchHudWithoutTitle(false)

        showError(message: "Request failed! :(", error: error)
    }

    func buyProduct(_ product: SKProduct) {
        print("準備加載 buyProduct(\(product))")
        print("即：發送內購產品信息至蘋果中")

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("準備加載 paymentQueue: updatedTransactions")
        print("即：已獲取蘋果回應")

        for transaction: AnyObject in transactions {
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("用戶內購成功")
                    print("產品ID：\((transaction as! SKPaymentTransaction).payment.productIdentifier)")
                    self.deliverProduct(transaction as! SKPaymentTransaction)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .failed:
                    print("用戶內購失敗：\(trans.error.debugDescription)")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)

                    showError(message: "Donation failed! :(", error: trans.error)
                    break
                default:
                    break
                }
            }
        }
    }

    func deliverProduct(_ transaction: SKPaymentTransaction) {
        print("準備加載 deliverProduct")
        print("即：用戶已捐款成功！")
        print("產品ID：\(transaction.payment.productIdentifier)")

        finishDonating()

        let donateSuccessAlert = UIAlertController(
            title: NSLocalizedString("About.Alert.DonateSuccess.Title", comment: "Thank you!"),
            message: NSLocalizedString("About.Alert.DonateSuccess.Content", comment: "We have received your donation!\nAD is hidden now! :)"),
            preferredStyle: .alert)
        donateSuccessAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .cancel, handler: { (action: UIAlertAction) in
            print("用戶已按下完成按鈕")
        }))

        DispatchQueue.main.async {
            self.present(donateSuccessAlert, animated: true, completion: nil)
        }
    }

    func restoreDonate() {
        print("準備加載 restoreDonate")
        print("即：用戶已按下「恢復購買」按鈕")

        switchHudWithoutTitle(true)

        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("準備加載 paymentQueue: restoreCompletedTransactionsFailedWithError")
        print("即：恢復內購失敗：\(error.localizedDescription)")

        switchHudWithoutTitle(false)

        showError(message: "Restore completed transactions failed! :(", error: error)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("準備加載 paymentQueueRestoreCompletedTransactionsFinished")
        print("即：已完成恢復先前之內購記錄")

        switchHudWithoutTitle(false)

        var willShowSuccess = false

        for transaction: SKPaymentTransaction in queue.transactions {
            if (transaction.payment.productIdentifier).range(of: "WordCounter.Donation.") != nil {
                print("用戶已恢復捐款")
                print("內購ID：\(transaction.payment.productIdentifier)")
                finishDonating()

                willShowSuccess = true
            }
            SKPaymentQueue.default().finishTransaction(transaction as SKPaymentTransaction)
        }

        if willShowSuccess {
            let restoreSuccessAlert = UIAlertController(
                title: NSLocalizedString("About.Alert.RestoreSuccess.Title", comment: "Thank you!"),
                message: NSLocalizedString("About.Alert.RestoreSuccess.Content", comment: "Your donation was restored!\nAD is hidden now! :)"),
                preferredStyle: .alert)
            restoreSuccessAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .cancel, handler: { (action: UIAlertAction) in
                print("用戶已按下完成按鈕")
            }))

            DispatchQueue.main.async {
                self.present(restoreSuccessAlert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Donation Record Not Found", message: "We cannot find your donation record! Please contact the developer if you have any questions! :)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }

        }
    }

    func finishDonating() {
        defaults.set(true, forKey: "noAd")
    }

    func alertPlzEnableIAP() {
        print("準備加載 alertPlzEnableIAP")
        print("即：準備顯示「請開啓內購」通知")
        let iapDisabledAlert = UIAlertController(title: NSLocalizedString("About.Alert.IapDisabledAlert.Title", comment: "IAP is not allowed!"), message: NSLocalizedString("About.Alert.IapDisabledAlert.Content", comment: "Please enable in-app purchases in Settings app."), preferredStyle: .alert)
        iapDisabledAlert.addAction(UIAlertAction(title: NSLocalizedString("About.Alert.IapDisabledAlert.Button.OpenSettings", comment: "Open Settings"), style: .default, handler: { alertAction in
            print("用戶已按下前往「設定」按鈕")
            let url: URL? = URL(string: UIApplication.openSettingsURLString)
            if url != nil{
                UIApplication.shared.openURL(url!)
            }
        }))
        iapDisabledAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: { alertAction in
            print("用戶已按下關閉按鈕")
        }))

        DispatchQueue.main.async {
            self.present(iapDisabledAlert, animated: true, completion: nil)
        }
    }


    // MARK: - Mail Related func
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Other func
    func switchHudWithoutTitle(_ show: Bool){
        DispatchQueue.main.async {
            if show {
                MBProgressHUD.showAdded(to: self.view.window!, animated: true)
            } else {
                MBProgressHUD.hide(for: self.view.window!, animated: true)
            }
        }
    }
}
