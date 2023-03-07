//
//  DownloadButtonView.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//


import UIKit


class DownloadButtonView: UIButton {

    private let progressButton = UICircleProgressButton(frame: .zero)
    private let statusLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureProgressView()
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureProgressView() {
        progressButton.translatesAutoresizingMaskIntoConstraints = false
        
        progressButton.status = .canceled
        progressButton.style = .new
        progressButton.startImage = UIImage(systemName: "icloud.and.arrow.down")
        progressButton.successImage = UIImage(systemName: "checkmark.circle.fill")
        progressButton.strokeDynamic = true
        progressButton.tintColor = .systemBlue
        progressButton.colorCanceled = .systemBlue
        progressButton.isUserInteractionEnabled = false
        progressButton.accessibilityIdentifier = "com.myapp.DownloadButtonView.progressButton"
        
        
        addSubview(progressButton)
        
        NSLayoutConstraint.activate([
            progressButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressButton.widthAnchor.constraint(equalToConstant: 25),
            progressButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func configureLabel() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .systemBlue
        statusLabel.text = "Download"
        statusLabel.accessibilityIdentifier = "com.myapp.DownloadButtonView.statusLabel"
        
        addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: progressButton.trailingAnchor, constant: 8)
        ])
    }
    
    func setProgress(_ progress: Float) {
        progressButton.progress = progress
    }
    
    func setButtonEnabled(_ enabled: Bool) {
        progressButton.isEnabled = enabled
    }
    func setStatus(_ status: UICircleProgressView.DownloadStatus) {
        progressButton.status = status
        
            statusLabel.text = status.downloadButtonText
            statusLabel.textColor = status.downloadButtonStatusLabelColor
            progressButton.tintColor = status.downloadButtonTintColor

    }
    
    func setButtonAction(_ target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
}

extension UICircleProgressView.DownloadStatus {
    var downloadButtonText:String {
        switch self {
            
        case .paused:
            return "Paused"
        case .waiting:
            return "Wait..."
        case .downloading:
            return "Cancel"
        case .success:
            return "Downloaded"
        case .canceled:
            return "Download"
        }
    }
    
    var downloadButtonTintColor:UIColor {
        switch self {
        case .success:
            return .green
        default:
            return .systemBlue
        }
    }
    
    var downloadButtonStatusLabelColor: UIColor {
        switch self {
        case .success:
            return .green
        default:
            return .systemBlue
        }
    }
    
}
