//
//  ViewController.swift
//  Note
//
//  Created by Alex Jun on 2023-01-24.
//

import UIKit
import PencilKit

class NoteViewController: UIViewController, UITextFieldDelegate, PKCanvasViewDelegate, PKToolPickerObserver, UIScrollViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    

    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var toggleToolPickerButton: UIBarButtonItem!
    
    let id: UUID = UUID()
    
    var toolPicker: PKToolPicker!
    var saveDrawingItem: UIBarButtonItem!
    static let canvasOverscrollHeight: CGFloat = 300
    let screenSize: CGRect = UIScreen.main.bounds
    var hasModifiedDrawing = false
    
    public var fileName = "Untitled"
    private var showingSelector = false
    var initialPath: URL? = nil
    var selectedPath = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeName.placeholder = fileName
        changeName.text = fileName
        setCanvas()
        
        
        // Show a back button.
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleOffApplePencilToolKit(_ :)), name: Notification.Name("hideApplePencilToolKit"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleOnApplePencilToolKit(_ :)), name: Notification.Name("showApplePencilToolKit"), object: nil)
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSaveImageNotification(_:)), name: NSNotification.Name("Notes/saveImage/\(self.id)"), object: nil)
         */
    }
    
    @objc func toggleOffApplePencilToolKit(_ notification: Notification) {
        if(canvasView != nil){
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            canvasView.resignFirstResponder()
        }
    }
    
    @objc func toggleOnApplePencilToolKit(_ notification: Notification) {
        if(canvasView != nil){
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    func setCanvas() {
        canvasView.becomeFirstResponder()
        canvasView.alwaysBounceVertical = true
        
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

        changeName.delegate = self
        canvasView.delegate = self
        canvasView.isOpaque = false
        
        canvasView.minimumZoomScale = 1
        canvasView.maximumZoomScale = 2.5
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.canvasView
    }
    
    @IBAction func toggleToolPicker() {
        if(toolPicker.isVisible){
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            toggleToolPickerButton.image = UIImage(systemName: "pencil.slash")
        } else{
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toggleToolPickerButton.image = UIImage(systemName: "pencil")
        }
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        print("tapped note view")
        if(changeName.isFirstResponder){
            let newfileName:String = changeName.text!
            if(newfileName != ""){
                fileName = newfileName
                changeName.text = fileName
            } else{
                changeName.text = fileName
            }
            changeName.placeholder = fileName
            changeName.resignFirstResponder()
            canvasView.becomeFirstResponder()
        }
        if(!toolPicker.isVisible){
            toggleToolPicker()
        }
    }
    
    // Hides keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let newfileName:String = changeName.text!
        if(newfileName != ""){
            fileName = newfileName
            changeName.text = fileName
        } else{
            changeName.text = fileName
        }
        changeName.placeholder = fileName
        changeName.resignFirstResponder()
        canvasView.becomeFirstResponder()
        toggleToolPicker()
        //setCanvas()
        return true
    }

    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasModifiedDrawing = true
        updateContentSizeForDrawing()
    }
    
    func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        var contentHeight: CGFloat
        let screenWidth = screenSize.width
        
        contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + NoteViewController.canvasOverscrollHeight) * canvasView.zoomScale)
        if contentHeight == CGFloat.infinity {
            contentHeight = canvasView.bounds.height
        }
        canvasView.minimumZoomScale = canvasView.bounds.width / screenWidth
        if (canvasView.minimumZoomScale > canvasView.zoomScale) {
            canvasView.zoomScale = canvasView.minimumZoomScale
        }
        canvasView.contentSize = CGSize(width: screenWidth * canvasView.zoomScale, height: contentHeight * 1.2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentSizeForDrawing()
    }
    
    // Makes the bottom home bar hidden
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // clears page
    @IBAction func clearPage(_ sender: UIBarButtonItem) {
        self.canvasView.drawing = PKDrawing()
        canvasView.contentSize = CGSize(width: 0, height: 0)
    }
    
    
    
    
    // saves current drawing in png image format
    @available(iOS 16.0, *)
    @IBAction func saveToFiles(_ sender: UIBarButtonItem) {
        /*
        let controller: FBLocationSelectorHostingController = FBLocationSelectorHostingController.init(notification: "Notes/saveImage/\(self.id)", selectorTitle: "Save to")
        controller.modalPresentationStyle = .formSheet
        self.present(controller, animated: true, completion: nil)
        */
    }
    // code is specific to infiniteX2P
    /*
    
    @objc func didReceiveSaveImageNotification(_ notification: Notification) {
        let toPath = notification.object as! URL
        let image = canvasView.drawing.image(from: screenSize, scale: 1.0)
        
        guard let data = image.pngData() else { return }
        print (fileName)
        fileName = FBFileManager.init().validateFilename(atPath: toPath, name: fileName, withExtension: "png")
        changeName.text = fileName
        print (fileName)
        print(toPath)
        try? data.write(to: toPath.appendingPathComponent(fileName+".png"))
    }
    */

     
}
