//
//  WeeklyViewController.swift
//  SimpleCalender
//
//  Created by 노미래 on 2018. 11. 3..
//  Copyright © 2018년 Mirae. All rights reserved.
//

import UIKit

class WeeklyViewController :UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblWeekly: UITableView!
    @IBOutlet var lblDate: UILabel!
    
    let calenderData = CalenderData()
    var cal = Calendar(identifier: .gregorian)
    var lengthM = Int()
    var year = Int()
    var month = Int()
    var day = Int()
    var wDay = Int() // 요일
    
    var nSchedule = Int()
    var strSchedule:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tblWeekly.delegate = self
        self.tblWeekly.dataSource = self
        
        self.tblWeekly.rowHeight = 65
        
        // 현재시점 날짜 관련 정보 세팅
        year = calenderData.curYear
        month = calenderData.curMonth
        day = calenderData.curDay
        wDay = self.cal.dateComponents([.weekday], from: calenderData.date).weekday! - 1
        
        lengthM = calenderData.calcLengthM(year: year, month: month)
        // 현재 주의 일요일 기준으로 정보 세팅
        day -= wDay
        if (day <= wDay) {
            if (month == 1) {
                year -= 1
                month = 12
            } else {
                month -= 1
            }
            day = lengthM + day
        }
        
        self.lblDate.text = String(year) + "년 " + String(month) + "월"
    }
    
    @IBAction func btnRefresh(_ sender: Any) {
        day -= 7
        updateDate()
        tblWeekly.reloadData()
    }
    
    @IBAction func btnWrite(_ sender: Any) {
        if let uvc = self.storyboard?.instantiateViewController(withIdentifier: "VCWrite") as? VCWrite {
            uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            uvc.modalPresentationStyle = .overCurrentContext
            self.present(uvc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblWeekly.dequeueReusableCell(withIdentifier: "TableViewCell_Weekly") as! TableViewCell_Weekly
        
        if (year == calenderData.curYear && month == calenderData.curMonth && day == calenderData.curDay) {
            cell.lblDate.textColor = UIColor.red
        } else {
            cell.lblDate.textColor = UIColor.black
        }
        
        //cell.lblDate.text = String(indexPath.row)
        var dayString = String()
        switch indexPath.row {
        case 0:
            dayString = "일 "
        case 1:
            dayString = "월 "
        case 2:
            dayString = "화 "
        case 3:
            dayString = "수 "
        case 4:
            dayString = "목 "
        case 5:
            dayString = "금 "
        case 6:
            dayString = "토 "
        default:
            break
        }
        dayString.append(String(day))
        cell.lblDate.text = dayString
        
        // 스케쥴 있는지 검사
        find()
        if nSchedule >= 1 {
            cell.backgroundColor = UIColor(red:0.89, green:0.93, blue:0.97, alpha:1.0)
            if nSchedule > 1 {
                cell.lblSchedule.text = String(nSchedule) + "개의 스케줄이 있습니다."
            } else {
                cell.lblSchedule.text = strSchedule
            }
        } else {
            cell.lblSchedule.text = " "
            cell.backgroundColor = UIColor.white
        }
        
        // update
        day += 1
        updateDate()
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    @IBAction func btnPre(_ sender: Any) {
        day -= 14
        updateDate()
        
        tblWeekly.reloadData()
        self.lblDate.text = String(year) + "년 " + String(month) + "월"
    }
    @IBAction func btnNext(_ sender: Any) {
        
        tblWeekly.reloadData()
        self.lblDate.text = String(year) + "년 " + String(month) + "월"
    }
    
    func find() {
        nSchedule = 0
        let contactDB = FMDatabase(path: dataPath)
        contactDB.open()
        
        let querySQL = "SELECT schedule FROM CONTACTS WHERE year = '\(year)' AND month = '\(month)' AND day = '\(day)' ORDER BY id ASC"
        let result :FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsIn: [])
        if result?.next() == true {
            strSchedule = result?.string(forColumn: "schedule")
            nSchedule += 1
        }
        while result?.next() == true {
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
    }
}

