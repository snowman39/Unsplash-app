//
//  ContentView.swift
//  Unsplash
//
//  Created by EQ1's Mac on 2020/11/10.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    
//    @ObservedObject var randomImages = UnsplashData()
    
    var body: some View {
        
        Home()
//        ScrollView {
//            LazyVStack {
//                ForEach(randomImages.photoArray, id: \.id) { photo in
//                    WebImage(url: URL(string: photo.urls["thumb"]!))
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: UIScreen.main.bounds.width - 50, height: 200, alignment: .center)
//                        .cornerRadius(15)
//
//                    if photo.alt_description != nil {
//                        Text(photo.alt_description!).font(.footnote)
//                    }
//                }
//            }.padding(20)
//        }.navigationTitle("Random List")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @ObservedObject var randomImages = UnsplashData()
    @State var expand = false;
    @State var search = "";
    @State var page = 1;
    @State var isSearching = false;
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack{
                
                // hiding this view when search bar is expanded ...
                if !self.expand {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("UnSplash")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Beautiful, Free Photos")
                            .font(.caption)
                    }
                    .foregroundColor(.black)
                }
                
                
                Spacer(minLength: 0)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        
                    withAnimation{
                        
                        self.expand = true
                    
                    }
                }
                // Displaying Textfield when search bar is expanded ...
                
                if self.expand {
                    
                    TextField("Search...", text: self.$search)
                    
                    // Displaying Close Button ...
                    
                    // Displaying search button when search txt is not empty...
                    
                    if self.search != "" {
                        
                        Button(action: {
                            
                            // Search Content...
                            // deleting all existing data and displating search data...
                            
                            self.randomImages.photoArray.removeAll()
                            self.isSearching = true
                            self.page = 1
                            self.SearchData()
                            
                        }) {
                            
                            Text("Find")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Button(action: {
                        
                        withAnimation{
                            
                            self.expand = false
                        }
                        
                        self.search = ""
                        
                        if self.isSearching {
                            
                            self.isSearching = false
                            self.randomImages.photoArray.removeAll()
                            // updating home data...
                            self.randomImages.loadData()

                        }
                    }) {
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 10)
                }
                
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            .background(Color.white)
            
            if self.randomImages.photoArray.isEmpty {

                // Data is Loading...
                // Or no data...
                Spacer()
                
                if self.randomImages.noresults {
                    
                    Text("No Results Found ")
                }
                else {
                    Indicator()
                }

                
                Spacer()
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    // Collection View...
                    
                    VStack(spacing: 15) {
                        
                        ForEach(self.randomImages.photoArray, id: \.self) {i in
                            HStack(spacing : 20) {
                                
                                ForEach(i) { j in
                                    AnimatedImage(url: URL(string: j.urls["thumb"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        // padding on both sides 30 and spacing 20 = 50
                                        .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 200)
                                        .cornerRadius(15)
                                        .contextMenu{
                                            
                                            // Save Button
                                            
                                            Button(action : {
                                                
                                                // saving Image...
                                                
                                                // Image Quality...
                                                SDWebImageDownloader()
                                                    .downloadImage(with: URL(string: j.urls["small"]!)) { (image, _, _, _) in
                                                    
                                                        // For this we need permission...
                                                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                                                    }
                                            }) {
                                                
                                                HStack{
                                                    
                                                    Text("Save")
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "square.and.arrow.down.fill")
                                                }
                                                .foregroundColor(.black)
                                            }
                                        }
                                }
                            }
                        }
                        
                        // Load More Button
                        
                        if !self.randomImages.photoArray.isEmpty {
                            
                            if self.isSearching && self.search != "" {
                                
                                HStack {
                                    
                                    Text("Page \(self.page)")
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        // Updating Data...
                                        self.randomImages.photoArray.removeAll()
                                        self.page += 1
                                        self.SearchData()
                                    }) {
                                        Text("Next")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                            
                            else {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        // Updating Data...
                                        self.randomImages.photoArray.removeAll()
                                        self.randomImages.loadData()
                                    }) {
                                        Text("Next")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
    }
    
    func SearchData() {
        let key = "oMpA7TXtuvGaVGH-L9GqtkWDlG0rGjhEeHxWu4TRS-Y"
        // replacing spaces into %20 for query...
        let query = self.search.replacingOccurrences(of: " ", with: "%20")
        // updating page every time...
        let url = "https://api.unsplash.com/search/photos/?page=\(self.page)&query=\(query)&client_id=\(key)"
        
        self.randomImages.searchData(url: url)
    }
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}
