
import Foundation

class MediaItem {
    
    // MARK: Types
    
    /// The type of resource.
    ///
    /// - songs: This indicates that the `MediaItem` is a song from the Apple Music Catalog.
    /// - albums: This indicates that the `MediaItem` is an album from the Apple Music Catalog.
    enum MediaType: String {
        case songs, albums, stations, playlists
    }
    
    /// The various keys needed for serializing an instance of `MediaItem` using a JSON response from the Apple Music Web Service.
    struct JSONKeys {
        static let identifier = "id"
        static let type = "type"
        static let attributes = "attributes"
        static let name = "name"
        static let artistName = "artistName"
        static let artwork = "artwork"
    }
    
    // MARK: Properties
    // Firebase identifier
    var firebaseKey: String!
    
    /// The persistent identifier of the resource which is used to add the item to the playlist or trigger playback.
    var identifier: String
    
    /// The localized name of the album or song.
    var name: String
    
    /// The artist’s name.
    var artistName: String
    
    /// The album artwork associated with the song or album.
    var artwork: Artwork
    
    /// The type of the `MediaItem` which in this application can be either `songs` or `albums`.
    var type: MediaType
    
    // MARK: Initialization
    
    init(json: [String: Any]) throws {
        guard let identifier = json[JSONKeys.identifier] as? String else {
            throw SerializationError.missing(JSONKeys.identifier)
        }
        
        guard let typeString = json[JSONKeys.type] as? String, let type = MediaType(rawValue: typeString) else {
            throw SerializationError.missing(JSONKeys.type)
        }
        
        guard let attributes = json[JSONKeys.attributes] as? [String: Any] else {
            throw SerializationError.missing(JSONKeys.attributes)
        }
        
        guard let name = attributes[JSONKeys.name] as? String else {
            throw SerializationError.missing(JSONKeys.name)
        }
        
        let artistName = attributes[JSONKeys.artistName] as? String ?? " "
        
        guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
            throw SerializationError.missing(JSONKeys.artwork)
        }
        
        self.identifier = identifier
        self.type = type
        self.name = name
        self.artistName = artistName
        self.artwork = artwork
        self.firebaseKey = nil
    }
    
    init(data: [String: Any]) {
        self.firebaseKey = data["firebaseKey"] as! String
        self.identifier = data["identifier"] as! String
        self.type = MediaType(rawValue: data["type"] as! String)!
        self.name = data["name"] as! String
        self.artistName = data["artistName"] as! String
        self.artwork = Artwork(data: data["artwork"] as! [String: Any])
    }
    
    func getData() -> [String: Any] {
        var data: [String: Any] = [:]
        data["firebaseKey"] = self.firebaseKey
        data["identifier"] = self.identifier
        data["type"] = self.type.rawValue
        data["name"] = self.name
        data["artistName"] = self.artistName
        data["artwork"] = self.artwork.getData()
        
        return data
    }
}
