//
//  ContentView.swift
//  Netflix
//
//  Created by Tate Wrigley on 03/06/2022.
//

import SwiftUI

struct MovieResult : Identifiable, Hashable {
    
    let id = UUID()
    var original_title: String
    var image : String
    var sectionTitle: String
    
}
struct ContentView : View {
    
    var body: some View {
        
        HomePage()
        
    }
    
}
struct HomePage : View {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @State var layoutIfNeeded = false
    @State var popular = [MovieResult]()
    @State var genres = [Genres]()
    @State var restOfMovies = [[MovieResult]]()
    
    var body: some View {
        
        ZStack {
            Rectangle()
            if layoutIfNeeded {
                ScrollView {
                    ZStack {
                        AsyncImage(url: URL(string: popular[popular.count - 1].image), content: { image in
                            
                            image.resizable().aspectRatio(contentMode: .fill)
                            
                        }, placeholder: {
                            ProgressView()
                        }).frame(width: screenWidth, height: 300, alignment: .center).clipped()
                        
                        VStack {
                            LinearGradient(colors: [
                            
                                Color.black,
                                Color.black,
                                Color.clear,
                            ], startPoint: .top, endPoint: .bottom)
                            Spacer()
                            LinearGradient(colors: [
                            
                                Color.clear,
                                
                                Color.black,
                             
                            ], startPoint: .top, endPoint: .bottom)
                        }
                        VStack {
                            HStack {
                                Image(uiImage: UIImage(named: "NetflixSmall")!).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20, alignment: .center)
                                Spacer()
                                
                            }.padding(20).offset(x: 0, y: 40)
                            HStack {
                                Spacer()
                                Text("Series").foregroundColor(.white).font(.system(size: 12))
                                Spacer()
                                Text("Films").foregroundColor(.white).font(.system(size: 12))
                                Spacer()
                                Text("Categories").foregroundColor(.white).font(.system(size: 12))
                                Spacer()
                            }.offset(x: 0, y: 50)
                            Spacer()
                            HStack {
                                Text("My List").foregroundColor(.white).font(.system(size: 12))
                                Spacer()
                                ZStack {
                                    Rectangle().foregroundColor(.white).frame(width: 60, height: 25, alignment: .center)
                                    HStack {
                                        Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(.black)
                                        Text("Play")
                                    }
                                }
                                Spacer()
                                Text("Info").foregroundColor(.white).font(.system(size: 12))
                            }.offset(x: 0, y: -20).padding(10)
                        }
                    }
                    VStack {
                        Spacer().frame(width: nil, height: 20, alignment: .center)
                        HStack {
                            Text("Popular").foregroundColor(.white).font(.system(size: 15)).bold()
                            Spacer()
                            
                        }
                        ScrollView(.horizontal, showsIndicators: false, content: {
                            
                            LazyHGrid(rows: [GridItem(.fixed(100))], alignment: .center, spacing: 10, content: {
                                HStack {
                                    ForEach(popular, content: { result in
                                        
                                        AsyncImage(url: URL(string: result.image), content: { image in
                                            
                                            image.resizable().aspectRatio(contentMode: .fill)
                                            
                                        }, placeholder: {
                                            ProgressView()
                                        }).frame(width: 100, height: 100, alignment: .center).clipped()
                                        
                                    })
                                }
                            })
                        })
                    }
                    ForEach(0..<restOfMovies.count - 1, content: { moveSection in
                        
                        HStack {
                            Text(restOfMovies[moveSection][moveSection].sectionTitle)
                            .foregroundColor(.white).font(.system(size: 15)).bold()
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false, content: {
                            LazyHGrid(rows: [GridItem(.fixed(100))], alignment: .center, spacing: 10, content: {
                                
                                HStack {
                                    ForEach(restOfMovies[moveSection], content: { movieRow in
                                        
                                        AsyncImage(url: URL(string: movieRow.image), content: { image in
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        }, placeholder: {
                                            ProgressView()
                                        }).frame(width: 100, height: 100, alignment: .center).clipped()
                                        
                                    })
                                }
                                
                                
                            })
                        })
                        
                        
                    })
                }
            }
        }.ignoresSafeArea().onAppear(perform: {
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            APICaller.shared.popular(completion: { result in
                
                switch result {
                case .success(let response):
                    
                    for index in 0...response.results.count - 1 {
                        popular.append(MovieResult(original_title: response.results[index].original_title, image: "https://image.tmdb.org/t/p/w500\(response.results[index].poster_path)", sectionTitle: "Popular"))
                    }
                    dispatchGroup.leave()
                case .failure(let error):
                    break
                }
                
                
            })
            
            dispatchGroup.enter()
            
            APICaller.shared.genre(completion: { result in
                dispatchGroup.leave()
                switch result {
                case .success(let response):
                    genres = response.genres
                case .failure(let error):
                    break
                }
                
            })
           
            dispatchGroup.notify(queue: .main, execute: {
        
                let group2 = DispatchGroup()
                for index in 0...self.genres.count - 1 {
                    if self.genres[index].name != "Horror" {
                        group2.enter()
                        
                        var genreString = String()
                        for _index in 0...self.genres.count - 1 {
                            if self.genres[_index].id != self.genres[index].id {
                                genreString.append("\(self.genres[_index].id),")
                            }
                        }
                        APICaller.shared.discover(genres: "\(self.genres[index].id)", withoutGenre: genreString, completion: { result in
                            
                            group2.leave()
                            switch result {
                            case .success(let response):
                                
                                var movie = [MovieResult]()
                                for __index in 0...response.results.count - 1 {
                                    movie.append(MovieResult(original_title: response.results[__index].original_title, image: "https://image.tmdb.org/t/p/w500\(response.results[__index].poster_path)", sectionTitle: "\(self.genres[index].name)"))
                                }
                                
                                restOfMovies.append(movie)
                            case .failure(let error):
                                break
                            }
                            
                        })
                    }
                    
                   
                }
                group2.notify(queue: .main, execute: {
                    print(restOfMovies)
                    withAnimation(.default.delay(0.5), {
                        layoutIfNeeded = true
                        print(restOfMovies.count)
                    })
                })
                
            })
            
        })
        
    }
}

