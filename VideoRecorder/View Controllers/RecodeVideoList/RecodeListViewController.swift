//
//  RecodeListViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/11.
//

import UIKit
import Photos
import AVKit

final class RecodeListViewController: UIViewController {

    // MARK: Constants

    enum Metrics {
        static let rowHeight: CGFloat = 100
        static let thumbnailSize: CGSize = .init(width: 100, height: 100)
    }

    // MARK: UI

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Metrics.rowHeight
        tableView.register(RecodeListCell.self, forCellReuseIdentifier: RecodeListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var recordingButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "video.badge.plus.fill"),
            style: .plain,
            target: self,
            action: #selector(recordButtonClicked)
        )
        button.tintColor = .systemPurple
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        return indicator
    }()
    
    private let miniPlayerViewController = UIViewController()

    // MARK: Properties

    // Pagination
    private let fetchSize = 6
    private var fetchLimit = 0
    private var isFetching: Bool = false

    // Fetch Videos
    private let imageManager = PHCachingImageManager()
    private let albumTitle = "MyVideos"
    private var fetchResult: PHFetchResult<PHAsset>?
    private var album: PHAssetCollection?

    // Preview
    private var looper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        fetchAssetCollection(for: albumTitle) {
            guard let album = self.album else { return }
            self.fetchMoreAssets(in: album)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        PHPhotoLibrary.shared().register(self)
    }

    // MARK: Layout
    
    private func setupNavigation() {
        navigationItem.title = "Video List"
        navigationItem.rightBarButtonItem = recordingButton
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: Pagination & Fetch Videos

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let album = album else { return }

        let offsetY = tableView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let height = tableView.bounds.size.height

        if offsetY > contentHeight - height {
            fetchMoreAssets(in: album)
        }
    }

    /// Fetching Asset Collection for specific `albumTitle`
    private func fetchAssetCollection(
        for albumTitle: String,
        completion: (() -> Void)?
    ) {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", albumTitle)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        album = assetCollections.firstObject
        completion?()
    }

    /// Fetching Assets by Page in `assetCollection`
    private func fetchMoreAssets(in assetCollection: PHAssetCollection) {
        if !isFetching {
            isFetching = true
            fetchLimit += fetchSize
            activityIndicator.startAnimating()

            fetchAssets(in: assetCollection, limitedBy: fetchLimit) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.isFetching = false
                }
            }
        }
    }

    /// Fetching up to `limit` Assets in `assetCollection`
    private func fetchAssets(
        in assetCollection: PHAssetCollection,
        limitedBy limit: Int,
        completion: (() -> Void)?
    ) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = limit
        fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        completion?()
    }

    // MARK: Preview

    private func setupPlayer(_ asset: PHAsset, completion: @escaping (AVAsset) -> Void) {
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
            guard let avAsset = avAsset else { return }
            completion(avAsset)
        }
    }

    private func setupMiniPlayer(_ asset: PHAsset) {
        let timescale: CMTimeScale = 600
        let start = CMTime(value: 0, timescale: timescale)
        let seconds: Int64 = 5
        var duration = CMTime(value: Int64(timescale) * seconds, timescale: timescale)

        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
            guard let avAsset = avAsset else { return }

            DispatchQueue.main.async {
                let playerItem = AVPlayerItem(asset: avAsset)
                self.queuePlayer = AVQueuePlayer(items: [playerItem])

                // 영상의 길이가 5초보다 짧을 경우 영상 길이만큼만 반복
                duration = CMTimeCompare(avAsset.duration, duration) == 1 ? duration : avAsset.duration
                let timeRange = CMTimeRangeMake(start: start, duration: duration)

                self.looper = AVPlayerLooper(player: self.queuePlayer!, templateItem: playerItem, timeRange:  timeRange)
                let playerLayer = AVPlayerLayer(player: self.queuePlayer)
                playerLayer.videoGravity = .resizeAspectFill
                self.miniPlayerViewController.view.layer.addSublayer(playerLayer)
                playerLayer.frame = self.miniPlayerViewController.view.frame

                self.queuePlayer!.play()
            }
        }
    }

    // MARK: Action Handler

    @objc
    private func recordButtonClicked() {
        let vc = RecordingViewController()
        guard navigationController?.topViewController == self else { return }
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - UITableViewDataSource

extension RecodeListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecodeListCell.reuseIdentifier, for: indexPath) as? RecodeListCell else {
            return UITableViewCell()
        }
        guard let asset = fetchResult?.object(at: indexPath.row) else { return cell }

        cell.configure(with: asset)
        imageManager.requestImage(for: asset, targetSize: Metrics.thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImageView.image = image
            }
        }
        return cell
    }

}

// MARK: - UITableViewDelegate

extension RecodeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let asset = fetchResult?.object(at: indexPath.row) else { return }

        let fileName = asset.originalFilename
        setupPlayer(asset) { asset in
            DispatchQueue.main.async {
                guard self.navigationController?.topViewController == self else { return }
                let vc = VideoPlayerViewController(asset: asset)
                vc.fileName = fileName
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let asset = fetchResult?.object(at: indexPath.row) else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }) { success, error in
                if success {
                    print("Remove the asset: \(String(describing: asset.localIdentifier))")
                } else {
                    print("Can't remove the asset: \(String(describing: error))")
                }
            }
        }
        DispatchQueue.global(qos: .background).async {
            FirebaseStorage.shared.delete(fileName: asset.originalFilename)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let asset = fetchResult?.object(at: indexPath.row) else { return nil }

        setupMiniPlayer(asset)
        var configuration: UIContextMenuConfiguration!
        let assetIdentifier = asset.localIdentifier as NSCopying
        configuration = UIContextMenuConfiguration(
            identifier: assetIdentifier,
            previewProvider: { self.miniPlayerViewController },
            actionProvider: nil
        )
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        queuePlayer?.pause()
    }

}

// MARK: - PHPhotoLibraryChangeObserver

extension RecodeListViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = fetchResult,
              let details = changeInstance.changeDetails(for: fetchResult) else { return }

        self.fetchResult = details.fetchResultAfterChanges
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
