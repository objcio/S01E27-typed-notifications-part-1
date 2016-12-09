import Foundation
import PlaygroundSupport

let center = NotificationCenter.default

struct NotificationDescriptor<A> {
    let name: Notification.Name
    let convert: (Notification) -> A
}

struct PlaygroundPagePayload {
    let page: PlaygroundPage
    let needsIndefiniteExecution: Bool
}

extension PlaygroundPagePayload {
    init(note: Notification) {
        page = note.object as! PlaygroundPage
        needsIndefiniteExecution = note.userInfo?["PlaygroundPageNeedsIndefiniteExecution"] as! Bool
    }
}

let playgroundNotification = NotificationDescriptor<PlaygroundPagePayload>(name: Notification.Name("PlaygroundPageNeedsIndefiniteExecutionDidChangeNotification"), convert: PlaygroundPagePayload.init)

class Token {
    let token: NSObjectProtocol
    let center: NotificationCenter
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {
    func addObserver<A>(descriptor: NotificationDescriptor<A>, using block: @escaping (A) -> ()) -> Token {
        let token = addObserver(forName: descriptor.name, object: nil, queue: nil, using: { note in
            block(descriptor.convert(note))
        })
        return Token(token: token, center: self)
    }
}


var token: Token? = center.addObserver(descriptor: playgroundNotification, using: {
    print($0)
})


PlaygroundPage.current.needsIndefiniteExecution = true
token = nil
PlaygroundPage.current.needsIndefiniteExecution = false
