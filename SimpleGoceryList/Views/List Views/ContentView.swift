//
//  ContentView.swift
//  Shared
//
//  Created by Balaji on 25/06/21.
//

import SwiftUI

struct ContentView: View {
    //MARK: - Properties
    @EnvironmentObject var persistenceController: PersistenceController
    
    @SceneStorage("selectedView") var selectedView: String?
    
    @AppStorage("v2point3") var v2point3: Bool = true
    
    @State private var isShowingAllItemsView = false
    @State private var isShowingUnlockView = false
    @State private var isShowingAddListView = false
    @State private var titleIsFocused = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        
        if persistenceController.fullVersionUnlocked {
            lists
        } else {
            quickList
        }
    }
    
    //MARK: - Quick List
    
    var quickList: some View {
        VStack {
            if !v2point3 {
                SplashScreen(imageSize: CGSize(width: 128, height: 128)) {
                    
                    // Home View....
                    QuickListView(audioRecorder: AudioRecorder(), editMode: $editMode)
                        .sheet(isPresented: $isShowingUnlockView, content: {
                            UnlockView()
                        })
                        .fullScreenCover(isPresented: $isShowingAllItemsView, content: {
                            AllItemsListView()
                        })
                    
                } titleView: {
                    
                    Text("Picked")
                        .font(.system(size: 35).weight(.heavy))
                        .foregroundColor(.white)
                    
                } logoView: {
                    
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } navButtonLeading: {
                    
                    historyButton
                    
                } navButtonTrailing: {
                    
                    EditButton()
                        .environment(\.editMode, $editMode)
                        .accentColor(.white)
                }
                
            } else {
                OnboardingView()
            }
        }
    }
    
    //MARK: - Quick List
    
    var lists: some View {
        VStack {
            if !v2point3 {
                SplashScreen(imageSize: CGSize(width: 128, height: 128)) {
                    ListsView(titleIsFocused: $titleIsFocused, isShowingAddListView: $isShowingAddListView)
                } titleView: {
                    
                    Text("Picked")
                        .font(.system(size: 35).weight(.heavy))
                        .foregroundColor(.white)
                        .disabled(isShowingAddListView)
                        .blur(radius: isShowingAddListView ? 4 : 0)
                    
                } logoView: {
                    
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .disabled(isShowingAddListView)
                        .blur(radius: isShowingAddListView ? 4 : 0)
                } navButtonLeading: {
                    
                    historyButton
                        .disabled(isShowingAddListView)
                        .blur(radius: isShowingAddListView ? 4 : 0)
                    
                } navButtonTrailing: {
                    
                    addListButton
                        .accentColor(.white)
                        .disabled(isShowingAddListView)
                        .blur(radius: isShowingAddListView ? 4 : 0)
                }
                
            } else {
                OnboardingView()
            }
        }
    }
    
    //MARK: - Add List Button
    var addListButton: some View {
        Button {
            isShowingAddListView.toggle()
            titleIsFocused = true
        } label: {
            Label("Add List", systemImage: "plus")
                .font(.body.weight(.semibold))
        }
    }
    
    //MARK: - History Button
    @ViewBuilder
    var historyButton: some View {
        //        if persistenceController.fullVersionUnlocked {
        Button {
            if persistenceController.fullVersionUnlocked {
                isShowingAllItemsView = true
                editMode = .inactive
            } else {
                isShowingUnlockView = true
                
            }
        } label: {
            HStack(spacing: 3) {
                
                Image(systemName: "clock")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text("History")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .textCase(.none)
            }
        }
        .fullScreenCover(isPresented: $isShowingAllItemsView, content: {
            AllItemsListView()
        })
        //        } else {
        //            Button {
        //
        //                isShowingUnlockView = true
        //            } label: {
        //                HStack(spacing: 3) {
        //
        //                    Image(systemName: "clock")
        //                        .font(.body.weight(.semibold))
        //                        .foregroundColor(.white)
        //                        .clipShape(RoundedRectangle(cornerRadius: 6))
        //
        //                    Text("History")
        //                        .font(.body.weight(.semibold))
        //                        .foregroundColor(.white)
        //                        .textCase(.none)
        //                }
        //            }
        //        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
