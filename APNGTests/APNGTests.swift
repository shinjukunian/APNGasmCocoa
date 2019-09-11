//
//  APNGTests.swift
//  APNGTests
//
//  Created by Morten Bertz on 2017/09/13.
//  Copyright © 2017 telethon k.k. All rights reserved.
//

import XCTest
import APNG

class APNGTests: XCTestCase {
    
    let outURL=URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("APNG").appendingPathExtension("png")
    let timeInterval:TimeInterval=0.1
    let loopCount=5
    
    #if SWIFT_PACKAGE
    lazy var imageURLS:[URL]={
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent()
        let imageURL=currentURL.appendingPathComponent("testData", isDirectory: true)
        let imageURLs=try! FileManager.default.contentsOfDirectory(at: imageURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .sorted(by: {u1,u2 in
                return u1.lastPathComponent.compare(u2.lastPathComponent, options:[.numeric]) == .orderedAscending
                
            })
        
        XCTAssertGreaterThan(imageURLs.count, 1, "insufficient images loaded")

        return imageURLs
    }()
    
    #else
    lazy var imageURLS:[URL]={
        guard let urls=Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: "testData")?.sorted(by: {u1,u2 in
            return u1.lastPathComponent.compare(u2.lastPathComponent, options:[.numeric]) == .orderedAscending
        }) else{
            XCTFail("No Images Loaded")
            return [URL]()
        }
        XCTAssertGreaterThan(urls.count, 1, "insufficient images loaded")
        return urls
    }()
    #endif
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        do{
            try FileManager.default.removeItem(at: self.outURL)
        }
        catch let error{
            print(error)
        }
        
        super.tearDown()
    }
    
    func testEncoding(){
        self.encodeAPNG(completion: {url in
            XCTAssertNotNil(url, "encoding failed")
            if let number=self.testDecoding(url: url!){
                XCTAssertGreaterThan(number, 0)
            }
            else{
                XCTFail("images not properly encoded")
            }
        })
    }
    
    func testDecoding(url:URL)->Int?{
        guard let source=CGImageSourceCreateWithURL(url as CFURL,nil) else{
            XCTFail("Image Source Creation failed")
            return nil}
        
        guard let props=CGImageSourceCopyProperties(source, nil) as? [String:Any],
            let pngProps=props[kCGImagePropertyPNGDictionary as String] as? [String:Any],
            let loopCount=pngProps[kCGImagePropertyAPNGLoopCount as String] as? Int else{
                XCTFail("PNG Properties Could not be read")
                return nil
        }
        
        XCTAssertEqual(loopCount, self.loopCount, "Encoded Loop Count Time")
        
        let count=CGImageSourceGetCount(source)
        let success=[0..<count].indices.reduce(true, {result, idx in
            let image=CGImageSourceCreateImageAtIndex(source, idx, nil)
            
            if let properties=CGImageSourceCopyPropertiesAtIndex(source, idx, nil) as? [String:Any],
                let pngProperties=properties[kCGImagePropertyPNGDictionary as String] as? [String:Any],
                let delay=pngProperties[kCGImagePropertyAPNGDelayTime as String] as? Double{
                    XCTAssertEqual(delay, self.timeInterval, accuracy: (self.timeInterval/100), "Encoded Delay Time Wrong")
                
            }
            else{
                
            }
            
            XCTAssertNotNil(image, "image creation failed at index \(idx)")
            return image != nil && result
        })
        return success == true ? count : nil
    }
    
    
    func encodeAPNG(completion:@escaping (_ url:URL?)->Void) {
        let images=self.imageURLS.compactMap({url->CGImage? in
        guard let source=CGImageSourceCreateWithURL(url as CFURL, nil) else{return nil}
            XCTAssert(CGImageSourceGetCount(source) == 1, "Image Source has image count too high")
            return CGImageSourceCreateImageAtIndex(source, 0, nil)
       })
        XCTAssertEqual(images.count, self.imageURLS.count)
        guard let encoder=APNGEncoder(url: self.outURL, count: UInt(images.count)) else{
            XCTFail("Encoder Creation Failed")
            return}
        encoder.loopCount=UInt(self.loopCount)
        for image in images{
            let success=encoder.add(image, withDelay: self.timeInterval)
            XCTAssert(success, "Image Encoding failed")
        }
        let expectation=XCTestExpectation(description: "Image Encoding")
        encoder.finalize(completion: {outURL, error in
            if let error=error{print(error)}
            XCTAssertNotNil(outURL, "writing APNG failed")
            completion(outURL)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10)
        
        
    }
    
}
