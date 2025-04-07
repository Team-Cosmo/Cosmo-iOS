//
//  OnBoardingPriorityViewController.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/1/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

protocol DragDropStackViewDelegate: AnyObject {
    func didBeginDrag()
    func dargging(inUpDirection up: Bool, maxY: CGFloat, minY: CGFloat)
    func didEndDrop()
}

struct DragDropConfig {
    let clipsToBoundsWhileDragDrop: Bool
    let dragEffectCornerRadius: Double
    let dargViewScale: Double
    let otherViewsScale: Double
    let temporaryViewAlpha: Double
    let dragBeganEffectOffsetY: Double
    let longPressMinimumPressDuration: Double
    
    init(
        clipsToBoundsWhileDragDrop: Bool = false,
        dragEffectCornerRadius: Double = 8.0,
        dargViewScale: Double = 1.2,
        otherViewsScale: Double = 0.9,
        temporaryViewAlpha: Double = 0.85,
        dragBeganEffectOffsetY: Double = 4.0,
        longPressMinimumPressDuration: Double = 0.2
    ) {
        self.clipsToBoundsWhileDragDrop = clipsToBoundsWhileDragDrop
        self.dragEffectCornerRadius = dragEffectCornerRadius
        self.dargViewScale = dargViewScale
        self.otherViewsScale = otherViewsScale
        self.temporaryViewAlpha = temporaryViewAlpha
        self.dragBeganEffectOffsetY = dragBeganEffectOffsetY
        self.longPressMinimumPressDuration = longPressMinimumPressDuration
    }
}

