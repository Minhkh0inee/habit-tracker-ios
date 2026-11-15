import XCTest
import UIKit
@testable import HabitTracker

final class ImageStorageServiceTests: XCTestCase {
    private var testImagesToDelete: [String] = []
    
    override func tearDown() {
        for fileName in testImagesToDelete {
            ImageStorageService.shared.deleteProofImage(named: fileName)
        }
        testImagesToDelete.removeAll()
        super.tearDown()
    }
    
    // Helper to generate a test image
    private func createTestImage(width: CGFloat, height: CGFloat, color: UIColor = .blue) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    func testSaveAndLoadProofImage() {
        let testImage = createTestImage(width: 100, height: 100, color: .red)
        
        let savedFileName = ImageStorageService.shared.saveProofImage(testImage)
        XCTAssertNotNil(savedFileName)
        
        guard let fileName = savedFileName else { return }
        testImagesToDelete.append(fileName)
        
        let loadedImage = ImageStorageService.shared.loadProofImage(named: fileName)
        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(loadedImage?.size.width, 100)
        XCTAssertEqual(loadedImage?.size.height, 100)
    }
    
    func testLargeImageAutoResize_CapsAtMaxDimension() {
        // Create an excessively large image (3000 x 1500)
        let largeImage = createTestImage(width: 3000, height: 1500, color: .green)
        
        let savedFileName = ImageStorageService.shared.saveProofImage(largeImage)
        XCTAssertNotNil(savedFileName)
        
        guard let fileName = savedFileName else { return }
        testImagesToDelete.append(fileName)
        
        let loadedImage = ImageStorageService.shared.loadProofImage(named: fileName)
        XCTAssertNotNil(loadedImage)
        
        // Assert max dimension is scaled down to 1600 (or close due to float precision)
        let maxSide = max(loadedImage!.size.width, loadedImage!.size.height)
        XCTAssertLessThanOrEqual(maxSide, 1601)
        XCTAssertEqual(loadedImage!.size.width / loadedImage!.size.height, 2.0, accuracy: 0.05)
    }
    
    func testDeleteProofImage() {
        let testImage = createTestImage(width: 50, height: 50)
        let savedFileName = ImageStorageService.shared.saveProofImage(testImage)
        XCTAssertNotNil(savedFileName)
        
        guard let fileName = savedFileName else { return }
        
        // Delete image
        ImageStorageService.shared.deleteProofImage(named: fileName)
        
        // Attempt load should return nil
        let loadedImage = ImageStorageService.shared.loadProofImage(named: fileName)
        XCTAssertNil(loadedImage)
    }
    
    func testLoadNonExistentImage_ReturnsNil() {
        let loadedImage = ImageStorageService.shared.loadProofImage(named: "non_existent_\(UUID().uuidString).jpg")
        XCTAssertNil(loadedImage)
    }
}
