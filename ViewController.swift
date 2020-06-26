//
//  ViewController.swift
//  What's In My Garden?
//
//  Created by Tristan Prater on 6/25/20.
//  Copyright © 2020 Tristan Prater. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var picFromCam: UIImageView!
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pictureTake = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                picFromCam.image = pictureTake
            
                guard let ciImage = CIImage(image: pictureTake)else {
                        fatalError("Could not convert to CIIMage")
                    }
                    Detect(flowerImage: ciImage)
                }
                imagePicker.dismiss(animated: true, completion: nil)
            }
    
    
    func Detect(flowerImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading CoreMLModel failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("could not classify items")
            }
            
            self.navigationItem.title = classification.identifier.capitalized
            
            self.getWiki(flowerName: classification.identifier)
            }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
       
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
        }
    }

    

    
    func getWiki(flowerName: String) {
        
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts",
        "exintro" : "",
        "explaintext" : "",
        "titles" : flowerName,
        "indexpageids" : "",
        "redirects" : "1"
        ]
        
        
       AF.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success:
                print("Validation Successful")
                print(response)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    
    

    @IBAction func buttonTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

