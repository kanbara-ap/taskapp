//
//  InputCategoryViewController.swift
//  taskapp
//
//  Created by WEBSYSTEM-MAC31 on 2022/05/09.
//

import UIKit
import RealmSwift

class InputCategoryViewController: UIViewController {
    
    let realm: Realm = try! Realm()
    var category = Category()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var newCategoryTextField: UITextField!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try! realm.write{
            if self.newCategoryTextField.text != nil && self.newCategoryTextField.text != "" {
                let allcategories = realm.objects(Category.self)
                category.id = (allcategories.max(ofProperty: "id") ?? 0)! + 1
                self.category.name = self.newCategoryTextField.text!
                self.realm.add(self.category, update: .modified)
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
