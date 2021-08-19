//
//  ViewController.swift
//  CoreML-Swift-5-IOS-Example
//
//  Created by apple on 19/08/21.
//

import UIKit
import CoreML
import Vision
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Click on camera"
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        PHPhotoLibrary.requestAuthorization { (status) in
           // No crash
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print("image")
        guard let image = info[.originalImage] as? UIImage else  {
            fatalError("Error while picking image")
        }
        imageView.image = image
        guard let ciImage = CIImage(image: image) else {
            fatalError("Error retreiving ci image")
        }
        detectImage(image: ciImage)
    }
   func detectImage (image:CIImage) {
    
    guard let model = try? VNCoreMLModel(for : Inceptionv3().model) else {
        fatalError("Error while creating ML Model")
    }
    let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
        guard let result = vnRequest.results as? [VNClassificationObservation] else {
            fatalError("Error fetching results")
        }
        if let identifierName = result.first?.identifier { // first is the highest value
            print(identifierName)
            self.navigationItem.title = identifierName
        }
        
    }
    let handler = VNImageRequestHandler(ciImage: image)
    do {
        try handler.perform([request])
    }
    catch {
        print(error)
    }
    
   }
    @IBAction func imageViewClicked(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

