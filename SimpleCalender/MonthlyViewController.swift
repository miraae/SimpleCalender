//
//  MonthlyViewController.swift
//  SimpleCalender
//
//  Created by 노미래 on 2018. 11. 3..
//  Copyright © 2018년 Mirae. All rights reserved.
//

import UIKit

class MonthlyViewController :UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var cllcDate: UICollectionView!
    
    let calenderData = CalenderData()
    var cal = Calendar(identifier: .gregorian)
    var lengthM:Int = Int()
    var startStr:String = String()
    var startDate:Date = Date()
    var startDay:Int = Int()
    var year = Int()
    var month = Int()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.cllcDate.delegate = self
        self.cllcDate.dataSource = self
        
        /* 달력 기능 구현 */
        // 현재 년도, 달
        year = calenderData.curYear
        month = calenderData.curMonth
        // 해당 달의 시작 요일
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy-MM-dd"
        startStr = calenderData.calcString(year:year, month:month, day:1)
        startDate = formatter.date(from: startStr)!
        startDay = self.cal.dateComponents([.weekday], from: startDate).weekday! - 1
        // 해당 달의 길이
        lengthM = calenderData.calcLengthM(year: year, month: month)
        
        // 달력 타이틀 표시
        lblTitle.text = String(year) + "년 " + String(month) + "월"
    }
    
    @IBAction func btnRefresh(_ sender: Any) {
        self.cllcDate.reloadData()
    }
    
    @IBAction func btnWrite(_ sender: Any) {
        if let uvc = self.storyboard?.instantiateViewController(withIdentifier: "VCWrite") as? VCWrite {
            uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            uvc.modalPresentationStyle = .overCurrentContext
            self.present(uvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPre(_ sender: Any) {
        // 현재 년도와 달 업데이트
        if (month == 1) {
            year -= 1
            month = 12
        }
        else {
            month -= 1
        }
        // 달 시작 요일 업데이트
        startStr = calenderData.calcString(year: year, month: month, day: 1)
        startDate = formatter.date(from: startStr)!
        startDay = self.cal.dateComponents([.weekday], from: startDate).weekday! - 1
        // 달의 길이 업데이트
        lengthM = calenderData.calcLengthM(year: year, month: month)
        
        self.cllcDate.reloadData()
        lblTitle.text = String(year) + "년 " + String(month) + "월"
    }
    
    @IBAction func btnNext(_ sender: Any) {
        // 현재 년도와 달 업데이트
        if (month == 12) {
            year += 1
            month = 1
        }
        else {
            month += 1
        }
        // 달 시작 요일 업데이트
        startStr = calenderData.calcString(year: year, month: month, day: 1)
        startDate = formatter.date(from: startStr)!
        startDay = self.cal.dateComponents([.weekday], from: startDate).weekday! - 1
        // 달의 길이 업데이트
        lengthM = calenderData.calcLengthM(year: year, month: month)
        
        self.cllcDate.reloadData()
        lblTitle.text = String(year) + "년 " + String(month) + "월"
    }
    
    // 표현할 셀의 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (lengthM + startDay)
    }
    // 셀 표현
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.cllcDate.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        // 셀에 날짜 채우기
        let index = indexPath.row - startDay
        
        if (indexPath.row < startDay) {
            cell.lblDate.text = ""
        } else {
            cell.lblDate.text = String(index+1)
        }
        cell.lblDate.textColor = UIColor.black
        cell.backgroundColor = UIColor.white
        
        // 스케쥴 있는지 검사
        let contactDB = FMDatabase(path: dataPath)
        if contactDB.open() {
            let querySQL = "SELECT schedule FROM CONTACTS WHERE year = '\(year)' AND month = '\(month)' AND day = '\(index+1)'"
            let result :FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsIn: [])
            if result?.next() == true {
                cell.lblDate.textColor = UIColor.white
                cell.backgroundColor = UIColor(red:0.61, green:0.71, blue:0.85, alpha:1.0)
            }
            contactDB.close()
        }
        
        // 오늘이면 색깔 변경
        if (year == calenderData.curYear) && (month == calenderData.curMonth) && ((index+1) == calenderData.curDay) {
            cell.lblDate.textColor = UIColor.red
        }
        
        return cell
    }
    // 셀 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
