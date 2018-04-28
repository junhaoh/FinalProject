//
//  ImageMLViewController.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/23/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ImageMLViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageText: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            
            guard let ciimage = CIImage(image: pickedImage) else {
                fatalError("Failed to convert CIImage!")
            }
            imageRecognizer(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imageRecognizer(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Failed to load CoreML!")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed to process images with model")
            }
        
            if let firstResult = results.first {
                self.navigationItem.title = "\(firstResult.identifier) @ \(round(firstResult.confidence * 1000) / 10)%"
            }
            
            let secondResult = results[1]
            self.imageText.text = "\(secondResult.identifier) @ \(round(secondResult.confidence * 1000) / 10)%"
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error: \(error)")
        }
    }
    
    @IBAction func camera(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    


}
