import SwiftUI

struct ContentView: View {
    
    @State private var prompt: String = ""
    @State private var responseURL: URL?
    
    var apiKey: String? {
        Bundle.main.infoDictionary?["IMAGE_API_KEY"] as? String
    }
    
    struct MyJsonObject: Encodable {
        let prompt: String
    }
    
    struct DecodedImage: Decodable {
        var created: Int
        var data: [ImageData]
    }
    
    struct ImageData: Decodable {
        var url: String
    }
    
    func postRequest() async throws {
        let myJsonObject = MyJsonObject(prompt: prompt)
        let payload = try JSONEncoder().encode(myJsonObject)
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            fatalError("Missing URL")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey!)", forHTTPHeaderField: "Authentication")
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error while fetching data")
        }
        let decodedImage = try JSONDecoder().decode(DecodedImage.self, from: data)
        responseURL = URL(string: decodedImage.data[0].url)
    }
    
    var body: some View {
        VStack {
            TextField("Test", text: $prompt)
            Button("Post") { }
            AsyncImage(url: responseURL)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