struct OnBoard : View {
    @State var animation1 = false
    @State var animation2 = false
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(.black)
            Image(uiImage: UIImage(named: "Netflix")!).resizable().aspectRatio(contentMode: .fit).frame(width: 200, height: 70, alignment: .center).offset(x: animation1 ? 0 : UIScreen.main.bounds.width, y: 0)
        }.ignoresSafeArea().opacity(animation2 ? 0 : 1).onAppear(perform: {
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                animation1 = true
                
            }
            withAnimation(.default.delay(3.0), {
                animation2 = true
            })
            
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



//MARK: - Download source code for these

class APICaller {
    
    static let shared = APICaller()
    public func search(search: String, completion: @escaping ((Result<SearchReponse , Error>)) -> Void) {
        
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=fcb0d34c7b008a12050398875e0af6fb&language=en-US&query=\(search)&page=1&include_adult=false"




    guard let url = URL(string: urlString) else {
    return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in


    guard let _data = data , error == nil else {
    return
    }
    do {
    let jsonResult = try JSONDecoder().decode(SearchReponse.self, from: _data)
    DispatchQueue.main.async {


    completion(.success(jsonResult))
    }

    }catch {
    completion(.failure(error))

    }
    }
    task.resume()
    }
    public func popular(completion: @escaping ((Result<PopularReponse , Error>)) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=fcb0d34c7b008a12050398875e0af6fb&language=en-US&page=1"




    guard let url = URL(string: urlString) else {
    return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in


    guard let _data = data , error == nil else {
    return
    }
    do {
    let jsonResult = try JSONDecoder().decode(PopularReponse.self, from: _data)
    DispatchQueue.main.async {


    completion(.success(jsonResult))
    }

    }catch {
    completion(.failure(error))

    }
    }
    task.resume()
    }
    public func discover(genres: String, withoutGenre:String,completion: @escaping ((Result<DiscoverResponse , Error>)) -> Void) {
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=fcb0d34c7b008a12050398875e0af6fb&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=\(genres)&without_genres=\(withoutGenre)&with_watch_monetization_types=flatrate"




    guard let url = URL(string: urlString) else {
    return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in


    guard let _data = data , error == nil else {
    return
    }
    do {
    let jsonResult = try JSONDecoder().decode(DiscoverResponse.self, from: _data)
    DispatchQueue.main.async {


    completion(.success(jsonResult))
    }

    }catch {
    completion(.failure(error))

    }
    }
    task.resume()
    }
    public func genre(completion: @escaping ((Result<GenreResponse , Error>)) -> Void) {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=fcb0d34c7b008a12050398875e0af6fb&language=en-US"




    guard let url = URL(string: urlString) else {
    return
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in


    guard let _data = data , error == nil else {
    return
    }
    do {
    let jsonResult = try JSONDecoder().decode(GenreResponse.self, from: _data)
    DispatchQueue.main.async {


    completion(.success(jsonResult))
    }

    }catch {
    completion(.failure(error))

    }
    }
    task.resume()
    }
    
}

struct SearchReponse: Codable {
    
    let results : [SearchResult]
    
}

struct SearchResult : Codable {
    let adult : Bool
    let backdrop_path : String?
    let genre_ids: [Int]
    let id: Int
    let original_language : String
    let original_title: String
    let overview : String
    let popularity : Double
    let poster_path: String
    let release_date: String
    let title: String
    let video: Bool
    let vote_average : Double
    let vote_count: Int
}

struct PopularReponse: Codable {
    
    let results : [PopularResult]
    
}

struct PopularResult : Codable  {

    let adult : Bool
    let backdrop_path : String
    let genre_ids: [Int]
    let id: Int
    let original_language : String
    let original_title: String
    let overview : String
    let popularity : Double
    let poster_path: String
    let release_date: String
    let title: String
    let video: Bool
    let vote_average : Double
    let vote_count: Int
}

struct DiscoverResponse : Codable {
    
    let results : [DiscoverResults]
    
}

struct DiscoverResults : Codable {
    let adult : Bool
    let backdrop_path : String
    let genre_ids: [Int]
    let id: Int
    let original_language : String
    let original_title: String
    let overview : String
    let popularity : Double
    let poster_path: String
    let release_date: String
    let title: String
    let video: Bool
    let vote_average : Double
    let vote_count: Int
}

struct GenreResponse: Codable {
    
    let genres : [Genres]
    
}

struct Genres : Codable {
    let id: Int
    let name: String
}
