//
//  InputViewController.swift
//  taskapp
//
//  Created by WEBSYSTEM-MAC31 on 2022/05/02.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    var pickerView = UIPickerView()
    private var data :[String] = [] //category.nameを入れる配列
    let realm: Realm = try! Realm()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var contentsTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    var task: Task!
    private var category :[Category] = []   //category本体を入れる配列
    var categoryNumber: Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UIGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        categoryTextField.delegate = self
        titleTextField.text = task.title
        contentsTextField.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category?.name
        
        categoryNumber = (task.category?.id ?? 0)
        
        // Do any additional setup after loading the view.
    }
    
    //viewタップ時の動作
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            if touch.view == self.view {
                return true
            }
            return false
    }
    //画面表示時必ず処理する動作
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Categoryクラスのデータを呼び出し
        category = Category.loadAll()
        data = []
        if category.count != 0{
            for num in 0..<(category.count) {
                data.append(category[num].name)
            }
            createPickerView()
        }else{
            //デバック用
            print("選択できるカテゴリーがありません")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextField.text!
            self.task.date = self.datePicker.date
                //categorynumberを使って指定のcategoryを保存
            if categoryNumber != nil{
                self.task.category = category[categoryNumber]
            }
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    //キーボードを非表示にする
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
        categoryTextField.text = data[row]
        categoryNumber = row 
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
    
    //category選択欄にキーボードから入力不可にする
    func textField(_ TextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        return false
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