class OnBoardingPriorityViewController: UIViewController, DragDropStackViewDelegate {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "과목별 학습 우선 순위를\n알려주세요"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "성향 데이터를 통해 컨텐츠 조정할 수 있어요"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⤮ 추천해요!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let rankStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10 // rankStackView.spacing과 동일
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 60, height: 50) // 레이블 높이와 동일
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OnBoardingPriorityCollectionViewCell.self, forCellWithReuseIdentifier: OnBoardingPriorityCollectionViewCell.identifier)
        collectionView.backgroundColor = .gray200
        collectionView.contentInset = .zero // 추가 패딩 없도록 설정
        return collectionView
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("↓ 달 줍줍해요", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음으로 ➔", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let subjects = BehaviorRelay<[String]>(value: [
        "운영체제",
        "자료구조",
        "알고리즘",
        "네트워크",
        "데이터베이스"
    ])
    
    private var snapshot: UIView? // 드래그 중인 셀의 스냅샷
    private var sourceIndexPath: IndexPath? // 드래그 시작 위치
    private var isDragging: Bool = false
    private var originalPosition: CGPoint = .zero
    private let config = DragDropConfig()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRankLabels()
        bind()
        setupLongPressGesture()
        collectionView.contentOffset = .zero
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .gray200
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(shuffleButton)
        view.addSubview(rankStackView)
        view.addSubview(collectionView)
        view.addSubview(downloadButton)
        view.addSubview(nextButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        shuffleButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        // rankStackView와 collectionView의 상단을 정확히 맞춤
        rankStackView.snp.makeConstraints { make in
            make.top.equalTo(shuffleButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(shuffleButton.snp.bottom).offset(20) // rankStackView와 동일한 상단 오프셋
            make.left.equalTo(rankStackView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(downloadButton.snp.top).offset(-20)
        }
        
        downloadButton.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func setupRankLabels() {
        rankStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 1...subjects.value.count {
            let label = UILabel()
            label.text = "\(i)"
            label.font = UIFont(name: "DOSGothic", size: 16)
            label.textColor = .gray900
            label.textAlignment = .center
            // 레이블 높이를 collectionView 셀 높이에 맞춤
            label.snp.makeConstraints { make in
                make.height.equalTo(50) // collectionView itemSize.height와 동일
            }
            rankStackView.addArrangedSubview(label)
        }
        // 스택 뷰 간격을 collectionView의 minimumLineSpacing과 맞춤
        rankStackView.spacing = 10
    }
    
    // MARK: - Bind RxSwift
    private func bind() {
        subjects
            .bind(to: collectionView.rx.items(cellIdentifier: OnBoardingPriorityCollectionViewCell.identifier, cellType: OnBoardingPriorityCollectionViewCell.self)) { (row, element, cell) in
                cell.configure(subject: element)
                cell.backgroundColor = .white
            }
            .disposed(by: disposeBag)
        
        shuffleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let shuffled = self.subjects.value.shuffled()
                self.subjects.accept(shuffled)
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: {
                print("다음으로 버튼이 눌렸습니다.")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup Long Press Gesture
    private func setupLongPressGesture() {
        collectionView.rx.longPressGesture(configuration: { [weak self] gesture, delegate in
            gesture.minimumPressDuration = self?.config.longPressMinimumPressDuration ?? 0.2
        })
        .subscribe(onNext: { [weak self] gesture in
            guard let self = self else { return }
            let location = gesture.location(in: self.collectionView)
            
            switch gesture.state {
            case .began:
                self.handleBegan(location: location)
            case .changed:
                self.handleChanged(location: location)
            case .ended, .cancelled:
                self.handleEnded()
            default:
                break
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func handleBegan(location: CGPoint) {
        guard !isDragging, let indexPath = collectionView.indexPathForItem(at: location) else { return }
        isDragging = true
        didBeginDrag()
        
        sourceIndexPath = indexPath
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        snapshot = cell.snapshotView(afterScreenUpdates: true)
        snapshot?.frame = cell.frame
        collectionView.addSubview(snapshot!)
        
        cell.alpha = 0
        originalPosition = location
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction]) {
            self.animateBeganDragEffect()
        }
    }
    
    private func animateBeganDragEffect() {
        let scale = CGAffineTransform(scaleX: config.dargViewScale, y: config.dargViewScale)
        let translation = CGAffineTransform(translationX: 0, y: config.dragBeganEffectOffsetY)
        snapshot?.transform = scale.concatenating(translation)
        snapshot?.alpha = config.temporaryViewAlpha
        
        collectionView.visibleCells
            .filter { $0 != collectionView.cellForItem(at: sourceIndexPath!) }
            .forEach { $0.transform = CGAffineTransform(scaleX: config.otherViewsScale, y: config.otherViewsScale) }
    }
    
    private func handleChanged(location: CGPoint) {
        guard let snapshot = snapshot, let sourceIndexPath = sourceIndexPath else { return }
        
        let yOffset = location.y - originalPosition.y
        let translation = CGAffineTransform(translationX: 0, y: yOffset)
        let scale = CGAffineTransform(scaleX: config.dargViewScale, y: config.dargViewScale)
        snapshot.transform = scale.concatenating(translation)
        
        let maxY = snapshot.frame.maxY
        let midY = snapshot.frame.midY
        let minY = snapshot.frame.minY
        
        if let newIndexPath = collectionView.indexPathForItem(at: location), newIndexPath != sourceIndexPath {
            let inUpDirection = newIndexPath.item < sourceIndexPath.item
            dargging(inUpDirection: inUpDirection, maxY: maxY, minY: minY)
            
            var updatedSubjects = subjects.value
            let subject = updatedSubjects.remove(at: sourceIndexPath.item)
            updatedSubjects.insert(subject, at: newIndexPath.item)
            subjects.accept(updatedSubjects)
            
            collectionView.moveItem(at: sourceIndexPath, to: newIndexPath)
            self.sourceIndexPath = newIndexPath
        }
    }
    
    private func handleEnded() {
        guard let snapshot = snapshot, let sourceIndexPath = sourceIndexPath else { return }
        guard let cell = collectionView.cellForItem(at: sourceIndexPath) else {
            snapshot.removeFromSuperview()
            collectionView.visibleCells.forEach { $0.alpha = 1; $0.transform = .identity }
            isDragging = false
            didEndDrop()
            return
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction]) {
            snapshot.transform = .identity
            snapshot.frame = cell.frame
            snapshot.alpha = 1.0
            
            self.collectionView.visibleCells.forEach { $0.transform = .identity }
        } completion: { _ in
            cell.alpha = 1
            snapshot.removeFromSuperview()
            self.snapshot = nil
            self.sourceIndexPath = nil
            self.isDragging = false
            self.didEndDrop()
        }
    }
    
    // MARK: - DragDropStackViewDelegate
    func didBeginDrag() {
        // 드래그 시작 시 추가 로직이 필요하면 여기에
    }
    
    func dargging(inUpDirection up: Bool, maxY: CGFloat, minY: CGFloat) {
        // 드래그 중 방향에 따른 추가 로직이 필요하면 여기에
    }
    
    func didEndDrop() {
        // 드롭 종료 시 추가 로직이 필요하면 여기에
    }
}
