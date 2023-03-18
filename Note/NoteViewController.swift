//
//  ViewController.swift
//  Note
//
//  Created by Alex Jun on 2023-01-24.
//

import UIKit
import PencilKit

class NoteViewController: UIViewController, PKToolPickerObserver {

    @IBOutlet weak var canvasView: PKCanvasView!
    var toolPicker: PKToolPicker!
    var saveDrawingItem: UIBarButtonItem!
    static let canvasOverscrollHeight: CGFloat = 500
    public var fileName = "untitled"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navBarItems()
        self.title = fileName
        
        
        // Set up the tool picker
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        canvasView.becomeFirstResponder()
        
        // Show a back button.
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    
    private func navBarItems() {
        
        if #available(iOS 16.0, *) {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(
                    title: "save",
                    image: UIImage(systemName: "square.and.arrow.down"),
                    target: self,
                    action: nil
                ),
                UIBarButtonItem(
                    title: "changeName",
                    image: UIImage(systemName: "pencil"),
                    target: self,
                    action: nil
                )
            ]
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(
                    title: "save",
                    style: .plain,
                    target: self,
                    action: nil
                ),
                UIBarButtonItem(
                    title: "edit",
                    style: .plain,
                    target: self,
                    action: nil
                )
            ]
        }
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // Makes the bottom home bar hidden
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    
}

