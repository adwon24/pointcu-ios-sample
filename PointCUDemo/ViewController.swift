//
//  ViewController.swift
//  PointCUDemoSB
//
//  Created by Juno Yoon on 5/19/26.
//  PointCU SDK 스토리보드 데모앱 샘플 - 메인 뷰컨트롤러
//

import UIKit
import AppTrackingTransparency
import PointCU

class ViewController: UIViewController {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let titleLabel = UILabel()
    private let userIdLabel = UILabel()
    private let divider1 = UIView()
    private let divider2 = UIView()
    private let divider3 = UIView()

    // 버튼
    private lazy var btnStartSDK       = makeButton(title: "SDK START",            color: .systemBlue)
    private lazy var btnRoulette       = makeButton(title: "ROULETTE GAME",        color: .systemPurple)
    private lazy var btnLottery        = makeButton(title: "LOTTERY GAME",         color: .systemPurple)
    private lazy var btnAdEat          = makeButton(title: "CU광고 - 오늘뭐먹지",      color: .systemOrange)
    private lazy var btnAdInventory    = makeButton(title: "CU광고 - 재고조회",       color: .systemOrange)
    private lazy var btnAdNewProduct   = makeButton(title: "CU광고 - 신상품",        color: .systemOrange)
    private lazy var btnAdPreOrder     = makeButton(title: "CU광고 - 예약구매",       color: .systemOrange)
    private lazy var btnClearUserData  = makeButton(title: "사용자 데이터 삭제",       color: .systemRed)

    // 선택 가능한 userId 목록
    private let userIds = [
        "age_14_f", "age_15_m", "age_24_f", "age_25_m",
        "age_34_f", "age_35_m", "age_44_f", "age_45_m",
        "age_54_f", "age_55_m", "age_64_f", "age_65_m",
        "age_74_f", "age_75_m"
    ]
    private let userIdDefaultsKey = "PointCUDemo_SelectedUserId"

    private var selectedUserId: String {
        get { UserDefaults.standard.string(forKey: userIdDefaultsKey) ?? "age_14_f" }
        set { UserDefaults.standard.set(newValue, forKey: userIdDefaultsKey) }
    }

    /// userId에서 age 파싱 (age_{age}_{gender} 형태)
    private var selectedAge: Int? {
        let parts = selectedUserId.split(separator: "_")
        guard parts.count >= 2, let age = Int(parts[1]) else { return nil }
        return age
    }

    /// userId에서 gender 파싱 (f=female, m=male)
    private var selectedGender: PointCUGender {
        let parts = selectedUserId.split(separator: "_")
        guard parts.count >= 3 else { return .unknown }
        return parts[2] == "f" ? .female : .male
    }

