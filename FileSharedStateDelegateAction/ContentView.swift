import ComposableArchitecture
import SwiftUI

@Reducer
struct ParentFeature {
  @ObservableState
  struct State: Equatable {
    @Shared(.fileStorage(.count)) var count = 0  // Not used in child feature.
    var status = false  // Mutated via delegate action sent from child feature.
    
    var child = ChildFeature.State()
  }
  
  enum Action {
    case child(ChildFeature.Action)
  }
  
  var body: some Reducer<State, Action> {
    Scope(state: \.child, action: \.child) {
      ChildFeature()
    }
    
    Reduce { state, action in
      switch action {
      case .child(.delegate(let delegateAction)):
        switch delegateAction {
        case .toggleStatus:
          state.count += 1
          state.status.toggle()
          return .none
        }
        
      case .child:
        return .none
      }
    }
  }
}

struct ParentView: View {
  let store: StoreOf<ParentFeature>
  
  var body: some View {
    VStack {
      ChildView(store: self.store.scope(state: \.child, action: \.child))
      Text("Values from parent feature:")
      Text("Status: \(self.store.status.description)")
      Text("Count: \(self.store.count)")
    }
  }
}


@Reducer
struct ChildFeature {
  @ObservableState
  struct State: Equatable {
    var random = 0.0
  }
  
  enum Action {
    case delegate(Delegate)
    case randomValueButtonTapped
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
      case .randomValueButtonTapped:
        state.random = Double.random(in: 0...1)
        return .none
      case .toggleStatusButtonTapped:
        return .send(.delegate(.toggleStatus))
      }
    }
  }
}

struct ChildView: View {
  let store: StoreOf<ChildFeature>
  
  var body: some View {
    Form {
      Text("Random value: \(store.random)")
      Button("New random value") { store.send(.randomValueButtonTapped) }
      Button("Toggle parent feature status") { store.send(.toggleStatusButtonTapped) }
    }
  }
}

#Preview {
  ParentView(
    store: Store(
      initialState: ParentFeature.State()
    ) {
      ParentFeature()
    }
  )
}

extension URL {
  static let count = Self.documentsDirectory.appending(path: "count")
}
