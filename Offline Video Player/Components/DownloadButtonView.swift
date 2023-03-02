//
//  DownloadButtonView.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//


import UIKit


class DownloadButtonView: UIButton {

    private let progressButtonButton = UICircleProgressButton(frame: .zero)
    private let statusLaabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureProgressView()
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureProgressView() {
        progressButtonButton.translatesAutoresizingMaskIntoConstraints = false
        
        progressButtonButton.status = .canceled
        progressButtonButton.style = .new
        progressButtonButton.startImage = UIImage(systemName: "icloud.and.arrow.down")
        progressButtonButton.successImage = UIImage(systemName: "checkmark.circle.fill")
        progressButtonButton.strokeDynamic = true
        progressButtonButton.tintColor = .systemBlue
        progressButtonButton.colorCanceled = .systemBlue
        progressButtonButton.isUserInteractionEnabled = false
        
        
        addSubview(progressButtonButton)
        
        NSLayoutConstraint.activate([
            progressButtonButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressButtonButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressButtonButton.widthAnchor.constraint(equalToConstant: 25),
            progressButtonButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func configureLabel() {
        statusLaabel.translatesAutoresizingMaskIntoConstraints = false
        statusLaabel.textColor = .systemBlue
        statusLaabel.text = "Download"
        addSubview(statusLaabel)
        NSLayoutConstraint.activate([
            statusLaabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusLaabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            statusLaabel.leadingAnchor.constraint(equalTo: progressButtonButton.trailingAnchor, constant: 10)
        ])
    }
    
    func setProgress(_ progress: Float) {
        progressButtonButton.progress = progress
    }
    
    func setButtonEnabled(_ enabled: Bool) {
        progressButtonButton.isEnabled = enabled
    }
    func setStatus(_ status: UICircleProgressView.DownloadStatus) {
        progressButtonButton.status = status
        switch status {
            
        case .paused:
            break
        case .waiting:
            statusLaabel.text = "Wait..."
        case .downloading:
            statusLaabel.text = "Cancel"
        case .success:
            statusLaabel.text = "Downloaded"
            statusLaabel.textColor = .green
            progressButtonButton.tintColor = .green
            
        case .canceled:
            statusLaabel.text = "Download"
        }
    }
    
    func setButtonAction(_ target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    
}
