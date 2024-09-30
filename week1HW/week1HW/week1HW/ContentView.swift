import SwiftUI
import Vision

struct ContentView: View {
    @State private var inputImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var processedImage: UIImage? = nil

    var body: some View {
        VStack {
            if let processedImage = processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 300, height: 300)
                    .overlay(Text("Select an Image"))
            }

            Button("Select Image") {
                showingImagePicker = true
            }
            .padding()

            Button("Apply Googly Eyes") {
                if let inputImage = inputImage?.fixOrientation() {  // Fix orientation
                    print("Applying googly eyes to selected image")
                    detectFaces(in: inputImage) { faceObservations in
                        if !faceObservations.isEmpty {
                            print("Processing image with googly eyes")
                            processedImage = drawGooglyEyes(on: inputImage, faceObservations: faceObservations)
                        } else {
                            print("No faces found to apply googly eyes")
                        }
                    }
                } else {
                    print("No image selected")
                }
            }
            .padding()
            .disabled(inputImage == nil)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
