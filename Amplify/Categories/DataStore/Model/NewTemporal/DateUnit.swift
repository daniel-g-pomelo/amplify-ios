//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// `DateUnit` for use in adding and subtracting units from `Temporal.Date`, `Temporal.DateTime`, and `Temporal.Time`.
///
/// `DateUnit` uses `Calendar.Component` under the hood to ensure date oddities are accounted for.
///
///     let tomorrow = Temporal.Date.now() + .days(1)
///     let twoWeeksFromNow = Temporal.Date.now() + .weeks(2)
///     let nextYear = Temporal.Date.now() + .years(1)
///
///     let yesterday = Temporal.Date.now() - .days(1)
///     let sixMonthsAgo = Temporal.Date.now() - .months(6)
// swiftlint:disable:next type_name
public struct _DateUnit {
    let calendarComponent: Calendar.Component
    let value: Int

    /// One day. Equivalent to 1 x `Calendar.Component.day`
    public static let oneDay: _DateUnit = .days(1)

    /// One week. Equivalent to 7 x `Calendar.Component.day`
    public static let oneWeek: _DateUnit = .weeks(1)

    /// One month. Equivalent to 1 x `Calendar.Component.month`
    public static let oneMonth: _DateUnit = .months(1)

    /// One year. Equivalent to 1 x `Calendar.Component.year`
    public static let oneYear: _DateUnit = .years(1)

    /// DateUnit amount of days.
    /// One day is 1 x `Calendar.Component.day`
    ///
    ///     let fiveDays = DateUnit.days(5)
    ///     // or
    ///     let fiveDays: DateUnit = .days(5)
    ///
    /// - Parameter value: Amount of days in this `DateUnit`
    /// - Returns: A `DateUnit` with the defined number of days.
    public static func days(_ value: Int) -> Self {
        .init(calendarComponent: .day, value: value)
    }

    /// DateUnit amount of weeks.
    /// One week is 7 x the `Calendar.Component.day`
    ///
    ///     let twoWeeks = DateUnit.weeks(2)
    ///     // or
    ///     let twoWeeks: DateUnit = .weeks(2)
    ///
    /// - Parameter value: Amount of weeks in this `DateUnit`
    /// - Returns: A `DateUnit` with the defined number of weeks.
    public static func weeks(_ value: Int) -> Self {
        .init(calendarComponent: .day, value: value * 7)
    }

    /// DateUnit amount of months.
    /// One month is 1 x `Calendar.Component.month`
    ///
    ///     let sixMonths = DateUnit.months(6)
    ///     // or
    ///     let sixMonths: DateUnit = .months(6)
    ///
    /// - Parameter value: Amount of months in this `DateUnit`
    /// - Returns: A `DateUnit` with the defined number of months.
    public static func months(_ value: Int) -> Self {
        .init(calendarComponent: .month, value: value)
    }

    /// DateUnit amount of years.
    /// One year is 1 x `Calendar.Component.year`
    ///
    ///     let oneYear = DateUnit.years(1)
    ///     // or
    ///     let oneYear: DateUnit = .years(1)
    ///
    /// - Parameter value: Amount of years in this `DateUnit`
    /// - Returns: A `DateUnit` with the defined number of years.
    public static func years(_ value: Int) -> Self {
        .init(calendarComponent: .year, value: value)
    }
}
