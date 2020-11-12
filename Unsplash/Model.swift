//
//  Model.swift
//  Unsplash
//
//  Created by EQ1's Mac on 2020/11/10.
//

import Foundation

struct Photo: Identifiable, Decodable {
    var id: String
    var alt_description: String?
    var urls: [String : String]
}

class UnsplashData: ObservableObject {
    @Published var photoArray: [Photo] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        let key = "oMpA7TXtuvGaVGH-L9GqtkWDlG0rGjhEeHxWu4TRS-Y"
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        
        let session = URLSession(configuration: .default)

        session.dataTask(with: URL(string: url)!) { (data, _, error) in
            guard let data = data else {
                print("URLSession DataTask error:", error ?? nil)
                return
            }
            do {
                let json = try JSONDecoder().decode([Photo].self, from: data)
                for photo in json {
                    DispatchQueue.main.async {
                        self.photoArray.append(photo)
                    }
                }
            } catch {
                print("catch : ", error.localizedDescription)
            }
        }.resume()
    }
}

