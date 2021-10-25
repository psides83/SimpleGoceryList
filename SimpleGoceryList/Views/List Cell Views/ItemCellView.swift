//
//  ItemCellView.swift
//  iOS15 Features
//
//  Created by Payton Sides on 6/8/21.
//

import SwiftUI

struct ItemCellView: View {
    
    //MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var persistenceController: PersistenceController
    
    @ObservedObject var item: Item
    @ObservedObject var haptics = Haptics()
    @ObservedObject var audioPlayer = AudioPlayer()
    @ObservedObject var audioRecorder = AudioRecorder()
    
    @Binding var editMode: EditMode
            
    @State private var sourceType: ImagePicker.SourceType = .camera
    @State private var isPresentingImagePicker = false
    @State private var isShowingPopover = false
    @State private var isShowingAudioRecorder = false
    @State private var isShowingCameraView = false
    @State private var isShowingImageView = false
    @State private var isShowingQtyStepper = false
    @State private var name: String
    @State private var quantity: Int16
    @State private var isUrgentColor: Color = .orange.opacity(0.7)
    @State private var searchText = ""
    @State private var isEditingTitle = false
    @State private var nameIsFocused = false
    @State private var isShowingDeleteAlert = false
    private let impactMed = UIImpactFeedbackGenerator(style: .rigid)
//    @State private var image: Data
    
    init(item: Item, editMode: Binding<EditMode>) {
        self.item = item
        
        _name = State(wrappedValue: item.nameDisplay)
        self._editMode = editMode
        _quantity = State(wrappedValue: item.quantity)
    }
    
    //MARK: - Enum
    enum StepperAction {
        case increasing
        case decreasing
    }
    
    //MARK: - Body
    var body: some View {
        ZStack {
            VStack {
//            if isShowingAudioRecorder {
//                AudioRecorderView(audioRecorder: audioRecorder, item: item, isShowingAudioRecorder: $isShowingAudioRecorder)
//            } else {
                mainCellView
//            }
            }
        }
    }
    
    //MARK: - Main Cell View
    var mainCellView: some View {
        VStack {
            
            HStack {
                
                statusCircle
                urgentView
                textFieldView
                imageButton
                quantityView
                menu
                    .fullScreenCover(isPresented: $isPresentingImagePicker, content: {
                        ImagePicker(sourceType: sourceType, completionHandler: didSelectImage)
                    })
                
//            if editMode == .inactive {
//                if audioRecorder.recordings.filter({$0.fileURL.absoluteString.contains(item.id!.uuidString)}).count != 0 {
//                    if audioPlayer.isPlaying == false {
//                        Button(action: {
//                            audioPlayer.startPlayback(audio: audioURL)
//                        }) {
//                            Image(systemName: "play.circle")
//                                .foregroundColor(.mint)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .animation(.easeInOut, value: audioPlayer.isPlaying)
//                    } else {
//                        Button(action: {
//                            print(audioPlayer.stopPlayback())
//                        }) {
//                            Image(systemName: "stop.circle")
//                                .foregroundColor(.red.opacity(0.6))
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .animation(.easeInOut, value: audioPlayer.isPlaying)
//                    }
//                }
//            }
            }
        }
        .alert(isPresented: $isShowingDeleteAlert, content: deleteAlert)
    }
    
    //MARK: - Quantity View
    @ViewBuilder
    var quantityView: some View {
        if editModeInactive && !nameIsFocused && !item.isPicked {
            
            stepperView
        } else if item.isPicked {
            
            Text("Qty: \(item.quantity)")
                .foregroundColor(.picked)
        }
    }
    
