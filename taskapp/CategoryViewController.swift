//
//  CategoryViewController.swift
//  taskapp
//
//  Created by 山本優也 on 2021/02/02.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var CategoryTextField: UITextField!
    
    
    let realm = try! Realm()
    var category: Category!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? InputViewController {
            controller.categories.append(CategoryTextField.text!)
            controller.pickerView.reloadAllComponents()
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
