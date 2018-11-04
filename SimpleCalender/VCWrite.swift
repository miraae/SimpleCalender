//
//  VCWrite.swift
//  SimpleCalender
//
//  Created by 노미래 on 2018. 11. 4..
//  Copyright © 2018년 Mirae. All rights reserved.
//

import UIKit

class VCWrite :UIViewController, UITextFieldDelegate{
    
    @IBOutlet var txtSchedule: UITextField!
    
    var year = Int()
    var month = Int()
    var day = Int()
    var cal = Calendar(identifier: .gregorian)
    var didPick = false
    
    let calenderData = CalenderData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtSchedule.delegate = self
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        
        didPick = true
        
        let dtView = sender
        year = cal.component(.year, from: dtView.date)
        month = cal.component(.month, from: dtView.date)
        day = cal.component(.day, from: dtView.date)
        /*
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy-MM-dd"*/
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnSave(_ sender: Any) {
        if didPick == false {
            let calenderData = CalenderData()
            year = calenderData.curYear
            month  = calenderData.curMonth
            day = calenderData.curDay
        }
        
        let contactDB = FMDatabase(path: dataPath)
        
        if contactDB.open() {
            let insertSQL = "INSERT INTO CONTACTS (year, month, day, schedule) VALUES ('\(year)', '\(month)', '\(day)', '\(txtSchedule.text!)')"
            let result = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
            if !result {
                print("Error \(contactDB.lastErrorMessage())")
            }
            
            contactDB.close()
            
            self.closeWrite()
        } else {
            print("Error \(contactDB.lastErrorMessage())")
        }
    }
    
    @IBAction func btnDelete(_ sender: Any) {
        
        let contactDB = FMDatabase(path: dataPath)
        
        if contactDB.open() {
            
            let deleteSQL = "DELETE FROM CONTACTS"
            contactDB.executeUpdate(deleteSQL, withArgumentsIn: [])
            /*
            if !contactDB.executeStatements("CREATE TABLE CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, YEAR INTEGER, MONTH INTEGER, DAY INTEGER, SCHEDULE TEXT)") {
                print("createError \(contactDB.lastErrorMessage())")
            }*/
            
            contactDB.close()
         
        }
        self.closeWrite()
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.closeWrite()
    }
    func closeWrite() {
        let vc = self.presentingViewController
        vc!.dismiss(animated: true, completion: nil)
    }
}
