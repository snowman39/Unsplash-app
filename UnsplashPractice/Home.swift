//
//  Home.swift
//  UnsplashPractice
//
//  Created by 최유림 on 2020/11/29.
//

import SwiftUI
import SDWebImageSwiftUI

struct Home: View {
    @State var expand = false
    @State var search = ""
    @ObservedObject var RandomImages = PhotoList()
    @State var isSearching = false
    @State var location = 0


    @State var pagecount = 1
    @State var cnt = 1
    @State private var offset = CGFloat.zero
    @State var pageLoaded = 0
    
    
    var body: some View {
        GeometryReader { geometry in
        
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
                                self.RandomImages.Images.removeAll()
                                self.isSearching = true
                                pagecount = 1
                                self.RandomImages.GetData(query: self.search)
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
                                self.RandomImages.Images.removeAll()
                                // updating home data
                                self.RandomImages.GetData()
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
            
                if self.RandomImages.Images.isEmpty {
                    Spacer()
                    if self.RandomImages.noresults {
                        Text("No Results Found")
                    } else {
                        Indicator()
                    }
                    Spacer()
                }
                else {

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10){
                        ForEach(self.RandomImages.Images, id: \.self) { i in
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
                        // print(geometry.size.height): 818
                        location = -132 * pageLoaded + Int($0) - pageLoaded * 2454
                        
                        if location > 2350 {
                            self.RandomImages.isLast = true
                            
                            print("\n" + ">>>>>>>>>>>>>>>>>>>>>>>>at here: \(location)<<<<<<<<<<<<<<<<<<<<<<<<<" + "\n")
                            self.RandomImages.isUpdating = true
                            self.RandomImages.loadNewData(query: self.search)
                            pageLoaded += 1
                            location = -132

                        }
                        
                    }
                }
                    
                if self.RandomImages.isUpdating == true {
                    Spacer()
                    Indicator_small()
                }
                
                // search for more photos
                if self.isSearching && self.search != "" {
                    HStack(){
                        Spacer()
                        Button(action: {
                            //Updating Data
                            pagecount += 1
                            RandomImages.GetData(query: self.search)
                        }) {
                            Text("More...")
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.top, 25)
                }
            }
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
            
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
