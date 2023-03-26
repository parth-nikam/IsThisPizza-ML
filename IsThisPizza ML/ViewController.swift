//
//  ViewController.swift
//  IsThisPizza ML
//
//  Created by Parth Nikam on 26/03/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage){
        do {
            let model = try VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model)

            let request = VNCoreMLRequest(model: model) { (request, error) in
                guard let results = request.results as? [VNClassificationObservation] else{
                    fatalError("Model failed to process image")
                }
                if let firstResult = results.first {
                    if firstResult.identifier.contains("pizza"){
                        self.navigationItem.title = "This is Pizza!!!🍕"
                    } else {
                        self.navigationItem.title = "Not a Pizza😭"
                    }
                }
            }

            let handler = VNImageRequestHandler(ciImage: image)
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        } catch {
            fatalError("Loading CoreML model failed.")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker,animated: true, completion: nil)
    }
}
