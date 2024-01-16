import Foundation

enum Decoders {
    static let iso801: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static let standardJSON: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Decoders.decodeDate)
        return decoder
    }()

    static func decodeDate(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)

        if let value = Formatters.isoDate.date(from: raw) {
            return value
        }

        if let value = Formatters.apiRendered.date(from: raw) {
            return value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Couldn't decode Date from \(raw).")
        }
    }
}
