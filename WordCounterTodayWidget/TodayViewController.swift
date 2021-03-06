//
//  TodayViewController.swift
//  WordCounterTodayWidget
//
//  Created by Arefly on 7/8/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITextViewDelegate, NCWidgetProviding {

    let sharedData = UserDefaults(suiteName: "group.com.arefly.WordCounter")

    @IBOutlet var textView: UITextView!
    @IBOutlet var wordsCountLabel: UILabel!
    @IBOutlet var parasCountLabel: UILabel!
    @IBOutlet var charsCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] 準備加載 Today View Controller 之 viewDidLoad")

        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.isUserInteractionEnabled = true

        textView.delegate = self
        textView.isUserInteractionEnabled = true

        textView.isSelectable = true  //BUG IN APPLE SIDE
        if #available(iOSApplicationExtension 13.0, *) {
            textView.textColor = .label
        } else {
            textView.textColor = .black
        }
        textView.isSelectable = false

        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.pressedOnce))
        self.view.addGestureRecognizer(tapGesture)

        var wordCounts = 0
        var charCount = 0
        var paraCount = 0

        var wordType: CountByType = WordCounter.isChineseUser() ? .chineseWord : .word
        var charType: CountByType = WordCounter.isChineseUser() ? .chineseWordWithoutPunctuation : .character

        if let clipBoard = UIPasteboard.general.string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            textView.text = clipBoard

            if (!clipBoard.containsChineseCharacters) {
                wordType = .word
                charType = .character
            }

            wordCounts = WordCounter.getCount(of: textView.text, by: wordType)
            charCount = WordCounter.getCount(of: textView.text, by: charType)
            paraCount = WordCounter.getCount(of: textView.text, by: .paragraph)
        }else{
            print("[提示] 用戶剪貼簿內並未任何內容")
            textView.text = NSLocalizedString("Global.Text.NothingOnClipboard", comment: "Nothing in your clipboard!")
        }

        let wordSingular = NSLocalizedString("Global.Units.Short.\(wordType.rawValue).Singular", comment: "word")
        let wordPlural = NSLocalizedString("Global.Units.Short.\(wordType.rawValue).Plural", comment: "words")

        let charSingular = NSLocalizedString("Global.Units.Short.\(charType.rawValue).Singular", comment: "char.")
        let charPlural = NSLocalizedString("Global.Units.Short.\(charType.rawValue).Plural", comment: "chars.")

        let paraSingular = NSLocalizedString("Global.Units.Short.Paragraph.Singular", comment: "para.")
        let paraPlural = NSLocalizedString("Global.Units.Short.Paragraph.Plural", comment: "paras.")

        let wordWords = (wordCounts == 1) ? wordSingular : wordPlural
        let wordTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.\(wordType.rawValue)", comment: "%1$@ %2$@"), String(wordCounts), wordWords)

        let charWords = (charCount == 1) ? charSingular : charPlural
        let charTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.\(charType.rawValue)", comment: "%1$@ %2$@"), String(charCount), charWords)

        let paraWords = (paraCount == 1) ? paraSingular : paraPlural
        let paraTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Paragraph", comment: "%1$@ %2$@"), String(paraCount), paraWords)

        if (WordCounter.isChineseUser()) {
            wordsCountLabel.text = wordTitle // 带标点字数
            parasCountLabel.text = charTitle // 不带标点字数
            charsCountLabel.text = paraTitle // 段落数
        } else {
            wordsCountLabel.text = wordTitle
            parasCountLabel.text = paraTitle
            charsCountLabel.text = charTitle
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[提示] 準備加載 Today View Controller 之 viewDidAppear")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] 準備加載 Today View Controller 之 viewWillAppear")

    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.newData)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets{
        //return UIEdgeInsetsZero
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }

    @objc func pressedOnce() {
        print("[提示] 用戶已按下任意位置！")
        if let clipBoard = UIPasteboard.general.string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            self.extensionContext?.open(URL(string: "count://fromClipBoard")!, completionHandler:{(success: Bool) -> Void in
                print("[提示] 已開啓App")
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
