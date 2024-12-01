//
//  ChronoDatePicker.swift
//  ChronoPicker
//
//  Created by Gerald Mahlknecht on 30.11.24.
//

import SwiftUI

// MARK: - ChronoDatePicker
public struct ChronoDatePicker: View {
    
    @Environment(\.isEnabled) var isEnabled
    
    /// First date of the month
    @State private var currentMonth: Date
    @State private var yearMonthSelectionOpen: Bool = false
    
    @Binding var selectedDate: Date?
    private let calendar: Calendar
    private let dateDisabled: ((Date) -> Bool)?
    
    public init(
        _ selectedDate: Binding<Date?>,
        calendar: Calendar = Calendar.current,
        dateDisabled: ((Date) -> Bool)? = nil
    ) {
        self._selectedDate = selectedDate
        self.calendar = calendar
        self.dateDisabled = dateDisabled
        
        let startOfMonth = calendar.startOfMonth(for: selectedDate.wrappedValue ?? Date())
        self._currentMonth = State(initialValue: startOfMonth)
    }
    
    public var body: some View {
        VStack {
            
            // MARK: Header
            HStack {
                HStack {
                    Text(monthYearString(for: currentMonth))
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(yearMonthSelectionOpen ? 90 : 0))
                }
                .font(.headline)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        yearMonthSelectionOpen.toggle()
                    }
                }
                
                
                Spacer()
                
                if !yearMonthSelectionOpen {
                    // MARK: Navigaion
                    Group {
                        Button(action: {
                            back()
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        
                        Button(action: {
                            next()
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.title2)
                }
            }
            .padding()
            
            // MARK: Content
            ZStack {
                // MARK: Quickselection
                if yearMonthSelectionOpen {
                    let yearMonthSelection = Binding<Date>(
                        get: { currentMonth },
                        set: { self.currentMonth = calendar.startOfMonth(for: $0) }
                    )
                    
                    MonthYearPicker(currentDate: yearMonthSelection)
                        .frame(maxWidth: .infinity)
                } else {
                    VStack {
                        // MARK: Week days
                        WeekdayHeader(calendar: calendar)
                        
                        // MARK: Calendar
                        ChronoCalendar(
                            selectedDate: $selectedDate,
                            month: currentMonth,
                            calendar: calendar,
                            dateDisabled: dateDisabled
                        )
                    }
                }
            }
        }
    }
    
    // MARK: Helpers
    
    private func next() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
    }
    private func back() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = calendar.locale // Ensure it matches the calendar locale
        return formatter.string(from: date)
    }
}

extension ChronoDatePicker {
    public init(
        _ selectedDate: Binding<Date?>,
        calendar: Calendar = Calendar.current,
        in range: Range<Date>
    ) {
        self.init(selectedDate, calendar: calendar, dateDisabled: { date in !range.contains(date) })
    }
    
    public init(
        _ selectedDate: Binding<Date?>,
        calendar: Calendar = Calendar.current,
        in range: PartialRangeFrom<Date>
    ) {
        self.init(selectedDate, calendar: calendar, dateDisabled: { date in !range.contains(date) })
    }
    
    public init(
        _ selectedDate: Binding<Date?>,
        calendar: Calendar = Calendar.current,
        in range: PartialRangeUpTo<Date>
    ) {
        self.init(selectedDate, calendar: calendar, dateDisabled: { date in !range.contains(date) })
    }
    
    public init(
        _ selectedDate: Binding<Date?>,
        calendar: Calendar = Calendar.current,
        in range: ClosedRange<Date>
    ) {
        self.init(selectedDate, calendar: calendar, dateDisabled: { date in !range.contains(date) })
    }
}


// MARK: - Preview
private struct ChronoPickerPreview: View {
    
    @State private var selectedDate: Date? = nil
    var calendar = Calendar.current
    var dateDisabled: ((Date) -> Bool)? = nil
    
    var body: some View {
        VStack {
            ChronoDatePicker($selectedDate, calendar: calendar, dateDisabled: dateDisabled)
                .frame(maxWidth: .infinity)
            
            if let selectedDate = selectedDate {
                Text("Selected Date: \(selectedDate, formatter: dateFormatter)")
            } else {
                Text("No date selected")
            }
        }
        .padding()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview("System calendar") {
    VStack {
        ChronoPickerPreview(calendar: Calendar.current)
        Spacer()
    }
}

#Preview("sunday first of the week") {
    var europeanCalendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.locale = Locale.autoupdatingCurrent
        return calendar
    }
    
    ChronoPickerPreview(calendar: europeanCalendar)
}

#Preview("Calendar Disabled") {
    ChronoPickerPreview()
        .disabled(true)
}

#Preview("Today disabled") {
    let today = Date()
    let yesterday = today.addingTimeInterval(-86400)
    
    ChronoDatePicker(Binding.constant(yesterday)) { date in
        Calendar.current.isDate(date, equalTo: today, toGranularity: .weekday)
    }
}

#Preview("Date within range disabled") {
    let today = Date()
    let yesterday = today.addingTimeInterval(-86400)
    
    ChronoDatePicker(Binding.constant(today), in: ..<yesterday)
}
