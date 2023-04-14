//
//  MainScreenViewController.swift
//  Giphy Demo
//
//  Created by Roman on 11.04.2023.
//

import UIKit

class MainScreenViewController: UIViewController {
    // MARK: - DiffableDataSource
    typealias DataSource = UICollectionViewDiffableDataSource<Section, GiphyModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GiphyModel>
    
    enum Section {
        case main
    }
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties
    private var items: [GiphyModel] = []
    private var offset: Int {
        return items.count
    }
    private var isLoading: Bool = false
    private let limit: Int = 50
    private lazy var dataSource = makeDataSource()
    
    private let loadingQueue = OperationQueue()
    private var loadingOperations: [IndexPath: AnimationLoadingOperation] = [:]
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadInitialData()
    }
    
    // MARK: - Private Methods
    private func setupCollectionView() {
        if let layout = collectionView?.collectionViewLayout as? MosaicLayout {
            layout.delegate = self
        }
        
        collectionView.register(UINib(nibName: MosaicCell.identifier, bundle: nil), forCellWithReuseIdentifier: MosaicCell.identifier)
    }
}

// MARK: - Data Loading Methods
private extension MainScreenViewController {
    func loadInitialData() {
        GiphyService.getTrendingGiphy(offset: 0, limit: limit) { [weak self] result in
            switch result {
            case .success(let response):
                self?.items = response
                self?.reloadData(animated: false)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func reloadData(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.applySnapshot(animatingDifferences: animated)
        }
    }
    
    func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true
        GiphyService.getTrendingGiphy(offset: offset, limit: limit) { [weak self] result in
            switch result {
            case .success(let newItems):
                self?.items.append(contentsOf: newItems)
                self?.reloadData(animated: false)
            case .failure(_):
                break
            }
            self?.isLoading = false
        }
    }
}

// MARK: - DiffableDataSource Methods
private extension MainScreenViewController {
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView,
                                    cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MosaicCell.identifier, for: indexPath)
            return cell
        })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate
extension MainScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let detailedVC = DetailsViewController.make()
        detailedVC.model = model
        detailedVC.modalPresentationStyle = .fullScreen
        let nav = UINavigationController(rootViewController: detailedVC)
        present(nav, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MosaicCell else { return }
        
        if indexPath.item > items.count - 10 {
            loadMoreData()
        }
        
        let updateCellClosure: (Data) -> Void = { [weak self] animationData in
            guard let strong = self else {
                return
            }
            cell.setup(withAnimationData: animationData)
            strong.loadingOperations.removeValue(forKey: indexPath)
        }
        
        if let dataLoader = loadingOperations[indexPath] {
            if let animationData = dataLoader.animationData {
                cell.setup(withAnimationData: animationData)
                loadingOperations.removeValue(forKey: indexPath)
            } else if dataLoader.loadingCompleteHandler == nil {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            let dataLoader = AnimationLoadingOperation(url: items[indexPath.item].preview.url)
            dataLoader.loadingCompleteHandler = updateCellClosure
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
}

// MARK: - Prefetching
extension MainScreenViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if loadingOperations[indexPath] != nil {
                continue
            }

            let dataLoader = AnimationLoadingOperation(url: items[indexPath.item].preview.url)
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}

// MARK: - Mosaic Layout Delegate
extension MainScreenViewController: MosaicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: items[indexPath.item].preview.width,
                      height: items[indexPath.item].preview.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}
