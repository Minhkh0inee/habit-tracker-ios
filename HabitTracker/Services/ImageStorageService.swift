import UIKit

public final class ImageStorageService {
    public static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let proofsDirectoryName = "Proofs"
    
    private var proofsDirectoryURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent(proofsDirectoryName, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private init() {}
    
    /// Saves an image to the local documents proofs directory and returns the unique filename
    @discardableResult
    public func saveProofImage(_ image: UIImage) -> String? {
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = proofsDirectoryURL.appendingPathComponent(fileName)
        
        // Resize image if excessively large to keep storage light and fast
        let resized = resizeImageIfNeeded(image, maxDimension: 1600)
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            print("Failed to save proof image: \(error)")
            return nil
        }
    }
    
    /// Loads a stored proof image by filename
    public func loadProofImage(named fileName: String) -> UIImage? {
        let fileURL = proofsDirectoryURL.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Deletes a stored proof image if it exists
    public func deleteProofImage(named fileName: String) {
        let fileURL = proofsDirectoryURL.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Helper Image Resizer
    private func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }
        
        let ratio = maxDimension / maxSide
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
