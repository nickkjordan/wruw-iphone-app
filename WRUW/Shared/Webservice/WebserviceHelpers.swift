import Foundation

extension NSString {
    var asQuery: NSString {
        let nonLetterSet = NSCharacterSet.punctuationCharacterSet()

        let base = lowercaseString
            .componentsSeparatedByCharactersInSet(nonLetterSet)
            .joinWithSeparator("")

        return base.stringByReplacingOccurrencesOfString(" ", withString: "-")
    }
}
