//
//  ListViewCell.swift
//  FamousSpotTour
//
//  Created by Takayasu Nasu on 2021/01/30.
//

import UIKit
import SnapKit

class ListViewCell: UITableViewCell {

    let wrapper: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()

    let above: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()

    let below: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        return view
    }()

    let rightImageBlock: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()

    let textBlock: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        return view
    }()

    let picture: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    let image1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    let image2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    let name: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    let headline: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUi()
        self.setAboveUi()
        self.setBelowUi()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUi() {
        super.contentView.addSubview(self.wrapper)
        self.wrapper.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    private func setAboveUi() {
        self.wrapper.addArrangedSubview(self.above)
        self.above.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.wrapper).multipliedBy(0.94)
            make.top.equalTo(self.wrapper)
        }
        self.above.addArrangedSubview(self.picture)
        self.picture.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.above)
            make.leading.equalTo(self.above)
//            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(contentView.bounds.width * 0.6)
        }
        self.above.addArrangedSubview(self.rightImageBlock)
        self.rightImageBlock.snp.makeConstraints { (make) -> Void in
            make.trailing.equalTo(self.above)
            make.height.equalToSuperview()
        }
        self.rightImageBlock.addArrangedSubview(self.image1)
        self.rightImageBlock.addArrangedSubview(self.image2)
        self.image1.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(contentView.bounds.width * 0.3).labeled("image1.height")
        }
    }

    private func setBelowUi() {
        self.wrapper.addArrangedSubview(self.below)
        self.below.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.94)
        }
        self.below.addArrangedSubview(self.name)
        self.name.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        self.below.addArrangedSubview(self.headline)
        self.headline.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().multipliedBy(0.4)
        }
    }

    func update(with location: Location) {
        ViewController.share.fetchImage(url: URL(string: location.picture)!) { (image) in
            DispatchQueue.main.async {
                self.picture.image = image
            }
        }
        self.name.text = location.name
        self.headline.text = location.headline

        if location.subPictures.count > 0 {
            ViewController.share.fetchImage(url: URL(string: location.subPictures[0])!) { (image) in
                DispatchQueue.main.async {
                    self.image1.image = image
                }
            }
        }

        if location.subPictures.count > 1 {
            ViewController.share.fetchImage(url: URL(string: location.subPictures[1])!) { (image) in
                DispatchQueue.main.async {
                    self.image2.image = image
                }
            }
        }
    }

}
