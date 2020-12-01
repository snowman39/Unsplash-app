//
//  GetPhotoModel.swift
//  UnsplashPractice
//
//  Created by 최유림 on 2020/11/26.
//

import Foundation

struct Photo: Identifiable, Decodable, Hashable {
    var id: String
    var description: String?
    var alt_description: String?
    var urls: [String: String]
}

struct SearchPhoto: Decodable {
    var results: [Photo]
}

class getData: ObservableObject {
    
    @Published var Images : [[Photo]] = []
    @Published var noresults = false
    @Published var isLast: Bool = false
    @Published var isUpdating: Bool = false
    
    init() {
        updateData()
    }
    
    func updateData() {
        
        self.noresults = false
        
        let key = "TnT1ZzW9h42-yihbnVRys0xKOOsWvPe3exgLkDYrdos"
        let count = 30
        let url = "https://api.unsplash.com/photos/random/?count=\(count)&client_id=\(key)"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            guard let data = data else {
                print("URLSession data error: ", err ?? "nil")
                return
            }
            
            //JSON Decoding
            do{
                let json = try JSONDecoder().decode([Photo].self, from: data)
                
                
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
                print(error)
            }
        }.resume()
    }
    
    func SearchData(url: String) {
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if err != nil {
                print((err)!)
                return
            }
            
            //JSON Decoding
            do{
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                
                print("json.results.count: \(json.results.count)")
                
                if json.results.isEmpty {
                    self.noresults = true
                } else {
                    self.noresults = false
                }

                
                // create collection view, each row has two views
                for i in stride(from: 0, to: json.results.count, by: 2){
                    
                    var ArrayData: [Photo] = []
                    
                    for j in i..<i + 2 {
                        
                        // Index out bound
                        if j < json.results.count {
                            ArrayData.append(json.results[j])
                        }
                    }

                    DispatchQueue.main.async {
                        self.Images.append(ArrayData)
                    }
                }
            }
            catch{
                print(error)
            }
        }
        .resume()
    }
    
    func loadNewData() {
        if self.isLast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.updateData()
                self.isUpdating = false
                self.isLast = false
            }
            
        }
        
    }
}
