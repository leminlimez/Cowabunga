//
//  GesturesView.swift
//  TrollTools
//
//  Created by exerhythm on 09.11.2022.
//

import SwiftUI

struct CalculatorErrorView: View {
    @State var errorMessage: String = "Error"
    @State var leet: String = ""
    
    let defaultSize: CGFloat = 80
    let spacing: CGFloat = 10
    
    struct CalculatorButtonStyle: ButtonStyle {
        var sizex: CGFloat
        var sizey: CGFloat
        var backgroundColor: Color
        var foregroundColor: Color
        @State private var held: Bool = false
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 36, weight: .medium))
                .frame(width: sizex, height: sizey)
                .background(backgroundColor)
                .opacity(held ? 0.5 : 1)
                .foregroundColor(foregroundColor)
                .clipShape(Capsule())
                .gesture(DragGesture(minimumDistance: 0.0)
                    .onChanged { _ in
                        withAnimation(Animation.linear(duration: 0.1)) {
                            held = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(Animation.linear(duration: 0.3)) {
                            held = false
                        }
                    })
        }
    }
    
    struct CalculatorNumber: Identifiable {
        var id = UUID()
        var number: String
        var isImage: Bool = false
        var sizeX: CGFloat = 80
        var sizeY: CGFloat = 80
        var bgColor: Color = Color(white: 0.225)
        var txtColor: Color = .white
        var action: () -> Void = CalculatorErrorManager.nothing
    }
    
    @State var CalculatorButtons: [CalculatorNumber] = [
        .init(number: "AC", bgColor: Color(UIColor.lightGray), txtColor: .black),
        .init(number: "plus.slash.minus", isImage: true, bgColor: Color(UIColor.lightGray), txtColor: .black),
        .init(number: "%", bgColor: Color(UIColor.lightGray), txtColor: .black),
        .init(number: "divide", isImage: true, bgColor: .orange),
        
        .init(number: "7", action: { CalculatorErrorManager.something(number: "7") }),
        .init(number: "8"),
        .init(number: "9"),
        .init(number: "multiply", isImage: true, bgColor: .orange),
        
        .init(number: "4"),
        .init(number: "5"),
        .init(number: "6"),
        .init(number: "minus", isImage: true, bgColor: .orange),
        
        .init(number: "1", action: { CalculatorErrorManager.something(number: "1") }),
        .init(number: "2"),
        .init(number: "3", action: { CalculatorErrorManager.something(number: "3") }),
        .init(number: "plus", isImage: true, bgColor: .orange),
        
        .init(number: "0", sizeX: 170),
        .init(number: "."),
        .init(number: "equal", isImage: true, bgColor: .orange)
    ]
    
    var body: some View {
        let gridItems = [GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading),
                                 GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading),
                                 GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading),
                                 GridItem(.fixed(defaultSize), spacing: spacing, alignment: .leading)]
        
        ZStack {
            Color.black
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
            VStack {
                Spacer()
                TextField("Error", text: $errorMessage)
                //                        .placeholder("Placeholder", errorMessage: text.isEmpty)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 24)
                    .font(.system(size: 64))
                    .minimumScaleFactor(0.5)
                    .frame(height: 80)
                    .textFieldStyle(PlainTextFieldStyle())
                LazyVGrid(columns: gridItems, spacing: spacing) {
                    ForEach(CalculatorButtons) { button in
                        CalcColumn(span: button.sizeX > 80) {
                            ZStack {
                                Capsule()
                                    .foregroundColor(.white)
                                    .frame(width: button.sizeX-1, height: button.sizeY-1)
                                
                                Button(action: button.action) {
                                    if button.isImage {
                                        Image(systemName: button.number)
                                    } else {
                                        if button.number == "0" {
                                            Text(button.number)
                                                .padding(.trailing, 85)
                                        } else {
                                            Text(button.number)
                                        }
                                    }
                                }
                                .buttonStyle(CalculatorButtonStyle(
                                    sizex: button.sizeX,
                                    sizey: button.sizeY,
                                    backgroundColor: button.bgColor,
                                    foregroundColor: button.txtColor)
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, 25)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    do {
                        try CalculatorErrorManager.applyErrorMessage(errorMessage)
                        UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("Restart the Calculator app (if it is running) to apply changes.", comment: "Succeeded in changing calculator error message"))
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .onAppear {
            errorMessage = UserDefaults.standard.string(forKey: "CalculatorErrorMessage") ?? "Error"
        }
    }
    
    struct CalcColumn<Content: View>: View {
        let span: Bool
        let content: () -> Content
        
        init(span: Bool, @ViewBuilder content: @escaping () -> Content) {
            self.span = span
            self.content = content
        }
        
        var body: some View {
            content()
            
            if span == true {
                Color.clear
            }
        }
    }
}

struct CalculatorErrorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorErrorView()
    }
}
