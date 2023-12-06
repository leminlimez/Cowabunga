//
//  MainCardView.swift
//  TrollBox
//
//  Created by c22dev on 22/12/2022.
//
import SwiftUI
import ACarousel

struct MainCardView: View {
    
    @State private var showNoCardsError = false
    
    func getPasses() -> [String]
    {
        let fm = FileManager.default
        let path = "/var/mobile/Library/Passes/Cards/"
        var data = [String]()
        
        do {
            let passes = try fm.contentsOfDirectory(atPath: path).filter {
                $0.hasSuffix("pkpass");
            }
            
            for pass in passes {
                let files = try fm.contentsOfDirectory(atPath: path + pass)
                
                if (files.contains("cardBackgroundCombined.pdf") || files.contains("cardBackgroundCombined@2x.png"))
                {
                    data.append(pass)
                }
            }
            print(data)
            return data
            
        } catch {
            return []
        }
    }
    
    /*func getName(id: String) -> String {
        let jsonPath = "/var/mobile/Library/Passes/Cards/" + id + "/pass.json"
        
        do {
            let contents = try String(contentsOfFile: jsonPath)
            let data: Data? = contents.data(using: .utf8)
            
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                
                if let name = try json["organizationName"] as? String {
                    return name
                }
            }
            
        } catch {
            return (error.localizedDescription)
        }
    
        return "error"
    }*/
    
    func getImage(id: String) -> (String, String)
    {
        let fm = FileManager.default
        let path = "/var/mobile/Library/Passes/Cards/" + id + "/cardBackgroundCombined"
        
        if (fm.fileExists(atPath: path + "@2x.png"))
        {
            return (path, "@2x.png")
        } else if (fm.fileExists(atPath: path + ".pdf"))
        {
            return (path, ".pdf")
        } else
        {
            UIApplication.shared.alert(body: "No cards were found!")
            return ("","")
        }
    }
        
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Tap a card to customize")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("Swipe to view different cards")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            VStack  {
                if (!getPasses().isEmpty) {
                    ACarousel(getPasses(), id: \.self) { i in
                        let imageData = getImage(id: i)
                        
                        if (!imageData.0.isEmpty) {
                            CardView(card: Card(image: imageData.0, id: i, format: imageData.1))
                        }

                    }
                } else {
                    Text("No Cards Found")
                        .foregroundColor(.red)
                        .padding(64)
                }
            }
        }
        .navigationTitle("Card Changer")
    }
}

struct MainCardView_Previews: PreviewProvider {
    static var previews: some View {
        MainCardView()
    }
}
