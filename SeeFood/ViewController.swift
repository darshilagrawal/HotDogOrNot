//
//  ViewController.swift
//  SeeFood
//
//  Created by Darshil Agrawal on 06/10/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker=UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image=pickedImage
            guard let ciImage=CIImage(image: pickedImage)else {
                fatalError("Error Converting Image to CIImage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image:CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error Loading up MLModel")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results=request.results as? [VNClassificationObservation] else {
                fatalError("Error Fetching Classification results")
            }
            if let firstResult=results.first?.identifier {
                if firstResult.contains("hotdog") {
                    self.navigationItem.title="Hotdog!"
                } else {
                    self.navigationItem.title="Not Hotdog"
                }
            }
        }
        let handler=VNImageRequestHandler(ciImage:image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

