//
//  ViewController.swift
//  taskapp
//
//  Created by WEBSYSTEM-MAC31 on 2022/05/02.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var pickerView = UIPickerView()
    let realm : Realm = try! Realm()
    let category = Category()
    var data: [String] = []
    var categoryAll :[Category] = []
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterText: UITextField!
    
    @IBAction func filterButton(_ sender: Any) {
        
        if filterText.text == nil {
        
        }else{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).filter("category.name=%@",filterText.text)
            loadView()
            viewDidLoad()
            viewWillAppear(true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        filterText.delegate = self
        
        print("ok")
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        let allCategories = realm.objects(Category.self)
        print("ok2")
        if allCategories.count == 0{
            try! realm.write(){
            category.name = "none"
            self.realm.add(category, update: .modified)
            }
        }
        //Categoryクラスのデータを呼び出し
        categoryAll = Category.loadAll()
        data = []
        if categoryAll.count != 0{
            for num in 0..<(categoryAll.count) {
                data.append(categoryAll[num].name)
            }
            createPickerView()
        }else{
            //デバック用
            print("選択できるカテゴリーがありません")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
                task.category?.id = 0
            }
            inputViewController.task = task
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete{
    
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            try! realm.write{
                realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath],with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
            
    }
    
    //category選択に使うPickerviewの必須メソッド
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filterText.text = data[row]
    }
    func createPickerView(){
        pickerView.delegate = self
        filterText.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InputViewController.donePicker))
        toolbar.setItems([doneButtonItem],animated: true)
        filterText.inputAccessoryView = toolbar
    }
    @objc func donePicker(){
        filterText.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        filterText.endEditing(true)
    }
    
    //category選択欄にキーボードから入力不可にする
    func textField(_ TextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        return false
    }
            
}
