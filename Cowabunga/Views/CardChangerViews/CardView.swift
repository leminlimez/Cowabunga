//
//  CardView.swift
//  Cowabunga
//
//  Created by lemin on 1/30/23.
//

import SwiftUI
import PDFKit

struct Card {
    var image: String
    var id: String
    var format: String
}

struct CardView: View {
    let fm = FileManager.default
    
    @State private var cardImage = UIImage()
    @State private var showSheet = false
    @State private var hasDefaultImage = false
    
    private func resetImage(format: String)
    {
        let fm = FileManager.default
        
        do {
            try fm.removeItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id.replacingOccurrences(of: "pkpass", with: "cache") )
        } catch {
            print(error.localizedDescription)
        }
        
        switch format
        {
        case "@2x.png":
            
            do {
                try fm.removeItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png")
                try fm.moveItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png.backup", toPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png")
            } catch {
                print(error.localizedDescription)
            }
            
            hasDefaultImage = true
            respring()
        case ".pdf":
            do {
                try fm.removeItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined.pdf")
                try fm.moveItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined.pdf.backup", toPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined.pdf")
            } catch {
                print(error.localizedDescription)
            }
            
            hasDefaultImage = true
            respring()
        default:
            UIApplication.shared.alert(body: "Unknown file!")
        }
    }
    
    private func setImage(image: UIImage, format: String)
    {
        switch format
        {
        case "@2x.png":
            if let data = image.pngData()
            {
                do {
                    let fm = FileManager.default
                    
                    try fm.moveItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png", toPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png.backup")
                    
                    try data.write(to: URL(fileURLWithPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png"))
                    
                    try fm.removeItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id.replacingOccurrences(of: "pkpass", with: "cache") )
                    
                    respring()
                    
                    
                } catch {
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            }
            
        case ".pdf":
            
            let pdfDocument = PDFDocument()
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: 0)
            let data = pdfDocument.dataRepresentation()
            let url = URL(fileURLWithPath: "")
            
            do {
                let fm = FileManager.default
                
                try fm.moveItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined.pdf", toPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined.pdf.backup")
                
                try data!.write(to: url)
                
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }

        default:
            UIApplication.shared.alert(body: "Unknown format!")
        }
    }
    
    var card: Card
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(contentsOfFile: card.image)!).resizable().aspectRatio(contentMode: .fit).frame(width: 320).zIndex(0).cornerRadius(5).onTapGesture {
                showSheet = true
            }
            .sheet(isPresented: $showSheet) {
                ImagePickerB(sourceType: .photoLibrary, selectedImage: self.$cardImage)
            }
            .onChange(of: self.cardImage) {
                newImage in setImage(image: newImage, format: card.format)
            }
            
            if fm.fileExists(atPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined" + card.format + ".backup") {
                Button {
                    resetImage(format: card.format)
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill").resizable().scaledToFit().frame(width: 40).foregroundColor(Color.red)
                }
                .zIndex(1)
                .padding(.top, 265)
            }
        }
    }
}
