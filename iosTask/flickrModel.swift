//
//  flickrModel.swift
//  iosTask
//
//  Created by Maged on 18/05/2022.
//

import Foundation
import Alamofire
struct FlickrModel: Codable {
    var photos: Photos?
    var stat: String?
}

// MARK: - Photos
struct Photos: Codable {
    var page, pages, perpage, total: Int?
    var photo: [Photo]?
}

// MARK: - Photo
struct Photo: Codable {
    var id, owner, secret, server: String?
    var farm: Int?
    var title: String?
    var ispublic, isfriend, isfamily: Int?
    var isHasAd:Bool?
}
struct APIRequest {
    var urlSuffix: APIPath
    var method: HTTPMethod = .get
    var body: Parameters = [:]
    var parameters: Parameters = [:]
}
struct ApiResponse<T: Decodable> {
    var entity: T
    let data: Data?

    init(data: Data?) throws {
        do {
            entity = try JSONDecoder().decode(T.self, from: data ?? Data())
            self.data = data
        } catch {
            throw ApiParseError(data: data, error: error as NSError)
        }
    }
}
class ApiParseError: NSError {
    static let code = 999

    var error: NSError?
    var httpUrlResponse: HTTPURLResponse?
    var data: Data?

    override var localizedDescription: String {
        return error?.localizedDescription ?? ""
    }

    init(data: Data?, httpUrlResponse: HTTPURLResponse, error: NSError?) {
        super.init(domain: "UnExpected Error", code: 1, userInfo: nil)
        self.httpUrlResponse = httpUrlResponse
        self.data = data
        self.error = error
    }

    init(data: Data?, error: NSError?) {
        super.init(domain: "UnExpected Error", code: 1, userInfo: nil)
        self.data = data
        self.error = error
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
enum APIPath: String {
    case registerToken = "auth/register_token"

}
class ImageCache {

    private init() {}

    static let shared = NSCache<NSString, UIImage>()
}
