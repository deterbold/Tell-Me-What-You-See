//
//  ViewController.swift
//  Tell Me What You See
//
//  Created by Miguel Sicart on 05/02/2020.
//  Copyright © 2020 Miguel Sicart. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    //MARK: - UI VARIABLES
       var camera: UIBarButtonItem!
       var library: UIBarButtonItem!
        var shareButton: UIBarButtonItem!
    var spacer: UIBarButtonItem!
       //text view
       var answerField: UITextView!
       //outletView
       var outletView: UIImageView!
       

       
       override func viewDidLoad()
       {
           super.viewDidLoad()
           
           //MARK: - TOOLBAR INTERFACE
           navigationController?.setToolbarHidden(false, animated: true)
           navigationController?.setNavigationBarHidden(false, animated: true)
           navigationController?.toolbar.barTintColor = .systemBackground
           camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePicture))
           library = UIBarButtonItem(title: "LIBRARY", style: .plain, target: self, action: #selector(openPhotoLibrary))
            shareButton = UIBarButtonItem(title: "SHARE", style: .plain, target: self, action: #selector(shareScreenshot))
            spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
           toolbarItems = [spacer, spacer, spacer, library, spacer, spacer, camera, spacer, spacer, spacer]
           
           //MARK: - OUTLET VIEW INIT
           outletView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.8))
        outletView.contentMode = .scaleAspectFit
           view.addSubview(outletView)
        

           outletView.translatesAutoresizingMaskIntoConstraints = false
           outletView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
           outletView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
           outletView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
           outletView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
           outletView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
           
           //MARK: - LABELS
            //https://stackoverflow.com/questions/37893000/swift-infinite-fade-in-and-out-loop
           answerField = UITextView(frame: CGRect(x: 25, y: self.view.frame.midY - 50, width: self.view.frame.width - 50, height: 120))
           //answerField.font = .boldSystemFont(ofSize: 60)
        answerField.font = UIFont(name: "Avenir-BlackOblique", size: 60)
           answerField.textColor = .black
           answerField.textAlignment = .center
           answerField.isEditable = false
           answerField.adjustsFontForContentSizeCategory = true
           answerField.text = "Take a picture or choose a picture from your library to learn what something is \n ABSOLUTELY NOT"
           answerField.updateTextFont()
        if self.traitCollection.userInterfaceStyle == .dark
        {
            self.view.backgroundColor = .black
            answerField.textColor = .white
            answerField.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6)
        }
        else if self.traitCollection.userInterfaceStyle == .light
        {
            self.view.backgroundColor = .white
            answerField.textColor = .black
            answerField.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.6)

        }
           view.addSubview(answerField)
           answerField.isHidden = false
       }
    
    //MARK: - INTERFACE CHANGES
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            if self.traitCollection.userInterfaceStyle == .dark
                  {
                      self.view.backgroundColor = .black
                    self.answerField.textColor = .white
                    answerField.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6)
                  }
                  else if self.traitCollection.userInterfaceStyle == .light
                  {
                      self.view.backgroundColor = .white
                    self.answerField.textColor = .black
                    answerField.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.6)
                  }
       }

       override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
            if self.traitCollection.userInterfaceStyle == .dark
            {
                self.view.backgroundColor = .black
              self.answerField.textColor = .white
            }
            else if self.traitCollection.userInterfaceStyle == .light
            {
                self.view.backgroundColor = .white
              self.answerField.textColor = .black
            }
       }
       
       @objc func takePicture()
       {
           let vc = UIImagePickerController()
           vc.sourceType = .camera
           vc.allowsEditing = false
           vc.delegate = self
           present(vc, animated: true)
       }
       
        @objc func openPhotoLibrary()
          {
              if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
              {
                  let imagePicker = UIImagePickerController()
                  imagePicker.delegate = self
                  imagePicker.sourceType = .photoLibrary
                  imagePicker.allowsEditing = false
                  present(imagePicker, animated: true)
              }
          }
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
       {
           var selectedImagefromPicker: UIImage?
          
           if let editedImage = info[.editedImage] as? UIImage
           {
               selectedImagefromPicker = editedImage
           }
           else if let originalImage = info[.originalImage] as? UIImage
           {
               selectedImagefromPicker = originalImage
           }
           
           if let selectedImage = selectedImagefromPicker
           {
               outletView.image = selectedImage
               guard let transformedImage = CIImage(image: selectedImage) else { return }
               artificialIntelligence(image: transformedImage)
           }
           print(selectedImagefromPicker!.size)
           
           dismiss(animated: true, completion: nil)
       
       }
    
    @objc func shareScreenshot()
    {
    navigationController?.setToolbarHidden(true, animated: true)
           navigationController?.setNavigationBarHidden(true, animated: true)
           var screenshot: UIImage?
           let layer = UIApplication.shared.keyWindow!.layer
           let scale = UIScreen.main.scale
           UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
           guard let context = UIGraphicsGetCurrentContext() else {return}
           layer.render(in: context)
           screenshot = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           let imageShare = [ screenshot! ]
           let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
           activityViewController.popoverPresentationController?.sourceView = self.view
           self.present(activityViewController, animated: true, completion: nil)
           activityViewController.completionWithItemsHandler = { activity, success, items, error in
               print("activity: \(String(describing: activity)), success: \(success), items: \(String(describing: items)), error: \(String(describing: error))")
               self.navigationController?.setToolbarHidden(false, animated: true)
               self.navigationController?.setNavigationBarHidden(false, animated: true)
           }
    }
       
    //MARK: - ARTIFICIAL INTELLIGENCE, BABY!
    
    func artificialIntelligence(image: CIImage)
           {

            answerField.frame.size.width = self.outletView.frame.width
            answerField.frame.origin.x = self.outletView.frame.origin.x
            answerField.updateTextFont()
            answerField.text = "Detecting image ..."
            toolbarItems = [spacer, library, spacer, shareButton, spacer, spacer, camera, spacer]

               // Load the ML model through its generated class
               guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
                   fatalError("Can't load Inception ML model")
               }

               // Create a Vision request with completion handler
               let request = VNCoreMLRequest(model: model)
               { [weak self] request, error in

                guard let results = request.results as? [VNClassificationObservation],
                    
                    
                    let firstResult = results.first else { fatalError("unexpected result type") }
                    let secondResult = results[1]
                let thirdResult = results[2]
                let fourthResult = results[3]
                
                let firstResultID: String = firstResult.identifier
                let secondResultID: String = secondResult.identifier
                let thirdResultID: String = thirdResult.identifier
                let fourthResultID: String = fourthResult.identifier
                

                DispatchQueue.main.async
                {
                    [weak self] in
                    
                    let limit = ","
                    let firstResultIDCut = firstResultID.components(separatedBy: limit)
                    let firstResultFInal = firstResultIDCut[0]
                    print(firstResultFInal)
                    let secondResultIDCut = secondResultID.components(separatedBy: limit)
                    let secondResultFInal = secondResultIDCut[0]
                    print(secondResultFInal)
                    let thirdResultIDCut = thirdResultID.components(separatedBy: limit)
                    let thirdResultFInal = thirdResultIDCut[0]
                    print(thirdResultFInal)
                    let fourthResultIDCut = fourthResultID.components(separatedBy: limit)
                    let fourthResultFInal = fourthResultIDCut[0]
                    print(fourthResultFInal)
                    
                    //write in the label what the computer can see.
                    
                   
                }
               }

               // Run the Core ML model classifier on global dispatch queue
               let handler = VNImageRequestHandler(ciImage: image)
               DispatchQueue.global(qos: .userInteractive).async {
                   do {
                       try handler.perform([request])
                   } catch {
                       print(error)
                   }
               }
           }
}


