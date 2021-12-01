//
//  DocumentPicker.swift
//  katatrain
//
//  Created by Yiming Huang on 2021/12/1.
//

import SwiftUI
import UniformTypeIdentifiers


struct DocumentPicker: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let uttype = UTType("com.yiming.katatrain.sgf")!
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [uttype])
    picker.allowsMultipleSelection = false
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
      
  }
  
  typealias UIViewControllerType = UIDocumentPickerViewController
  
  
  
}
