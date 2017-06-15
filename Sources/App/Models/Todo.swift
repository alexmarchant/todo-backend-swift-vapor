//
//  Task.swift
//  TodoBackend
//
//  Created by Alex Marchant on 6/15/17.
//
//

import Vapor
import FluentProvider
import HTTP
import Foundation

final class Todo: Model {
    var title: String
    var completed: Bool
    var order: Int
    let storage = Storage()
    
    static let idKey = "id"
    static let titleKey = "title"
    static let completedKey = "completed"
    static let orderKey = "order"
    
    init(row: Row) throws {
        self.title = try row.get("title")
        self.completed = try row.get("completed")
        self.order = try row.get("order")
    }
    
    init(title: String, completed: Bool?, order: Int?) {
        self.title = title
        self.completed = completed ?? true
        self.order = order ?? 0
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("completed", completed)
        try row.set("order", order)
        return row
    }
    
    func url() -> String {
        guard
            let rootURL = ProcessInfo.processInfo.environment["ROOT_URL"],
            let id = self.id?.string
        else {
            fatalError("Can't generate URL for todo")
        }
        return "\(rootURL)/todos/\(id)"
    }
}

// MARK: Fluent Preparation

extension Todo: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Todo.titleKey, length: nil, optional: false, unique: false, default: nil)
            builder.bool(Todo.completedKey, optional: false, unique: false, default: false)
            builder.int(Todo.orderKey, optional: false, unique: false, default: 0)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Todo: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            title: json.get(Todo.titleKey),
            completed: try? json.get(Todo.completedKey),
            order: try? json.get(Todo.orderKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Todo.idKey, id)
        try json.set(Todo.titleKey, title)
        try json.set(Todo.completedKey, completed)
        try json.set(Todo.orderKey, order)
        try json.set("url", url())
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Todo: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Todo: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Todo>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Todo.titleKey, String.self) { todo, title in
                todo.title = title
            },
            UpdateableKey(Todo.completedKey, Bool.self) { todo, completed in
                todo.completed = completed
            },
            UpdateableKey(Todo.orderKey, Int.self) { todo, order in
                todo.order = order
            },
        ]
    }
}
