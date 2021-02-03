//
//  InputViewController.swift
//  taskapp
//
//  Created by 山本優也 on 2021/01/24.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController ,UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    let realm = try! Realm()
    var task: Task!
    
    
    //プロパティを設定
    
    
    var categories = ["宿題","仕事","遊び"] {
        didSet {
            print("新しい配列\(categories)")
        }
    }
    
    var selected = ""

    
    //pickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerViewの行の数、要素の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    // pickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return categories[row]
    }
    
    // pickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        selected = categories[row]
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ピッカービューのデリゲートの設定
        pickerView.delegate = self
        pickerView.dataSource = self

        
        //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
    
        datePicker.date = task.date
    }
    
   
    
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //遷移先に戻る際にタスクの内容をデータベースに保存する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text!
            self.task.date = self.datePicker.date
            self.task.category = selected
            self.realm.add(self.task, update: .modified)
            
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }

    //タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定（中身がない場合メッセージなしで音だけの通知になるので「(xxなし)を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "内容なし"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger(日付マッチ)を作成
        let calendar = Calendar.current
        let dateComponets = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponets, repeats: false)
        
        //identifier,content,triggerからローカル通知を作成(identifierが同じだとローカル通知を上書き保存)
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知　OK")
            //errorがnilならローカル通知の登録に成功したと表示する。errorが存在すればerrorを表示します
        }
        
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/------------")
                print(request)
                print("------------/")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
