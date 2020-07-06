//
//  RDFBirthDate.swift
//  IdolBirthdayBackend
//
//  Created by user on 2020/06/25.
//

import Foundation
import Regex

public struct RDFBirthDate {
    public var month: UInt8
    public var day: UInt8
    
    static let regex = try! Regex(string: "--([0-9]{2})-([0-9]{2})")
    
    public init?(string: String) {
        guard let result = Self.regex.firstMatch(in: string) else {
            return nil
        }
        let captures = result.captures.map { UInt8($0!) }
        month = captures[0]!
        day = captures[1]!
    }
    
    /// 今日が誕生日かどうかを判定する
    public func isBirthDay(current: Date, calendar: Calendar) -> Bool {
        let currentMonth = calendar.component(.month, from: current)
        let currentDay = calendar.component(.day, from: current)
        return currentMonth == month && currentDay == day
    }
    
    /// 今年の誕生日が終わったかどうかを判定する
    public func isThisYearBirthDateAlreadyPassed(current: Date, calendar: Calendar) -> Bool {
        let currentMonth = calendar.component(.month, from: current)
        guard currentMonth == month else {
            return currentMonth > month
        }
        let currentDay = calendar.component(.day, from: current)
        return currentDay > day // 当日だったらまだ終わってないのでfalseが返るべき
    }
    
    /// current から見て次に来る誕生日を返す
    public func next(current: Date = Date(), calendar: Calendar = .current) -> Date {
        let nextYear = isThisYearBirthDateAlreadyPassed(current: current, calendar: calendar)
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            era: calendar.component(.era, from: current),
            year: calendar.component(.year, from: current) + (nextYear ? 1 : 0),
            month: Int(month),
            day: Int(day)
        )
        return components.date!
    }
}
