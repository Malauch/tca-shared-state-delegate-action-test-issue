import ComposableArchitecture
import SwiftUI

@main
struct FileSharedStateDelegateActionApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(initialState: ContentFeature.State()) {
          ContentFeature()
        }
      )
    }
  }
}
