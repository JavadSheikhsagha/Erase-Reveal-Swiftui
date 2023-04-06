//
//  ContentView.swift
//  Paint to Remove and Reveal
//
//  Created by enigma 1 on 4/6/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var maskImage =
        UIImage(named: "imgBlack")!
        .resize(to: CGSize(width: UIScreen.screenWidth, height: UIScreen.screenWidth))!
    @State var erase : Bool = true
    @State var diameter = 30.0
    
    var body: some View {
        VStack {
            
            ZStack {
                Color.black
                
                Image("imgTransparentPattern")
                    .resizable()
                
                Image("imgSample")
                    .resizable()
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    .mask {
                        Image(uiImage: maskImage)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                
                                if erase {
                                    erase(fromPoint: value.location, toPoint: value.location, diameter: diameter)
                                } else {
                                    let img = maskImage.drawRectangleOnImage(value.location, diameter: diameter)
                                    maskImage = combinedImages(foreground: maskImage, background:img)
                                }
                                
                            }
                    )
                    .onAppear {
                        maskImage = combinedImages(foreground: maskImage, background:maskImage)
                    }
            }
            .ignoresSafeArea()
            .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
            
            VStack {
                
                Spacer()
                    .frame(height: 128)
                
                Toggle(isOn: $erase) {
                    Text(erase ? "Erase" : "Reveal")
                }
                .frame(width: 130)
                
                Spacer()
                    .frame(height: 32)
                
                HStack {
                    Slider(value: $diameter, in: 10...70)
                        .frame(width: UIScreen.screenWidth / 2)
                    
                    
                    Text("\(Int(diameter))")
                }
            }
            .frame(height: 100)
            
            Spacer()
                .frame(height: 100)
        }
    }
    
    func erase(fromPoint: CGPoint, toPoint: CGPoint, diameter : CGFloat) {
        UIGraphicsBeginImageContextWithOptions(UIImageView(image: maskImage).bounds.size, false, 1)
        //UIGraphicsBeginImageContext(lassoImageView.bounds.size)
        //UIGraphicsBeginImageContext(lassoImageView.image!.size)
        let context = UIGraphicsGetCurrentContext()
        UIImageView(image: maskImage)
            .image?
            .draw(in: CGRect(x: 0,
                             y: 0,
                             width: UIImageView(image: maskImage).frame.size.width,
                             height: UIImageView(image: maskImage).frame.size.height))
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)

        context?.setLineCap(.round)
        context?.setLineWidth(CGFloat(diameter))
        context?.setBlendMode(.clear)
        context?.setStrokeColor(UIColor.clear.cgColor)
        context?.strokePath()

        maskImage = UIGraphicsGetImageFromCurrentImageContext()!
//            croppedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
//        guard let image = maskImage else { return }
//        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
//        if let context = UIGraphicsGetCurrentContext() {
//            mainImageView.layer.render(in: context)
//            context.addPath(currentPath.cgPath)
//            context.setBlendMode(.clear)
//            context.setLineWidth(translatedBrushWidth)
//            context.setLineCap(.round)
//            context.setLineJoin(.round)
//            context.setStrokeColor(UIColor.clear.cgColor)
//            context.strokePath()
//
//            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
//            imageView.image = capturedImage
//        }
//
//        UIGraphicsEndImageContext()
    }
    
    func combinedImages(foreground:UIImage?, background:UIImage?) -> UIImage {
        let size = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        UIGraphicsBeginImageContext(size)

        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        background?.draw(in: areaSize)
        
        foreground?.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension UIImage {
    
    func drawRectangleOnImage(_ point: CGPoint, diameter : CGFloat) -> UIImage? {
        let imageSize = self.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let context = UIGraphicsGetCurrentContext()

        let rectangle = CGRect(x: point.x - diameter/2, y: point.y - diameter/2, width: diameter, height: diameter)

        context!.setFillColor(UIColor.white.cgColor)
        context!.setAlpha(1.0)
        context!.setLineWidth(5)
        context!.addRect(rectangle)
        context!.fillEllipse(in: rectangle)
        
//        context!.setFillColor(UIColor.white.cgColor)
//        context!.setAlpha(1.0)
//        context?.setLineCap(.round)
//        context?.setLineWidth(100)
//        context?.setBlendMode(.clear)
//        context!.addRect(rectangle)
//        context?.setShouldAntialias(true)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    

}

extension UIImage {

    public enum ResizeFramework {
        case uikit, coreImage, coreGraphics, imageIO
    }

    /// Resize image with ScaleAspectFit mode and given size.
    ///
    /// - Parameter dimension: width or length of the image output.
    /// - Parameter resizeFramework: Technique for image resizing: UIKit / CoreImage / CoreGraphics / ImageIO / Accelerate.
    /// - Returns: Resized image.

    func resizeWithScaleAspectFitMode(to dimension: CGFloat, resizeFramework: ResizeFramework = .coreGraphics) -> UIImage? {

        if max(size.width, size.height) <= dimension { return self }

        var newSize: CGSize!
        let aspectRatio = size.width/size.height

        if aspectRatio > 1 {
            // Landscape image
            newSize = CGSize(width: dimension, height: dimension / aspectRatio)
        } else {
            // Portrait image
            newSize = CGSize(width: dimension * aspectRatio, height: dimension)
        }

        return resize(to: newSize, with: resizeFramework)
    }

    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Parameter resizeFramework: Technique for image resizing: UIKit / CoreImage / CoreGraphics / ImageIO / Accelerate.
    /// - Returns: Resized image.
    public func resize(to newSize: CGSize, with resizeFramework: ResizeFramework = .coreImage) -> UIImage? {
        switch resizeFramework {
            case .uikit: return resizeWithUIKit(to: newSize)
            case .coreGraphics: return resizeWithCoreGraphics(to: newSize)
            case .coreImage: return resizeWithCoreImage(to: newSize)
            case .imageIO: return resizeWithImageIO(to: newSize)
            
        }
    }

    // MARK: - UIKit

    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    private func resizeWithUIKit(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
  
    // MARK: - CoreImage

    /// Resize CI image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    private func resizeWithCoreImage(to newSize: CGSize) -> UIImage? {
        guard let cgImage = cgImage, let filter = CIFilter(name: "CILanczosScaleTransform") else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let scale = (Double)(newSize.width) / (Double)(ciImage.extent.size.width)

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value:scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let resultCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: resultCGImage)
    }

    // MARK: - CoreGraphics

    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    private func resizeWithCoreGraphics(to newSize: CGSize) -> UIImage? {
        guard let cgImage = cgImage, let colorSpace = cgImage.colorSpace else { return nil }

        let width = Int(newSize.width)
        let height = Int(newSize.height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = cgImage.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        context.draw(cgImage, in: rect)

        return context.makeImage().flatMap { UIImage(cgImage: $0) }
    }

    // MARK: - ImageIO

    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    private func resizeWithImageIO(to newSize: CGSize) -> UIImage? {
        var resultImage = self

        guard let data = jpegData(compressionQuality: 1.0) else { return resultImage }
        let imageCFData = NSData(data: data) as CFData
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(newSize.width, newSize.height)
            ] as CFDictionary
        guard   let source = CGImageSourceCreateWithData(imageCFData, nil),
                let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return resultImage }
        resultImage = UIImage(cgImage: imageReference)

        return resultImage
    }

    // MARK: - Accelerate

    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.

}
