//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//Subjects act as both an observable and an observer.
//PublishSubject: Starts empty and only emits new elements to subscribers
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")

    let subscriptionOne = subject.subscribe(onNext: { string in
        print(string)
    })

    subject.on(.next("1"))
    subject.onNext("2")

    let subscriptionTwo = subject.subscribe{ event in
        print("2)", event.element ?? event)
    }

    subject.onNext("3")
    subscriptionOne.dispose()
    subject.onNext("4")

    subject.onCompleted()
    subject.onNext("5")

    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()

    subject
        .subscribe {
            print("3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

    subject.onNext("?")
}

enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error ?? event) ?? "Not found")
}

//Behavior subjects are useful when you want to pre populate a view with the most
//recent data.
example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()

    subject.subscribe {
        print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)

    subject.onNext("X")

    subject.onError(MyError.anError)

    subject.subscribe {
        print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)

    let disposeBag = DisposeBag()

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")

    subject.subscribe {
        print(label: "1)", event: $0)
    }.disposed(by: disposeBag)

    subject.subscribe {
        print(label: "2)", event: $0)
    }.disposed(by: disposeBag)

    subject.onNext("4")

    //Object `RxSwift.(unknown context at 0x12499a9f8).ReplayMany<Swift.String>` was already disposed.
//    subject.dispose()
    subject.subscribe {
        print(label:  "3)", event: $0)
    }.disposed(by: disposeBag)
    subject.onError(MyError.anError)
}

//[DEPRECATED] `Variable` is planned for future deprecation. Please consider `BehaviorRelay` as a replacement. Read more at: https://git.io/vNqvx
//It can receive the latest value.
example(of: "Variable") {
    let variable = Variable("Initial Value")

    let disposeBag = DisposeBag()

    variable.value = "New initial value"

    variable.asObservable()
        .subscribe {
            print(label: "1)", event: $0)
    }.disposed(by: disposeBag)

    variable.value = "1"

    variable.asObservable()
        .subscribe {
            print(label: "2)", event: $0)
    }.disposed(by: disposeBag)

    variable.value = "2"

}

//Challenge 1
example(of: "Challenge 1. PublishSubject") {

    let disposeBag = DisposeBag()

    let dealtHand = PublishSubject<[(String, Int)]>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()

        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        // Add code to update dealtHand here
        if points(for: hand) > 21 {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
    }

    // Add subscription to handSubject here
    dealtHand
        .subscribe(
            onNext: {
                print(cardString(for: $0), "for", points(for: $0), "points")
        },
            onError: {
                print(String(describing: $0).capitalized)
        })
        .disposed(by: disposeBag)

    deal(2)
}


example(of: "Challenge 2. Variable") {

    enum UserSession {
        case loggedIn, loggedOut
    }

    enum LoginError: Error {
        case invalidCredentials
    }

    let disposeBag = DisposeBag()

    // Create userSession Variable of type UserSession with initial value of .loggedOut
    let userSession = Variable(UserSession.loggedOut)

    // Subscribe to receive next events from userSession
    userSession.asObservable()
        .subscribe(onNext: {
            print("userSession changed:", $0)
        })
        .disposed(by: disposeBag)

    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
            password == "appleseed"
            else {
                completion(LoginError.invalidCredentials)
                return
        }

        // Update userSession
        userSession.value = .loggedIn
    }

    func logOut() {
        // Update userSession
        userSession.value = .loggedOut
    }

    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else {
            print("You can't do that!")
            return
        }

        action()
    }

    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"

        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }

            print("User logged in.")
        }

        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}


/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
