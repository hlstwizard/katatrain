//
//  DocumentPicker.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/1.
//

import SwiftUI
import UniformTypeIdentifiers


struct DocumentPicker: UIViewControllerRepresentable {
  var game: Game
  
  func makeCoordinator() -> Coordinator {
    return DocumentPicker.Coordinator(parent: self)
  }
  
  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let uttype = UTType("com.yiming.katatrain.sgf")!
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [uttype])
    picker.allowsMultipleSelection = false
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
      
  }
  
  typealias UIViewControllerType = UIDocumentPickerViewController
  
  class Coordinator: NSObject, UIDocumentPickerDelegate {
    var parent: DocumentPicker
    
    init(parent: DocumentPicker) {
      self.parent = parent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      try? self.parent.game.load(url: urls[0])
      
    }
  }
  
}
