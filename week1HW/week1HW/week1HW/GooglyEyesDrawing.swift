import SwiftUI
import Vision

func drawGooglyEyes(on image: UIImage, faceObservations: [VNFaceObservation]) -> UIImage {
    print("Drawing googly eyes on image")

    let imageSize = image.size
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

    image.draw(in: CGRect(origin: .zero, size: imageSize))

    guard let context = UIGraphicsGetCurrentContext() else {
        print("Failed to get CoreGraphics context")
        return image
    }

    context.setFillColor(UIColor.white.cgColor)

    for face in faceObservations {
        if let landmarks = face.landmarks,
           let leftEye = landmarks.leftEye,
           let rightEye = landmarks.rightEye {
            print("Eyes detected for face")

            let boundingBox = face.boundingBox
            let faceRect = CGRect(
                x: boundingBox.origin.x * imageSize.width,
                y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
                width: boundingBox.width * imageSize.width,
                height: boundingBox.height * imageSize.height
            )

            let leftEyePoints = leftEye.normalizedPoints.map { point in
                CGPoint(
                    x: faceRect.origin.x + point.x * faceRect.width,
                    y: faceRect.origin.y + (1 - point.y) * faceRect.height // Flipping Y-axis for UIKit
                )
            }
            let rightEyePoints = rightEye.normalizedPoints.map { point in
                CGPoint(
                    x: faceRect.origin.x + point.x * faceRect.width,
                    y: faceRect.origin.y + (1 - point.y) * faceRect.height // Flipping Y-axis for UIKit
                )
            }

            let leftEyeCenter = calculateCenter(of: leftEyePoints)
            let rightEyeCenter = calculateCenter(of: rightEyePoints)

            print("Drawing googly eyes at left eye: \(leftEyeCenter), right eye: \(rightEyeCenter)")

            let eyeRadius: CGFloat = 30.0

            context.addEllipse(in: CGRect(x: leftEyeCenter.x - eyeRadius, y: leftEyeCenter.y - eyeRadius, width: 2 * eyeRadius, height: 2 * eyeRadius))
            context.addEllipse(in: CGRect(x: rightEyeCenter.x - eyeRadius, y: rightEyeCenter.y - eyeRadius, width: 2 * eyeRadius, height: 2 * eyeRadius))
            context.setFillColor(UIColor.white.cgColor)
            context.fillPath()

            let pupilRadius: CGFloat = 10.0
            context.addEllipse(in: CGRect(x: leftEyeCenter.x - pupilRadius, y: leftEyeCenter.y - pupilRadius, width: 2 * pupilRadius, height: 2 * pupilRadius))
            context.addEllipse(in: CGRect(x: rightEyeCenter.x - pupilRadius, y: rightEyeCenter.y - pupilRadius, width: 2 * pupilRadius, height: 2 * pupilRadius))
            context.setFillColor(UIColor.black.cgColor)
            context.fillPath()
        } else {
            print("Eyes not detected for this face")
        }
    }

    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return finalImage ?? image
}

func calculateCenter(of points: [CGPoint]) -> CGPoint {
    guard !points.isEmpty else { return .zero }
    let sum = points.reduce(CGPoint.zero) { (result, point) -> CGPoint in
        CGPoint(x: result.x + point.x, y: result.y + point.y)
    }
    return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
}
