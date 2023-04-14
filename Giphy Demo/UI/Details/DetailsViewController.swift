//
//  DetailsViewController.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import UIKit
import Gifu
import Photos

class DetailsViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: GIFImageView!
    @IBOutlet weak var shimmeringView: ShimmeringView!
    @IBOutlet weak var copyGifLinkButton: UIButton!
    @IBOutlet weak var copyGifButton: UIButton!
    
    // MARK: - Private Properties
    private var imageData: Data?
    
    // MARK: - Internal Properties
    let operationQueue = OperationQueue()
    var operation: AnimationLoadingOperation?
    
    // MARK: - Public Properties
    public var model: GiphyModel? {
        didSet {
            loadModel()
        }
    }
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shimmeringView.backgroundColor = UIColor.randomColor()
        
        setupNavigationBar()
        loadModel()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action))
    }
}

// MARK: - Model Loading
private extension DetailsViewController {
    func loadModel() {
        guard isViewLoaded else {
            return
        }
        guard let model else {
            imageView.image = nil
            return
        }
        
        // Load preview to show while hq is loaded, most probably will come from cache
        // I've decided to disable it since it looks ugly in terms of UX
        
//        let previewDataLoader = AnimationLoadingOperation(url: model.preview.url)
//        previewDataLoader.loadingCompleteHandler = { [weak self] data in
//            self?.onModelLoaded(data: data)
//        }
//        operationQueue.addOperation(previewDataLoader)
        shimmeringView.startShim()
        
        let dataLoader = AnimationLoadingOperation(url: model.highQuality.url)
        dataLoader.loadingCompleteHandler = { [weak self] data in
            self?.onModelLoaded(data: data)
            self?.operation = nil
        }
        operation = dataLoader
        operationQueue.addOperation(dataLoader)
    }
    
    func onModelLoaded(data: Data) {
        self.imageData = data
        DispatchQueue.main.async { [weak self] in
            self?.imageView.animate(withGIFData: data)
            self?.shimmeringView.stopShim()
            self?.shimmeringView.isHidden = true
        }
    }
}
    
// MARK: - Animation saving
private extension DetailsViewController {
    func onPhotoSaved(success: Bool, error: Error?) {
        DispatchQueue.main.async {
            if let error {
                self.presentFailure(message: error.localizedDescription)
                return
            }
            guard success else {
                self.presentFailure(message: "Unknown error!")
                return
            }
            self.presentSuccess(message: "GIF is saved to Camera Roll!")
        }
    }
    
    func writeAnimationDataToTemporaryFile() throws -> URL {
        guard let imageData else {
            throw NSError(domain: "No image data found", code: -1)
        }
        let tempURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).gif")
        try imageData.write(to: tempURL)
        return tempURL
    }
}

// MARK: - Actions
private extension DetailsViewController {
    @objc
    private func action() {
        guard let imageData else { return }
        let activityVC = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc
    private func close() {
        dismiss(animated: true)
    }
    
    
    @IBAction func copyGifLinkPressed(_ sender: Any) {
        UIPasteboard.general.url = model?.giphyURL
        presentSuccess(message: "URL is copied!")
    }
    
    @IBAction func copyGifPressed(_ sender: Any) {
        do {
            let url = try writeAnimationDataToTemporaryFile()
            PHPhotoLibrary.shared().performChanges {
                _ = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            } completionHandler: { [weak self](success, error) in
                try? FileManager.default.removeItem(at: url)
                self?.onPhotoSaved(success: success, error: error)
            }
        } catch {
            presentFailure(message: error.localizedDescription)
        }
    }
}
