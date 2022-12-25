import SwiftUI

struct ContentView: View {
    
    @State private var prompt: String = ""
    @State private var responseURL: URL?
    @State private var displayImage: Bool = false
    
    var body: some View {
        VStack {
            TextField("Test", text: $prompt)
                .textFieldStyle(.roundedBorder)
            Button("Post") {
                Task {
                    do {
                        displayImage = true
                        responseURL = await URL(string: try NetworkRequest.postRequest(prompt: prompt))
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            if displayImage {
                AsyncImage(url: responseURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 300)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
