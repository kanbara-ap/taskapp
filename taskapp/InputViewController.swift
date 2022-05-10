//
//  InputViewController.swift
//  taskapp
//
//  Created by WEBSYSTEM-MAC31 on 2022/05/02.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerView = UIPickerView()
    var data :[String] = []
    let realm: Realm = try! Realm()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var contentsTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    var task: Task!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UIGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextField.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Category.loadAll().count != 0{
            data = Category.loadAll()
        }else{
            data = ["none"]
        }
        createPickerView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextField.text!
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats:false)
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in
            print(error ?? "ローカル通知登録　OK")
        }
        
        center.getPendingNotificationRequests{ (request:[UNNotificationRequest]) in
            for request in request {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = data[row]
    }
    
    func createPickerView(){
        pickerView.delegate = self
        categoryTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InputViewController.donePicker))
        toolbar.setItems([doneButtonItem],animated: true)
        categoryTextField.inputAccessoryView = toolbar
    }

    @objc func donePicker(){
        categoryTextField.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        categoryTextField.endEditing(true)
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
