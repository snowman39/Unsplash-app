//
//  Model.swift
//  Unsplash
//
//  Created by EQ1's Mac on 2020/11/10.
//

import Foundation

struct Photo: Identifiable, Decodable, Hashable {
    var id: String
    var alt_description: String?
    var urls: [String : String]
}

struct SearchPhoto: Decodable, Hashable {
    var results : [Photo]
}

class UnsplashData: ObservableObject {
    @Published var photoArray: [[Photo]] = []
    @Published var noresults = false
    
    init() {
        loadData()
    }
    
    func loadData() {
        
        self.noresults = false
        
        let key = "oMpA7TXtuvGaVGH-L9GqtkWDlG0rGjhEeHxWu4TRS-Y"
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        
        let session = URLSession(configuration: .default)

        session.dataTask(with: URL(string: url)!) { (data, _, error) in
            
            if error != nil {
                
                print((error?.localizedDescription)!)
                return
            }
            
            // JSON decoding...
            
//            guard let data = data else {
//                print("URLSession DataTask error:", error ?? nil)
//                return
//            }
            do {
                let json = try JSONDecoder().decode([Photo].self, from: data!)
                
                // going to create collection view each row has two views...
                
                for i in stride(from: 0, to: json.count, by: 2) {
                    
                    var ArrayData : [Photo] = []
                    
                    for j in i..<i+2 {
                        
                        // Index out bound ...
                        
                        if j < json.count {
                            
                            ArrayData.append(json[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.photoArray.append(ArrayData)
                    }
                }
                
//                for photo in json {
//                    DispatchQueue.main.async {
//                        self.photoArray.append(photo)
//                    }
//                }
            } catch {
                print("catch : ", error.localizedDescription)
            }
        }.resume()
    }
    
    func searchData(url: String) {
         
        let session = URLSession(configuration: .default)

        session.dataTask(with: URL(string: url)!) { (data, _, error) in
            
            if error != nil {
                
                print((error?.localizedDescription)!)
                return
            }
            
            // JSON decoding...
            
            do {
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                
                
                if json.results.isEmpty {
                    self.noresults = true
                }
                else {
                    self.noresults = false
                }
                // going to create collection view each row has two views...
                
                
                for i in stride(from: 0, to: json.results.count, by: 2) {
                    
                    var ArrayData : [Photo] = []
                    
                    for j in i..<i+2 {
                        
                        // Index out bound ...
                        
                        if j < json.results.count {
                            
                            ArrayData.append(json.results[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.photoArray.append(ArrayData)
                    }
                }
                
//                for photo in json {
//                    DispatchQueue.main.async {
//                        self.photoArray.append(photo)
//                    }
//                }
            } catch {
                print("catch : ", error.localizedDescription)
            }
        }.resume()
    }
}

