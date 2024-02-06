import ComposableArchitecture
import XCTest
@testable import FileSharedStateDelegateAction

@MainActor
final class FileSharedStateDelegateActionTests: XCTestCase {
  
  func testExample() async {
    let store = TestStore(initialState: ContentFeature.State()) {
      ContentFeature()
    }

    #warning("Issue here")
    // Here is a weird behaviour. Count is mutated after receiving delegate action (#2) but TestStore shows state mutation on action which only sends delegate action (#1).
    // Problem occurs only when delegate action is send synchronously.
    await store.send(.counter(.toggleStatusButtonTapped))  // #1
    await store.receive(\.counter.delegate.toggleStatus) {  // #2
      $0.status = true
      $0.count = 10
    }
  }
}
