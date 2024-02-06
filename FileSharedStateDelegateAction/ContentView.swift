import ComposableArchitecture
import SwiftUI

@Reducer
struct ContentFeature {
  @ObservableState
  struct State: Equatable {
    @Shared(.fileStorage(.count)) var count = 0
    var status = false
    
    var counter = CounterFeature.State()
  }
  
  enum Action {
    case counter(CounterFeature.Action)
  }
  
  var body: some Reducer<State, Action> {
    Scope(state: \.counter, action: \.counter) {
      CounterFeature()
    }
    
    Reduce { state, action in
      switch action {
      case .counter(.delegate(let delegateAction)):
        switch delegateAction {
        case .toggleStatus:
          state.count += 10
          state.status.toggle()
          return .none
        }
        
      case .counter:
        return .none
      }
    }
  }
}

struct ContentView: View {
  let store: StoreOf<ContentFeature>
  
  var body: some View {
    VStack {
      CounterView(store: self.store.scope(state: \.counter, action: \.counter))
      Text("Status: \(self.store.status.description)")
      Text("Count from parent: \(self.store.count)")
    }
  }
}


@Reducer
struct CounterFeature {
  @ObservableState
  struct State: Equatable {
    @Shared(.fileStorage(.count)) var count = 0
  }
  
  enum Action {
    case delegate(Delegate)
    case increaseButtonTapped
    case toggleStatusButtonTapped
    
    @CasePathable
    enum Delegate {
      case toggleStatus
    }
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .increaseButtonTapped:
        state.count += 1
        return .none
      case .toggleStatusButtonTapped:
        return .send(.delegate(.toggleStatus))
      }
    }
  }
}

struct CounterView: View {
  let store: StoreOf<CounterFeature>
  
  var body: some View {
    Form {
      Text("Count: \(store.count)")
      Button("Increase") { store.send(.increaseButtonTapped) }
      Button("Toggle status") { store.send(.toggleStatusButtonTapped) }
    }
  }
}

#Preview {
  ContentView(
    store: Store(
      initialState: ContentFeature.State()
    ) {
      ContentFeature()
    }
  )
}

extension URL {
  static let count = Self.documentsDirectory.appending(path: "count")
}
