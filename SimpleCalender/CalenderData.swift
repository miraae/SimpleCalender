//
//  CalenderData.swift
//  SimpleCalender
//
//  Created by 노미래 on 2018. 11. 3..
//  Copyright © 2018년 Mirae. All rights reserved.
//

import Foundation

class CalenderData {
    
    let date = Date()
    let cal = Calendar(identifier: .gregorian)
    
    let curYear:Int
    let curMonth:Int
    let curDay:Int
    
    init() {
        curYear = self.cal.component(.year, from: date)
        curMonth = self.cal.component(.month, from: date)
        curDay = self.cal.component(.day, from: date)
    }
    
    func calcLengthM (year:Int, month:Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31;
        case 4, 6, 9, 11:
            return 30;
        case 2:
            if (year % 4 == 0) { return 29 }
            else { return 28 }
        default:
            return 0
        }
    }
    
    func calcString (year:Int, month:Int, day:Int) -> String {
        
        var dayString:String = String(year) + "-"
        if (month < 10) {
            dayString.append("0"+String(month))
        } else {
            dayString.append(String(month))
        }
        if (day < 10) {
            dayString.append("-0"+String(day))
        } else {
            dayString.append("-"+String(day))
        }
        return dayString
    }
}

var dataPath = String()
