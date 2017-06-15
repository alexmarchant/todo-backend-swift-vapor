import Vapor

extension Droplet {
    func setupRoutes() throws {        
        try resource("todos", TodoController.self)
    }
}
