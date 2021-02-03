//
//  ViewController.swift
//  taskapp
//
//  Created by 山本優也 on 2021/01/22.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    
    //DB内のタスクが格納されるリスト。
    //日付の近い順でソート(並び替え)：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",ascending: true)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //データの数(＝セルの数)を返すメソッド　プロトコルメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド　プロトコルメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルがタップされた時にsegueのIDを指定して遷移させるメソッド
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルの削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Deleteボタンが押されたときに呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt  indexPath: IndexPath) {
        if editingStyle == .delete {
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/--------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        //すでに作成済みのタスクを編集
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            //新たなタスクを作成
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //テキストが入力されたら呼ばれるメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

            if searchText.isEmpty {
                taskArray = realm.objects(Task.self)
            } else {
                taskArray = realm
                    .objects(Task.self)
                    .filter("category BEGINSWITH %@", searchText)
            }

            tableView.reloadData()
    
    }


}
