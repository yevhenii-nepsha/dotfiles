import Foundation
import EventKit

// Reminders helper for SketchyBar.
// Uses native EventKit — does not block Reminders.app UI.
//
// Usage:
//   reminder_count count    — print count of due/overdue incomplete reminders
//   reminder_count list     — print JSON array of due/overdue reminders [{id, title, due}]
//   reminder_count complete <calendarItemIdentifier> — mark a reminder as complete

let store = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

func getEndOfToday() -> Date? {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
}

func countReminders() {
    guard let endOfToday = getEndOfToday() else {
        print("0")
        semaphore.signal()
        return
    }

    let predicate = store.predicateForIncompleteReminders(
        withDueDateStarting: nil,
        ending: endOfToday,
        calendars: nil
    )

    store.fetchReminders(matching: predicate) { reminders in
        print("\(reminders?.count ?? 0)")
        semaphore.signal()
    }
}

func listReminders() {
    guard let endOfToday = getEndOfToday() else {
        print("[]")
        semaphore.signal()
        return
    }

    let predicate = store.predicateForIncompleteReminders(
        withDueDateStarting: nil,
        ending: endOfToday,
        calendars: nil
    )

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    let now = Date()
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US_POSIX")

    store.fetchReminders(matching: predicate) { reminders in
        guard let reminders = reminders else {
            print("[]")
            semaphore.signal()
            return
        }

        // Sort by due date (nil dates last)
        let sorted = reminders.sorted { a, b in
            guard let da = a.dueDateComponents?.date else { return false }
            guard let db = b.dueDateComponents?.date else { return true }
            return da < db
        }

        var items: [[String: Any]] = []
        for r in sorted {
            var item: [String: Any] = [
                "id": r.calendarItemIdentifier,
                "title": r.title ?? "(no title)"
            ]
            if let dueComps = r.dueDateComponents, let dueDate = dueComps.date {
                // Check if reminder has a specific time set (hour component exists)
                let hasTime = dueComps.hour != nil
                item["due"] = dateFormatter.string(from: dueDate)
                item["hasTime"] = hasTime

                // For reminders without a specific time, only mark overdue
                // if the due date is before today (not just before now)
                if hasTime {
                    item["overdue"] = dueDate < now
                } else {
                    let startOfToday = calendar.startOfDay(for: now)
                    item["overdue"] = dueDate < startOfToday
                }
            }
            items.append(item)
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: items),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print("[]")
        }
        semaphore.signal()
    }
}

func completeReminder(identifier: String) {
    let predicate = store.predicateForIncompleteReminders(
        withDueDateStarting: nil,
        ending: Date.distantFuture,
        calendars: nil
    )

    store.fetchReminders(matching: predicate) { reminders in
        guard let reminders = reminders else {
            print("error: no reminders found")
            semaphore.signal()
            return
        }

        if let target = reminders.first(where: { $0.calendarItemIdentifier == identifier }) {
            target.isCompleted = true
            do {
                try store.save(target, commit: true)
                print("ok")
            } catch {
                print("error: \(error.localizedDescription)")
            }
        } else {
            print("error: reminder not found")
        }
        semaphore.signal()
    }
}

func run(command: String, arg: String?) {
    switch command {
    case "count":
        countReminders()
    case "list":
        listReminders()
    case "complete":
        guard let id = arg, !id.isEmpty else {
            print("error: missing reminder id")
            semaphore.signal()
            return
        }
        completeReminder(identifier: id)
    default:
        print("error: unknown command '\(command)'. Use: count, list, complete <id>")
        semaphore.signal()
    }
}

let command = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "count"
let arg = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil

if #available(macOS 14.0, *) {
    store.requestFullAccessToReminders { granted, error in
        if granted {
            run(command: command, arg: arg)
        } else {
            print("error: access denied")
            semaphore.signal()
        }
    }
} else {
    store.requestAccess(to: .reminder) { granted, error in
        if granted {
            run(command: command, arg: arg)
        } else {
            print("error: access denied")
            semaphore.signal()
        }
    }
}

_ = semaphore.wait(timeout: .distantFuture)
