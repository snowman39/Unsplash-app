//
//  ContentView.swift
//  UnsplashPractice
//
//  Created by 최유림 on 2020/11/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @State var expand = false
    @State var search = ""
    @ObservedObject var photoList = PhotoList()
    @State var isSearching = false
    @State var location = 0

    @State private var offset = CGFloat.zero
    @State var pageCount = 1
    
    
    var body: some View {
            VStack(spacing: 0){
                HStack{
                    // Title
                    if !self.expand {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("UnSplash")
                                .font(.title)
                                .fontWeight(.bold)
                                      
                            Text("Assignment for Interface-Programming")
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
                              
                    // Displaying Textfield when search bar is expanded
                    if self.expand {
                        TextField("Search...", text: self.$search)
                                  
                        // Displaying Close Button & Search Button when search txt is not empty
                        if self.search != "" {
                            Button(action: {
                                // Search Content -> deleting all existing data and displaying search data
                                self.photoList.Images.removeAll()
                                self.isSearching = true
                                pageCount = 1
                                self.photoList.GetData(query: self.search)
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
                                self.photoList.Images.removeAll()
                                // updating home data
                                self.photoList.GetData()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.leading,10)
                    }
                              
                }
                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                .padding()
                .background(Color.white)
            
                if self.photoList.Images.isEmpty {
                    Spacer()
                    if self.photoList.noresults {
                        Text("No Results Found")
                    } else {
                        Indicator()
                    }
                    Spacer()
                } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10){
                        ForEach(self.photoList.Images, id: \.self) { i in
                            HStack(spacing: 20){
                                ForEach(i){ j in
                                    WebImage(url: URL(string: j.urls["thumb"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 200)
                                        .cornerRadius(15)
                                }
                            }
                        }
                            
                    }
                    .padding(.top)  // for VStack
                    .background(GeometryReader {
                        Color.clear.preference(key: ViewOffsetKey.self,
                            value: -$0.frame(in: .named("scroll")).origin.y)
                       })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        print("offset >> \($0)")
                        
                        location = Int($0) - (3150 * (pageCount - 1))
                        print("location: \(location)")
                        
                        /*
                        iPhone Xs Max: 2294    >>>> starts at: -132
                        iPhone SE(2nd gen.): 2489    >>>> starts at: -108
                        iPod touch(7th gen.): 2588    >>>> starts at: -106
                        iPhone 8: 2489    >>>> starts at: -108
                        iPhone 8+: 2420    >>>> starts at: -108
                        iPhone 12 Pro Max: 2264    >>>> starts at: -135
                        iPhone 12 mini: 2378    >>>> starts at: -138
                        */
                        
                        if location >= 2400 {
                            self.photoList.isLast = true
                            self.photoList.isUpdating = true
                            self.photoList.loadNewData(query: self.search)
                            pageCount += 1
                        }
                        
                    }
                }
                    
                if self.photoList.isUpdating == true {
                    Spacer()
                    Indicator_small()
                }
            }
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Indicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}

struct Indicator_small: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
