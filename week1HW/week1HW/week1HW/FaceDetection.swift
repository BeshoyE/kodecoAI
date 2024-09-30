import Vision
import UIKit

func detectFaces(in image: UIImage, completion: @escaping ([VNFaceObservation]) -> Void) {
    guard let cgImage = image.cgImage else {
        print("Failed to get CGImage from UIImage")
        return
    }

    let request = VNDetectFaceLandmarksRequest { (request, error) in
        if let error = error {
            print("Error during face detection: \(error)")
            completion([])
            return
        }

        if let results = request.results as? [VNFaceObservation], !results.isEmpty {
            print("Faces detected: \(results.count)")
            completion(results)
        } else {
            print("No faces detected")
            completion([])
        }
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

    do {
        try handler.perform([request])
        print("Face detection request performed")
    } catch {
        print("Error performing face detection request: \(error)")
        completion([])
    }
}
