
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("ControlTabMapper Settings")
                .font(.largeTitle)
                .padding()

            Text("Select an application to enable Control-Tab mapping.")

            // A list of running applications will be displayed here.
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
