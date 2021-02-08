//
//  Task.swift
//  taskapp
//
//  Created by 山本優也 on 2021/01/26.
//

import RealmSwift

class Task: Object {
    //管理用ID。プライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //カテゴリー
        @objc dynamic var category = ""
        //Listの定義
        let categoryTitle = List<Category>()
    
    //日時
    @objc dynamic var date = Date()
    
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }

}

class Category: Object {
    @objc dynamic var categoryContent: String = ""
}
