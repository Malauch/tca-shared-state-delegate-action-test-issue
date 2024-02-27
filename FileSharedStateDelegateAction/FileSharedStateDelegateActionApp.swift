import ComposableArchitecture
import SwiftUI

@main
struct FileSharedStateDelegateActionApp: App {
  var body: some Scene {
    WindowGroup {
      ParentView(
        store: Store(initialState: ParentFeature.State()) {
          ParentFeature()
        }
      )
    }
  }
}
