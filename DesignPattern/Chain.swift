import Foundation

enum ChainError: Error {
    case invalidRequest
    case handlerNotFound
    case processingFailed(String)
}

class Request {
    let type: String
    private(set) var error: Error?
    private var _handled: Bool = false
    private var lock: NSLock = NSLock()
    
    var handled: Bool {
        get {
            lock.lock()
            defer {
                lock.unlock()
            }
            return _handled
        }
        set {
            lock.lock()
            _handled = newValue
            lock.unlock()
        }
    }
    
    init(type: String) {
        self.type = type
    }
    
    func setError(_ error: Error) {
        lock.lock()
        defer {
            lock.unlock()
        }
        self.error = error
    }
}

protocol Handler: AnyObject {
    var next: Handler? {set get}
    func handleRequest(_ request: Request) throws
    func processRequest(_ request: Request) throws -> Bool
}

class BaseHandler: Handler {
    var next: Handler?
    
    func handleRequest(_ request: Request) throws {
        let handled: Bool = try processRequest(request)
        if handled {
            request.handled = true
            /// 如果已处理直接结束，也可以继续后续的处理器，根据业务需求来处理。
            return
        }
        guard let next = next  else {
            throw ChainError.handlerNotFound
        }
        try next.handleRequest(request)
    }
    
    func processRequest(_ request: Request) throws -> Bool {
        false
    }
}

class ValidationHandler: BaseHandler {
    override func processRequest(_ request: Request) throws -> Bool {
        guard !request.type.isEmpty else {
            throw ChainError.invalidRequest
        }
        print("validation unHandled")
        return false
    }
}

class ProcessHandler: BaseHandler {
    override func processRequest(_ request: Request) throws -> Bool {
        if request.type == "process" {
            throw ChainError.processingFailed("Failed to process request")
        }
        print("process unHandled")
        return false
    }
}

class LogHandler: BaseHandler {
    override func processRequest(_ request: Request) throws -> Bool {
        if request.type == "log" {
            print("logging request")
            request.handled = true
            return true
        }
        print("logging unHandled")
        return false
    }
}

class AuthHandler: BaseHandler {
    override func processRequest(_ request: Request) throws -> Bool {
        if request.type == "auth" {
            print("authenticating request")
            request.handled = true
            return true
        }
        print("authenticating unHandled")
        return false
    }
}

class ChainManager {
    private var header: Handler?
    private let queue = DispatchQueue(label: "com.chainmanager.queue", attributes: .concurrent)
    
    func addHandler(_ handler: Handler) {
        queue.async(flags: .barrier) { [weak self] in
            if self?.header == nil {
                self?.header = handler
                return
            }
            
            var current = self?.header
            while current?.next != nil {
                current = current?.next
            }
            current?.next = handler
        }
    }
    
    func progress(_ request: Request, completion: @escaping (Error?) -> Void) {
        queue.async { [weak self] in
            guard let header = self?.header else {
                completion(ChainError.handlerNotFound)
                return
            }
            
            do {
                try header.handleRequest(request)
                completion(nil)
            }
            catch {
                request.setError(error)
                completion(error)
            }
        }
    }
}
