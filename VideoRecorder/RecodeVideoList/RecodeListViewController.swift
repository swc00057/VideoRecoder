//
//  RecodeListViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/11.
//

import UIKit

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

    private var videos = Video.sampleData

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupViews()
    }

    private func setupNavigation() {
        navigationItem.title = "Video List"
        navigationItem.rightBarButtonItem = recordingButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupViews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc
    private func recordButtonClicked() {
        // TODO: 영상녹화화면으로 이동
    }

}

extension RecodeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecodeListCell.reuseIdentifier, for: indexPath) as? RecodeListCell else {
            return UITableViewCell()
        }
        let video = videos[indexPath.row]
        cell.configure(with: video)
        return cell
    }
}

extension RecodeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 영상을 짧게 누르면 해당 영상을 볼 수 있는 세번째 페이지로 이동합니다.
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // TODO: 행을 스와이프 하면 삭제할 수 있도록 UI와 UX를 제공합니다.
        // 백업된 영상도 삭제합니다.
        return nil
    }
}
