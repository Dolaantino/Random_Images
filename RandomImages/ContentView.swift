import SwiftUI
import Alamofire
import AlamofireImage

struct ContentView: View {
    @State private var randomImages: [UIImage] = []
    @State private var urlImageMap: [String: UIImage] = [:]

    var body: some View {
        NavigationView {
            VStack {
                Button("Загрузить случайное изображение", action: loadImage)
                    .buttonStyle(RoundedButtonStyle())
                    .padding()

                ForEach(urlImageMap.keys.sorted(), id: \.self) { url in
                    if let image = urlImageMap[url] {
                        NavigationLink(destination: ImageDetail(image: image)) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }
            .navigationTitle("Random Images")
        }
        .onAppear {
            if let data = UserDefaults.standard.value(forKey: "urlImageMapKey") as? Data {
                if let savedMap = try? PropertyListDecoder().decode([String: Data].self, from: data) {
                    urlImageMap = savedMap.reduce(into: [:]) { (result, element) in
                        if let image = UIImage(data: element.value) {
                            result[element.key] = image
                        }
                    }
                }
            }
        }
    }

    private func loadImage() {
        randomImages.removeAll()

        DispatchQueue.global(qos: .background).async {
            AF.request("https://loremflickr.com/200/300", requestModifier: { urlRequest in
                urlRequest.timeoutInterval = 30
            })
            .validate()
            .responseImage { response in
                if case .success(let image) = response.result {
                    if let url = response.request?.url?.absoluteString {
                        randomImages.append(image)
                        urlImageMap[url] = image

                        if let encodedMap = try? PropertyListEncoder().encode(urlImageMap.mapValues { $0.jpegData(compressionQuality: 1.0)! }) {
                            UserDefaults.standard.set(encodedMap, forKey: "urlImageMapKey")
                        }
                    }
                }
            }
        }
    }
}

struct ImageDetail: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button("< Назад") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedButtonStyle())
                .padding()
                
                Spacer()
            }
            .padding(.horizontal)

            Spacer()

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .navigationBarHidden(true)

            Spacer()
        }
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .cornerRadius(10)
    }
}


