import Foundation

protocol QueryItemRepresentable {
    var queryItem: URLQueryItem { get }
    
    static var queryItemKey: String { get }
}
