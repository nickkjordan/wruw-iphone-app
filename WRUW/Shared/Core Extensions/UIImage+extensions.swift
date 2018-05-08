import Foundation

extension UIImage {
    /// Checks if image has alpha component
    var hasAlpha: Bool {
        switch cgImage?.alphaInfo {
        case .none?, .noneSkipFirst?, .noneSkipLast?, .none:
            return false
        default:
            return true
        }
    }

    /// Convert to data
    var data: Data? {
        return hasAlpha
            ? UIImagePNGRepresentation(self)
            : UIImageJPEGRepresentation(self, 1.0)
    }
}
