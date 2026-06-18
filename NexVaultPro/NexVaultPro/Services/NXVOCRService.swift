//
//  NXVOCRService.swift
//  NexVaultPro
//
//  Document text recognition via the Vision framework.
//

import UIKit
import Vision

final class NXVOCRService {
    static let shared = NXVOCRService()

    enum NXVOCRError: Error { case invalidImage, noText }

    /// Recognize text in an image. Completion is delivered on the main queue.
    func nxvRecognizeText(in image: UIImage,
                          completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async { completion(.failure(NXVOCRError.invalidImage)) }
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async {
                if lines.isEmpty {
                    completion(.failure(NXVOCRError.noText))
                } else {
                    completion(.success(lines.joined(separator: "\n")))
                }
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
