import Foundation

func stubbedResponse(filename: String) -> NSData! {
    @objc class TestClass: NSObject { }

    let bundle = NSBundle(forClass: TestClass.self)
    let path = bundle.pathForResource(filename, ofType: "json")
    
    return NSData(contentsOfURL: NSURL(fileURLWithPath: path!))
}