    //MARK: - Stepper View
    var stepperView: some View {
        HStack {
            
            Text("Qty: \(quantity)")
                .foregroundColor(.picked)
                .onTapGesture {
                    withAnimation(Animation.easeInOut) {
                        isShowingQtyStepper.toggle()
                    }
                }
            
            if isShowingQtyStepper {
                Divider()
                    .frame(height: 20)
                HStack {
                    Button {
                        impactMed.impactOccurred()
                        quantity -= 1
                    } label: {
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .font(.subheadline)
                            .foregroundColor(quantity > 1 ? .mint : .picked)
                    }
                    .padding(2)
                    .disabled(quantity < 2)
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        impactMed.impactOccurred()
                        quantity += 1
                    } label: {
                        Image(systemName: "chevron.up")
                            .imageScale(.large)
                            .font(.subheadline)
                            .foregroundColor(quantity < 100 ? .mint : .picked)
                    }
                    .padding(2)
                    .disabled(quantity > 99)
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.opacity)
            }
        }
        .onChange(of: quantity, perform: { value in
            update(quantity)
            print("onChange value = \(value)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(Animation.easeIn) {
                    isShowingQtyStepper = false
                }
            }
        })
    }
    
    //MARK: - Urgent Indicator View
    @ViewBuilder
    var urgentView: some View {
        if item.isUrgent && editModeInactive {
            Image(systemName: "exclamationmark.3")
                .foregroundColor(!item.isPicked ? isUrgentColor : .picked)
                .animation(.spring(), value: item.isUrgent)
        }
    }
    
    //MARK: - Status Circle View
    @ViewBuilder
    var statusCircle: some View {
        if editModeInactive {
            Toggle("", isOn: $item.isPicked)
                .toggleStyle(CheckToggleStyle())
                .onChange(of: item.isPicked, perform: { value in
                    pickToggle()
                })
//            Image(systemName: item.pickedImage)
//                .imageScale(.large)
//                .foregroundColor(.mint)
//                .onTapGesture {
//                    pickToggle()
//                    haptics.simpleSuccess
//                }
        }
    }
    
    //MARK: - Text Field View
    @ViewBuilder
    var textFieldView: some View {
        if item.isPicked {
            
            Text(item.nameDisplay)
                .foregroundColor(.secondary)
                .strikethrough()
            
            Spacer()
        } else {
            
            CustomTextField("", text: $name, isEditing: $nameIsFocused)
                .autocapitalization(.none)
                .returnKeyType(.done)
                .onReturn {
                    if name == "" {
                        delete(item)
                    } else {
                        update(name)
                    }
                }
                .onTapGesture {
                    if nameIsFocused {
                        nameIsFocused = false
                    }
                }
        }
    }
    
    //MARK: - Image Button
    @ViewBuilder
    var imageButton: some View {
        if !item.isPicked && item.image != nil && !isShowingQtyStepper && !nameIsFocused {
            Image(systemName: "photo")
                .foregroundColor(.picked)
                .onTapGesture {
                    nameIsFocused = false
                    isShowingImageView.toggle()
                }
                .sheet(isPresented: $isShowingImageView, content: {
                    ImageView(item: item)
                })
        }
    }
    
    //MARK: - Menu View
    @ViewBuilder
    var menu: some View {
        if showMenuIcon {
            
            Menu {
                
                modifiedDateView
                
                if !item.isPicked {
                    Button {
                        withAnimation {
                            makeUrgent(item)
                        }
                    } label: {
                        Label(item.isUrgent ? "Make unurgent" : "Make urgent", systemImage: "exclamationmark.3")
                            .imageScale(.large)
                    }
                    
                    if item.image == nil || item.image == Data(count: 0) {
                        Button {
                            choosePhoto()
                            nameIsFocused = false
                        } label: {
                            Label("Select Photo", systemImage: "photo.fill")
                                .imageScale(.large)
                        }
                        
                        Button {
                            takePhoto()
                            nameIsFocused = false
                        } label: {
                            Label("Take Photo", systemImage: "camera.fill")
                                .imageScale(.large)
                        }
                    } else {
                        
                        Button {
                            isShowingImageView.toggle()
                            nameIsFocused = false
                        } label: {
                            Label("View Image", systemImage: "photo.fill")
                                .imageScale(.large)
                        }
                        .sheet(isPresented: $isShowingImageView, content: {
                            ImageView(item: item)
                        })
                        
                        Button {
                            isShowingDeleteAlert.toggle()
                        } label: {
                            Label("Delete Image", systemImage: "trash")
                                .imageScale(.large)
                        }
                    }
                }
                
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(!item.isPicked ? .orange.opacity(0.6) : .picked)
                    .imageScale(.large)
            }
            .padding(.leading, 8)
            
        }
    }
    
    //MARK: - Alert
    func deleteAlert() -> Alert {
        Alert(
            title: Text("Delete image?"),
            primaryButton: .cancel(),
            secondaryButton: .destructive(Text("Ok"),
            action: {
                deleteImage()
            }))
    }
    
    //MARK: - Image View
    @ViewBuilder
    func imageView(for image: UIImage?) -> some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 25, height: 25)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(radius: 2)
        } else {
            EmptyView()
        }
    }
    
    //MARK: - Modified Date View
    var modifiedDateView: some View {
        Text("\(modifiedText) \(item.modifiedDateOnly)")
            .font(.caption2)
            .foregroundColor(.picked)
    }
    
    //MARK: - Computed Properties
    var showMenuIcon: Bool {
        if nameIsFocused && editModeInactive {
            return true
        } else if item.isPicked {
            return true
        } else { return false }
    }
    
    var audioURL: URL {
        let recording = audioRecorder.recordings.filter({$0.fileURL.absoluteString.contains(item.id!.uuidString)}).first
        
        return recording!.fileURL
    }
    
    var modifiedText: String {
        switch item.isPicked {
        case true: return "Picked"
        case false: return "Added"
        }
    }
    
    var editModeInactive: Bool {
        switch editMode {
        case .active: return false
        case .inactive: return true
        case .transient: return true
        @unknown default:
            fatalError()
        }
    }
    
    var textFieldIsActive: Bool {
        if nameIsFocused {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Functions
    private func deleteRecording() {
        var urlsToDelete = [URL]()
        audioRecorder.recordings.filter({$0.fileURL.absoluteString.contains(item.id!.uuidString)}).forEach { recording in
            urlsToDelete.append(recording.fileURL)
        }
        audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
    }
    
    private func makeUrgent(_ item: Item) {
        withAnimation {
            
            item.isUrgent.toggle()
            item.lastModified = Date()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func update(_ quantity: Int16) {
        withAnimation {
            
            item.quantity = quantity
            item.lastModified = Date()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    private func deleteImage() {
        item.image = nil
        
        try? viewContext.save()
    }
    
    private func update(_ name: String) {
        withAnimation {
    
            item.name = name
            item.lastModified = Date()
//            do {
                persistenceController.update(item)
//            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
        }
    }
    
    private func pickToggle() {
        withAnimation {
            
            isShowingQtyStepper = false
//            item.isPicked.toggle()
            item.lastModified = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func delete(_ item: Item) {
        withAnimation {
            viewContext.delete(item)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func choosePhoto() {
        
        sourceType = .photoLibrary
        isPresentingImagePicker = true
    }
    
    func takePhoto() {
        
        sourceType = .camera
        isPresentingImagePicker = true
    }
    
    func didSelectImage(_ image: UIImage?) {
                
        item.image = image?.jpegData(compressionQuality: 1.0) ?? nil
        try? viewContext.save()
        
        isPresentingImagePicker = false
    }
}
