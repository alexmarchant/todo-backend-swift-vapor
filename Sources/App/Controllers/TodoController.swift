//
//  TaskController.swift
//  TodoBackend
//
//  Created by Alex Marchant on 6/15/17.
//
//

import Vapor
import HTTP

final class TodoController: ResourceRepresentable {
    func index(req: Request) throws -> ResponseRepresentable {
        return try Todo.all().makeJSON()
    }
    
    func create(req: Request) throws -> ResponseRepresentable {
        let todo = try req.todo()
        try todo.save()
        return todo
    }
    
    func show(req: Request, todo: Todo) throws -> ResponseRepresentable {
        return todo
    }
    
    func update(req: Request, todo: Todo) throws -> ResponseRepresentable {
        try todo.update(for: req)
        try todo.save()
        return todo
    }
    
    func delete(req: Request, todo: Todo) throws -> ResponseRepresentable {
        try todo.delete()
        return Response(status: .ok)
    }
    
    func clear(req: Request) throws -> ResponseRepresentable {
        try Todo.makeQuery().delete()
        return Response(status: .ok)
    }
    
    func makeResource() -> Resource<Todo> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func todo() throws -> Todo {
        guard let json = json else { throw Abort.badRequest }
        return try Todo(json: json)
    }
}

/// Since TodoController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
/// This will allow it to be passed by type.
extension TodoController: EmptyInitializable { }
