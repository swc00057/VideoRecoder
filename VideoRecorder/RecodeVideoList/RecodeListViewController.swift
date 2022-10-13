//
//  RecodeListViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/11.
//

import UIKit
import Photos

final class RecodeListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
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

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        return indicator
    }()

    private let imageManager = PHCachingImageManager()
    private let albumTitle = "MyVideos"
    private let fetchSize = 6

    private var fetchLimit = 0
    private var fetchResult: PHFetchResult<PHAsset>?
    private var isFetching: Bool = false
    private var album: PHAssetCollection?

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let album = album else { return }

        let offsetY = tableView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let height = tableView.bounds.size.height

        if offsetY > contentHeight - height {
            fetchMoreAssets(in: album)
        }
    }

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

    @objc
    private func recordButtonClicked() {
        // TODO: 영상녹화화면으로 이동
        let vc = RecordingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
        let size = CGSize(width: 100, height: 100)
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
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

        let viewController = PlayBackViewController(with: asset)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let asset = fetchResult?.object(at: indexPath.row) else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            // TODO: 백업된 영상도 삭제합니다.
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
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let asset = fetchResult?.object(at: indexPath.row) else { return nil }

        let assetIdentifier = asset.localIdentifier as NSCopying
        let viewController = PlayBackViewController(with: asset)
        let configuration = UIContextMenuConfiguration(
            identifier: assetIdentifier,
            previewProvider: { viewController },
            actionProvider: nil
        )
        return configuration
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension RecodeListViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            guard let fetchResult = self.fetchResult,
                  let details = changeInstance.changeDetails(for: fetchResult) else { return }

            self.fetchResult = details.fetchResultAfterChanges
            self.tableView.reloadData()
        }
    }
}
