//
//  Date+Extensions.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation

// Enum to define all supported date formats with more readable case names
enum DateFormat: String, CaseIterable {
    case h_mm_a = "h:mm a"                                           // 8:05 AM
    case HH_mm_ss = "HH:mm:ss"                                       // 08:05:16
    case dd_MM_yy = "dd.MM.yy"                                      // 30.01.25
    case MM_dd_yyyy = "MM/dd/yyyy"                                  // 01/30/2025
    case HH_mm_ss_SSS = "HH:mm:ss.SSS"                              // 08:05:16.864
    case dd_MMM_yyyy = "dd MMM yyyy"                                // 25 Sep 2026
    case MMM_d_yyyy = "MMM d, yyyy"                                 // Jan 30, 2025
    case MMMM_yyyy = "MMMM yyyy"                                    // January 2025
    case MMM_d_h_mm_a = "MMM d, h:mm a"                             // Jan 30, 8:05 AM
    case MM_dd_yyyy_HH_mm = "MM-dd-yyyy HH:mm"                      // 01-30-2025 08:05
    case EEEE_MMM_d_yyyy = "EEEE, MMM d, yyyy"                      // Thursday, Jan 30, 2025
    case E_d_MMM_yyyy_HH_mm_ss_Z = "E, d MMM yyyy HH:mm:ss Z"      // Thu, 30 Jan 2025 08:05:16 +0000
    case yyyy_MM_dd_T_HH_mm_ss_Z = "yyyy-MM-dd'T'HH:mm:ssZ"        // 2025-01-30T08:05:16+0000
    case yyyy_MM_dd_T_HH_mm_ss_SSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  // 2025-01-30T08:05:16.864+0000
}

extension Date {
    
    // MARK: - Convert String to Date (Auto-detects format)
    static func fromString(_ dateString: String?, timeZone: TimeZone = .current) -> Date? {
        // Return nil if the input string is nil
        guard let dateString = dateString else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        
        // Loop through all defined date formats to try parsing the string
        for format in DateFormat.allCases {
            dateFormatter.dateFormat = format.rawValue
            if let date = dateFormatter.date(from: dateString) {
                return date // Return the first successfully parsed date
            }
        }
        return nil // Return nil if no formats matched
    }

    // MARK: - Convert Date to String
    func toString(format: DateFormat, timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self) // Return the formatted date string
    }
    
    // MARK: - Convert Date to Any Time Zone
    func toTimeZone(_ timeZone: TimeZone) -> Date {
        let calendar = Calendar.current
        let currentOffset = TimeZone.current.secondsFromGMT(for: self)
        let targetOffset = timeZone.secondsFromGMT(for: self)
        let offsetDifference = targetOffset - currentOffset
        return calendar.date(byAdding: .second, value: offsetDifference, to: self) ?? self
    }
    
    // MARK: - Add or Subtract Days, Months, Years
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self // Add days
    }

    func addingMonths(_ months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self // Add months
    }

    func addingYears(_ years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self // Add years
    }

    // MARK: - Get Start and End of the Day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self) // Get the start of the current day (00:00:00)
    }

    var endOfDay: Date {
        return Calendar.current.date(byAdding: .second, value: 86399, to: startOfDay) ?? self // Get the end of the current day (23:59:59)
    }

    // MARK: - Check If Date is Today, Yesterday, or Tomorrow
    var isToday: Bool {
        return Calendar.current.isDateInToday(self) // Check if the date is today
    }

    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self) // Check if the date is yesterday
    }

    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self) // Check if the date is tomorrow
    }

    // MARK: - Get Day, Month, Year Components
    var day: Int {
        return Calendar.current.component(.day, from: self) // Get the day component
    }

    var month: Int {
        return Calendar.current.component(.month, from: self) // Get the month component
    }

    var year: Int {
        return Calendar.current.component(.year, from: self) // Get the year component
    }

    // MARK: - Get Weekday Name
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Set date format to get full weekday name
        return formatter.string(from: self) // Return the weekday name
    }

    // MARK: - Get Time Ago String
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date()) // Return a human-readable time ago string
    }
}
