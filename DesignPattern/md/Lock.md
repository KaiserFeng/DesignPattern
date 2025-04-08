# Lock

## NSLock

NSLock的本质是对POSIX threads (pthread)互斥锁的封装。以下是其核心实现原理：

**底层实现**
```swift
// 简化的底层实现示意
class NSLock {
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
```

**关键特性：**
1. 基于pthread_mutex
- 使用pthread_mutex_t作为底层数据结构
- 提供互斥访问机制
- 支持递归锁定(通过pthread_mutex属性设置)

2. 状态管理
- 锁定/解锁两种状态
- 同一时间只允许一个线程持有
- 持有线程负责解锁

3. 性能特点
- 轻量级,系统开销小
- 适合短时间的临界区保护
- 比GCD队列和信号量更高效

在`Request`类中：
```swift
class Request {
    private var lock: NSLock = NSLock() // pthread_mutex底层实现
    private var _handled: Bool = false   // 受mutex保护的资源
    
    var handled: Bool {
        get {
            lock.lock()    // pthread_mutex_lock
            defer {
                lock.unlock() // pthread_mutex_unlock
            }
            return _handled
        }
    }
}
```

NSLock是最基础的同步原语之一，适合保护简单的共享资源访问。

