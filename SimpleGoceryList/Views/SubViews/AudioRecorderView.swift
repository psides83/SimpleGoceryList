//
//  AudioRecorderView.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/13/21.
//

import SwiftUI

struct AudioRecorderView: View {
    
    //MARK: - Properties
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var item: Item
    
    @Binding var isShowingAudioRecorder: Bool
    
    //MARK: - Body
    var body: some View {
        
        HStack {
            Text("Record a note for this list item")
                .foregroundColor(.secondary)
            Spacer()
            if audioRecorder.recording == false {
                Button(action: {audioRecorder.startRecording(for: item)}) {
                    Image(systemName: "record.circle")
                        .imageScale(.large)
                        .foregroundColor(.red.opacity(0.6))
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                Button(action: {
                        audioRecorder.stopRecording()
                    isShowingAudioRecorder = false
                }) {
                    Image(systemName: "stop.circle")
                        .imageScale(.large)
                        .foregroundColor(.red.opacity(0.6))
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            Spacer()
            
            Button(action: {isShowingAudioRecorder = false}) {
                Image(systemName: "delete.left")
                    .imageScale(.large)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

//struct AudioRecorderView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioRecorderView(audioRecorder: AudioRecorder(), item: <#Item#>)
//    }
//}
