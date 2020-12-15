//
//  Model.swift
//  Unsplash
//
//  Created by EQ1's Mac on 2020/11/10.
//

import Foundation

struct Photo: Identifiable, Decodable, Hashable {
    var id: String
    var urls: [String : String]
}

struct SearchPhoto: Decodable, Hashable {
    var results : [Photo]
}

class UnsplashData: ObservableObject {
    @Published var Images : [[Photo]] = []
    @Published var noresults = false
    @Published var isLast: Bool = false
    @Published var isUpdating: Bool = false
    
    var page = 0
    var url = ""
    
    let key = "TnT1ZzW9h42-yihbnVRys0xKOOsWvPe3exgLkDYrdos"
    let count = 30
    
    init() {
        GetData()
    }
    
    func GetData(query: String = "") {

        self.noresults = false
        
        if query == "" {
            page = 0
            url = "https://api.unsplash.com/photos/random/?count=\(count)&client_id=\(key)"
        } else {
            page += 1
            let query = query.replacingOccurrences(of: " ", with: "%20")
            url = "https://api.unsplash.com/search/photos/?query=\(query)&page=\(page)&per_page=\(count)&client_id=\(key)"
        }

        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            guard let data = data else {
                print("URLSession data error: ", err ?? "nil")
                return
            }
            
            //JSON Decoding
            do{
                let json: [Photo]
                if query == "" {
                    json = try JSONDecoder().decode([Photo].self, from: data)
                } else {
                    let temp = try JSONDecoder().decode(SearchPhoto.self, from: data)
                    json = temp.results
                }
                
                if json.count == 0 {
                    self.noresults = true
                }
                
                //going to create collection view each row has two views
                for i in stride(from: 0, to: json.count, by: 2){
                    
                    var ArrayData: [Photo] = []
                    
                    for j in i..<i + 2 {
                        // Index out bound...
                        if j < json.count {
                            ArrayData.append(json[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.Images.append(ArrayData)

                    }
                    print("Photos loaded: \(i)")
                }
                
            }
            catch{

                print("JSON Decoding Error: \(error)")
            }
        }.resume()
    }
    
    func loadNewData(query: String = "") {
        if self.isLast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.GetData(query: query)
                self.isUpdating = false
                self.isLast = false
            })
        }
        
    }
}
