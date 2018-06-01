import Foundation

public struct ImageWrapper: Codable {
    public var image: UIImage

    public enum CodingKeys: String, CodingKey {
        case image
    }

    // Image is a standard UI/NSImage conditional typealias
    public init(image: UIImage) {
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var data = try? container.decode(Data.self, forKey: CodingKeys.image)

        if data == nil {
            let string =
                try container.decode(String.self, forKey: CodingKeys.image)

            data = Data(base64Encoded: string)
        }

        guard let imageData = data,
            let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.image,
                in: container,
                debugDescription: "UIImage can't be initialized from data"
            )
        }

        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        guard let data = image.data else {
            throw EncodingError.invalidValue(
                image,
                .init(
                    codingPath: [CodingKeys.image],
                    debugDescription: "Image not converted to Data"
                )
            )
        }

        try container.encode(data, forKey: CodingKeys.image)
    }
}
