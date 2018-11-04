//
//  DailyViewController.swift
//  SimpleCalender
//
//  Created by 노미래 on 2018. 11. 4..
//  Copyright © 2018년 Mirae. All rights reserved.
//

import UIKit

class DailyViewController :UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblSchedule: UITableView!
    @IBOutlet var lblTitle: UILabel!
    
    let calenderData = CalenderData()
    var date = Date()
    var cal = Calendar(identifier: .gregorian)
    var lengthM = Int()
    var year = Int()
    var month = Int()
    var day = Int()
    var wDay = Int()
    var wDayString = String()
    let formatter = DateFormatter()
    
    var nSchedule:Int = 0
    var result :FMResultSet? = FMResultSet()
    
    var contactDB = FMDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblSchedule.delegate = self
        self.tblSchedule.dataSource = self
        self.tblSchedule.rowHeight = 50
        
        // Do any additional setup after loading the view, typically from a nib.
        
        year = calenderData.curYear
        month = calenderData.curMonth
        day = calenderData.curDay
        lengthM = calenderData.calcLengthM(year: year, month: month)
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy-MM-dd"
        calcWDate()
        
        lblTitle.textColor = UIColor.red
        lblTitle.text = String(year) + "년 " + String(month) + "월 " + String(day) + "일 " + wDayString + "요일"
        
        find()
    }
    
    @IBAction func btnRefresh(_ sender: Any) {
        refresh()
    }
    
    @IBAction func btnWrite(_ sender: Any) {
        if let uvc = self.storyboard?.instantiateViewController(withIdentifier: "VCWrite") as? VCWrite {
            uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            uvc.modalPresentationStyle = .overCurrentContext
            self.present(uvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPre(_ sender: Any) {
        day -= 1
        updateDate()
        if (year == calenderData.curYear && month == calenderData.curMonth && day == calenderData.curDay) {
            lblTitle.textColor = UIColor.red
        } else {
            lblTitle.textColor = UIColor.black
        }
        lblTitle.text = String(year) + "년 " + String(month) + "월 " + String(day) + "일 " + wDayString + "요일"
        refresh()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        day += 1
        updateDate()
        if (year == calenderData.curYear && month == calenderData.curMonth && day == calenderData.curDay) {
            lblTitle.textColor = UIColor.red
        } else {
            lblTitle.textColor = UIColor.black
        }
        lblTitle.text = String(year) + "년 " + String(month) + "월 " + String(day) + "일 " + wDayString + "요일"
        refresh()
    }
    
    func calcWDate() {
        wDayString = calenderData.calcString(year: year, month: month, day: day)
        date = formatter.date(from: wDayString)!
        wDay = self.cal.dateComponents([.weekday], from: date).weekday! - 1
        switch wDay {
        case 0:
            wDayString = "일"
        case 1:
            wDayString = "월"
        case 2:
            wDayString = "화"
        case 3:
            wDayString = "수"
        case 4:
            wDayString = "목"
        case 5:
            wDayString = "금"
        case 6:
            wDayString = "토"
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nSchedule
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblSchedule.dequeueReusableCell(withIdentifier: "TableViewCell_Daily") as! TableViewCell_Daily
        cell.lblSchedule.text = "exists"
        
        if (indexPath.row == 0) {
            contactDB = FMDatabase(path: dataPath)
            contactDB.open()
            let querySQL = "SELECT schedule FROM CONTACTS WHERE year = '\(year)' AND month = '\(month)' AND day = '\(day)' ORDER BY id ASC"
            result = contactDB.executeQuery(querySQL, withArgumentsIn: [])
        }
        
        if result?.next() == true {
            cell.lblSchedule.text = result?.string(forColumn: "schedule")
        }
        
        if (indexPath.row == nSchedule-1) {
            contactDB.close()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func refresh() -> Void{
        find()
        tblSchedule.reloadData()
    }
    
    func find() {
        nSchedule = 0
        let contactDB = FMDatabase(path: dataPath)
        contactDB.open()
        
        let querySQL = "SELECT schedule FROM CONTACTS WHERE year = '\(year)' AND month = '\(month)' AND day = '\(day)' ORDER BY id ASC"
        let result :FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsIn: [])
        while result?.next() == true {
            print("true")
            nSchedule += 1
        }
        print("find : " + String(nSchedule))
        contactDB.close()
    }
    
    func updateDate() {
        if day <= 0 {
            month -= 1
            if (month == 0) {
                month = 12
                year -= 1
            }
            lengthM = calenderData.calcLengthM(year: year, month: month)
            day = lengthM + day
        } else if day > lengthM {
            month += 1
            if (month == 13) {
                month = 1
                year += 1
            }
            lengthM = calenderData.calcLengthM(year: year, month: month)
            day = 1
        }
        calcWDate()
    }
}
