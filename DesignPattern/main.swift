import Foundation

// MARK: Chain
func testChain() {
    let chainManager = ChainManager()
    chainManager.addHandler(ValidationHandler())
    chainManager.addHandler(ProcessHandler())
    chainManager.addHandler(LogHandler())
    chainManager.addHandler(AuthHandler())
    
    let semaphore = DispatchSemaphore(value: 0)
    chainManager.progress(Request(type: "log")) { error in
        if let error = error {
            print("1", error)
        }
        semaphore.signal()
    }
    
    semaphore.wait()
    
    
    
//    DispatchQueue.concurrentPerform(iterations: 10) { index in
//        let threadId = Thread.current.description
//        print("Starting Request \(index) on thread: \(threadId)")
//        
//        let requests = [
//            Request(type: ""),
//            Request(type: "process"),
//            Request(type: "log"),
//            Request(type: "auth")
//        ]
//        
//        let semaphore = DispatchSemaphore(value: 0)
//        
//        let request = requests.randomElement()!
//        chainManager.progress(request) { error in
//            print("Completed Request \(index) on thread: \(threadId)")
//            if let error = error {
//                print("Error \(index) on thread \(threadId)", error)
//            }
//            
//            semaphore.signal()
//        }
//        
//        semaphore.wait()
//    }
}

testChain()

// MARK: - xxx




 
