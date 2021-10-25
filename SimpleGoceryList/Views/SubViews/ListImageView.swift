//
//  ListImageView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 7/14/21.
//

import SwiftUI

struct ListImageView: View {
    
    //MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var item: ListItem
        
    @State private var isShowingAlert = false
    
    //MARK: - Body
    var body: some View {
        
        ZStack{
            
            
            VStack {
                
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(CircleButton(color: .secondary))
                    .padding()
                }
                
                Spacer()
                
                imageView(for: UIImage(data: item.image ?? Data(count: 0)))
                
                Spacer()
                
                HStack {
                    Button {
                        isShowingAlert.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                        
                    }
                    .buttonStyle(SelecttionActionButton(color: .red.opacity(0.8)))
                    .padding()
                    .alert(isPresented: $isShowingAlert, content: alert)
                    
                    Spacer()
                }
                
            }
        }
    }
    
    //MARK: - Alert
    func alert() -> Alert {
        Alert(
            title: Text("Delete image?"),
            primaryButton: .cancel(),
            secondaryButton: .destructive(Text("Ok"),
            action: {
                deleteImage(item)
                presentationMode.wrappedValue.dismiss()
            }))
    }
    
    //MARK: - Image View
    @ViewBuilder
    func imageView(for image: UIImage?) -> some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(width: UIScreen.main.bounds.width - 15, height: 550)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
        } else {
            EmptyView()
        }
    }
    
    //MARK: - Functions
    private func deleteImage(_ item: ListItem) {
        withAnimation {
            item.image = nil
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