    // USER ID 선택 버튼 + 현재 선택 레이블
    private lazy var userIdRowView: UIView = makeUserIdRow()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - ATT 권한 요청

    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateUserIdLabel()
            }
        }
    }

    // MARK: - UI 구성

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "PointCU SDK Demo"

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // StackView
        stackView.axis         = .vertical
        stackView.spacing      = 12
        stackView.alignment    = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])

        // 타이틀
        titleLabel.text          = "PointCU SDK"
        titleLabel.font          = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        // userId 레이블 — UserDefaults에서 복원한 값으로 초기 표시 (age/gender 파싱)
        userIdLabel.font      = .systemFont(ofSize: 14, weight: .medium)
        userIdLabel.textColor = .label
        updateUserIdLabel()

        // 버튼 액션 연결
        btnStartSDK.addTarget(self,      action: #selector(onStartSDK),      for: .touchUpInside)
        btnRoulette.addTarget(self,      action: #selector(onRoulette),      for: .touchUpInside)
        btnLottery.addTarget(self,       action: #selector(onLottery),       for: .touchUpInside)
        btnAdEat.addTarget(self,         action: #selector(onAdEat),         for: .touchUpInside)
        btnAdInventory.addTarget(self,   action: #selector(onAdInventory),   for: .touchUpInside)
        btnAdNewProduct.addTarget(self,  action: #selector(onAdNewProduct),  for: .touchUpInside)
        btnAdPreOrder.addTarget(self,    action: #selector(onAdPreOrder),    for: .touchUpInside)
        btnClearUserData.addTarget(self, action: #selector(onClearUserData), for: .touchUpInside)

        // 구분선
        [divider1, divider2, divider3].forEach {
            $0.backgroundColor = .separator
            $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }

        // StackView 구성
        stackView.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(makeSectionLabel("SDK 메인"))
        stackView.addArrangedSubview(btnStartSDK)
        stackView.setCustomSpacing(20, after: btnStartSDK)

        stackView.addArrangedSubview(userIdRowView)
        stackView.setCustomSpacing(24, after: userIdRowView)
        
        stackView.addArrangedSubview(divider1)
        stackView.setCustomSpacing(20, after: divider1)

        stackView.addArrangedSubview(makeSectionLabel("게임"))
        stackView.addArrangedSubview(makeHStack(btnRoulette, btnLottery))
        stackView.setCustomSpacing(20, after: stackView.arrangedSubviews.last!)

        stackView.addArrangedSubview(divider2)
        stackView.setCustomSpacing(20, after: divider2)

        stackView.addArrangedSubview(makeSectionLabel("CU 자체 광고"))
        stackView.addArrangedSubview(makeHStack(btnAdEat, btnAdInventory))
        stackView.addArrangedSubview(makeHStack(btnAdNewProduct, btnAdPreOrder))
        stackView.setCustomSpacing(20, after: stackView.arrangedSubviews.last!)

        stackView.addArrangedSubview(divider3)
        stackView.setCustomSpacing(20, after: divider3)

        stackView.addArrangedSubview(makeSectionLabel("계정"))
        stackView.addArrangedSubview(btnClearUserData)
    }

    private func updateUserIdLabel() {
        let age    = selectedAge.map { "\($0)세" } ?? "-"
        let gender = selectedGender == .male ? "남" : (selectedGender == .female ? "여" : "-")
        userIdLabel.text = "\(selectedUserId) (\(age) / \(gender))"
    }

    // MARK: - 팩토리

    // MARK: - USER ID 선택 행

    private func makeUserIdRow() -> UIView {
        let row = UIView()

        var config = UIButton.Configuration.filled()
        config.title = "USER ID"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemIndigo
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            return a
        }
        let btn = UIButton(configuration: config)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(onSelectUserId), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false

        userIdLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(btn)
        row.addSubview(userIdLabel)

        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            btn.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            btn.heightAnchor.constraint(equalToConstant: 36),

            userIdLabel.leadingAnchor.constraint(equalTo: btn.trailingAnchor, constant: 12),
            userIdLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            userIdLabel.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),

            row.heightAnchor.constraint(equalToConstant: 44),
        ])
        return row
    }

    @objc private func onSelectUserId() {
        let alert = UIAlertController(title: "USER ID 선택", message: nil, preferredStyle: .actionSheet)
        for uid in userIds {
            let action = UIAlertAction(title: uid, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selectedUserId = uid
                self.updateUserIdLabel()
                print("userId 선택 | id=\(uid) age=\(self.selectedAge.map { "\($0)세" } ?? "-") gender=\(self.selectedGender.rawValue)")
            }
            if uid == selectedUserId {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = userIdRowView
            popover.sourceRect = userIdRowView.bounds
        }
        present(alert, animated: true)
    }

    private func makeHStack(_ left: UIView, _ right: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [left, right])
        stack.axis         = .horizontal
        stack.spacing      = 12
        stack.alignment    = .fill
        stack.distribution = .fillEqually
        return stack
    }

    private func makeButton(title: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font    = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor     = color
        btn.layer.cornerRadius  = 12
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return btn
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text      = text
        label.font      = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    // MARK: - Actions

    @objc private func onStartSDK() {
        let vc = PointCUSDK.makeMainViewController(
            userId:         selectedUserId,
            age:            selectedAge,     // userId에서 자동 파싱 (age_{age}_{gender})
            gender:         selectedGender,  // userId에서 자동 파싱 (f=female, m=male)
            finishDelegate: self
        )
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func onRoulette() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        PointCUSDK.startGameRoulette()
    }

    @objc private func onLottery() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        PointCUSDK.startGameLottery()
    }

    @objc private func onAdEat() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        PointCUSDK.startPoint4uAdvertise(type: .eat,
            onComplete: { [weak self] in self?.showToast("광고 완료") },
            onFail:     { [weak self] in self?.showToast("광고 실패") }
        )
    }

    @objc private func onAdInventory() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        PointCUSDK.startPoint4uAdvertise(type: .inventory,
            onComplete: { [weak self] in self?.showToast("광고 완료") },
            onFail:     { [weak self] in self?.showToast("광고 실패") }
        )
    }

    @objc private func onAdNewProduct() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        PointCUSDK.startPoint4uAdvertise(type: .newProduct,
            onComplete: { [weak self] in self?.showToast("광고 완료") },
            onFail:     { [weak self] in self?.showToast("광고 실패") }
        )
    }

    @objc private func onAdPreOrder() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        PointCUSDK.startPoint4uAdvertise(type: .preOrder,
            onComplete: { [weak self] in self?.showToast("광고 완료") },
            onFail:     { [weak self] in self?.showToast("광고 실패") }
        )
    }

    @objc private func onClearUserData() {
        let alert = UIAlertController(
            title: "사용자 데이터 삭제",
            message: "로컬에 저장된 사용자 데이터를 삭제합니다.\n로그아웃 또는 계정 전환 시 사용합니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            PointCUSDK.clearUserData()
            self?.showToast("사용자 데이터가 삭제되었습니다.")
        })
        present(alert, animated: true)
    }

    // MARK: - Toast

    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text                = message
        toast.font                = .systemFont(ofSize: 14)
        toast.textColor           = .white
        toast.textAlignment       = .center
        toast.backgroundColor     = UIColor.black.withAlphaComponent(0.75)
        toast.layer.cornerRadius  = 20
        toast.clipsToBounds       = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            toast.heightAnchor.constraint(equalToConstant: 44),
        ])
        toast.layoutIfNeeded()
        toast.widthAnchor.constraint(greaterThanOrEqualToConstant: toast.intrinsicContentSize.width + 40).isActive = true

        UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut) {
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}


// MARK: - PointCUGameDelegate

extension ViewController: PointCUGameDelegate {
    func onGameLoadFail(error: PointCUError) {
        showToast("게임 오류 [\(error.code.rawValue)] \(error.message)")
    }
    func onGameComplete(winPoint: Int) {
        showToast("게임 완료 — \(winPoint)P 획득")
    }
    func onGameClose() { }
}

// MARK: - PointCUAdDelegate

extension ViewController: PointCUAdDelegate {
    func onAdShow(type: Point4uAd?)   { }
    func onAdFail(type: Point4uAd?, error: PointCUError) {
        showToast("광고 실패 [\(error.code.rawValue)] \(error.message)")
    }
    func onAdClose(type: Point4uAd?)  { }
    func onAdEarned(type: Point4uAd?) { showToast("광고 리워드 적립 완료") }
    func onAdClick(type: Point4uAd?)  { }
}

// MARK: - PointCUFinishDelegate

extension ViewController: PointCUFinishDelegate {
    func onMoveInventory() {
        // SDK가 이미 dismiss 완료 후 호출됨
        // 재고조회 ViewController로 이동
        showToast("재고 조회로 이동합니다.")
    }
}
