//
//  ViewController.swift
//  PointCUDemoSB
//
//  Created by Juno Yoon on 5/19/26.
//  PointCU SDK 스토리보드 데모앱 샘플 - 메인 뷰컨트롤러
//

import UIKit
import CoreMotion
import AppTrackingTransparency
import PointCU

class ViewController: UIViewController {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let titleLabel = UILabel()
    private let versionLabel = UILabel()
    private let userIdLabel = UILabel()
    private let divider1 = UIView()
    private let divider2 = UIView()
    private let divider3 = UIView()

    // 서버 환경 선택 (STG / AWS / 상용)
    private lazy var serverSegment: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["STG", "AWS", "상용"])
        seg.selectedSegmentIndex = 1  // 기본값: AWS
        seg.addTarget(self, action: #selector(onServerChanged), for: .valueChanged)
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    
    private lazy var btnStartSDK       = makeButton(title: "SDK START",            color: .systemBlue)
    private lazy var btnRoulette       = makeButton(title: "ROULETTE GAME",        color: .systemPurple)
    private lazy var btnLottery        = makeButton(title: "LOTTERY GAME",         color: .systemPurple)
    private lazy var btnAdEat          = makeButton(title: "CU광고 - 오늘뭐먹지",      color: .systemOrange)
    private lazy var btnAdInventory    = makeButton(title: "CU광고 - 재고조회",       color: .systemOrange)
    private lazy var btnAdNewProduct   = makeButton(title: "CU광고 - 신상품",        color: .systemOrange)
    private lazy var btnAdPreOrder     = makeButton(title: "CU광고 - 예약구매",       color: .systemOrange)
    private lazy var btnClearUserData  = makeButton(title: "사용자 데이터 삭제",       color: .systemRed)
    private lazy var btnGetSteps       = makeButton(title: "오늘 걸음수 조회",         color: .systemTeal)

    // 선택 가능한 userId 목록
    private let userIds = [
        "age_14_f", "age_15_m", "age_24_f", "age_25_m",
        "age_34_f", "age_35_m", "age_44_f", "age_45_m",
        "age_54_f", "age_55_m", "age_64_f", "age_65_m",
        "age_74_f", "age_75_m"
    ]
    private let userIdDefaultsKey = "PointCUDemo_SelectedUserId"
    private let serverTypeDefaultsKey = "PointCUDemo_DevServerType"
    
    // 0: STG, 1: AWS, 2: 상용
    private var savedServerIndex: Int {
        get {
            let saved = UserDefaults.standard.object(forKey: serverTypeDefaultsKey)
            return saved == nil ? 1 : UserDefaults.standard.integer(forKey: serverTypeDefaultsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: serverTypeDefaultsKey) }
    }

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
        let index = savedServerIndex
        serverSegment.selectedSegmentIndex = index
        applyServerType(index: index)
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
        
        // version 레이블
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        versionLabel.text           = "Verion \(version) B(\(build))"
        versionLabel.font           = .systemFont(ofSize: 12, weight: .medium)
        versionLabel.textAlignment  = .center

        // userId 레이블
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
        btnGetSteps.addTarget(self,      action: #selector(onGetStepCount),  for: .touchUpInside)

        // 구분선
        [divider1, divider2, divider3].forEach {
            $0.backgroundColor = .separator
            $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }

        // StackView 구성
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(versionLabel)
        
        stackView.addArrangedSubview(makeSectionLabel("서버 환경"))
        stackView.addArrangedSubview(serverSegment)
        serverSegment.heightAnchor.constraint(equalToConstant: 36).isActive = true
        stackView.setCustomSpacing(20, after: serverSegment)
        
        stackView.addArrangedSubview(makeSectionLabel("SDK 메인"))
        stackView.addArrangedSubview(btnStartSDK)
        stackView.setCustomSpacing(20, after: btnStartSDK)

        stackView.addArrangedSubview(userIdRowView)
        stackView.setCustomSpacing(20, after: userIdRowView)
        
        stackView.addArrangedSubview(btnGetSteps)
        stackView.setCustomSpacing(24, after: btnGetSteps)
        
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

    // MARK: - 서버 환경 적용

    private func applyServerType(index: Int) {
        switch index {
        case 0: PointCUSDK.setServerType(.stg)
        case 1: PointCUSDK.setServerType(.aws)
        case 2: PointCUSDK.setServerType(.prod)
        default: break
        }
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
        btn.titleLabel?.font   = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor    = color
        btn.layer.cornerRadius = 12
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
            age:            selectedAge,
            gender:         selectedGender,
            finishDelegate: self
        )
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // 2026.05.29 ADDED 걸음 수 연동 함수 추가
    @objc private func onGetStepCount() {
        guard PointCUSDK.isRegistered() else {
            showToast("회원가입 되지 않은 사용자 입니다.")
            return
        }
        
        PointCUSDK.getStepCount { steps in
            if steps == -1 {
                self.showToast("모션 권한 없음")
            } else {
                self.showToast("오늘 걸음수: \(steps)보")
            }
        }
    }
    
    @objc private func onServerChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        savedServerIndex = index
        applyServerType(index: index)
        // 서버 전환 시 토큰 초기화
        PointCUSDK.clearUserData()
        let names = ["STG", "AWS", "상용"]
        showToast("서버 환경: \(names[index]) (재인증 필요)")
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
        PointCUSDK.startPoint4uAdvertise(type: .eat, delegate: self)
    }

    // ──────────────────────────────────────────────────────────────
    // MARK: - CU 광고 뷰 (PointCUAdViewController 활용)
    // makeAdViewController 를 사용하면 광고 뷰만 제공받고
    // 테두리·닫기 버튼 등 컨테이너 UI는 메인앱에서 직접 구성합니다.
    // - adSize 생략 시 기본값 300×250 사용
    // - adSize 파라미터로 원하는 크기 지정 가능
    // ──────────────────────────────────────────────────────────────

    // 재고조회: addChild — 커스텀 팝업 컨테이너 안에 광고 뷰 삽입
    @objc private func onAdInventory() {
        let popup = AdCustomPopupViewController(type: .inventory)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle   = .crossDissolve
        present(popup, animated: true)
    }

    // 신상품: present (pageSheet) — 시트 형태로 간단하게 표시
    @objc private func onAdNewProduct() {
        let adVC = PointCUSDK.makeAdViewController(type: .newProduct, delegate: self)
            adVC.modalPresentationStyle = .pageSheet
            if let sheet = adVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
        }
        adVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        present(adVC, animated: true)
    }

    // 예약구매: UIView 직접 — 현재 화면 위에 인라인으로 광고 뷰 삽입
    private var inlineAdVC: PointCUAdViewController?

    @objc private func onAdPreOrder() {
        inlineAdVC?.willMove(toParent: nil)
        inlineAdVC?.view.removeFromSuperview()
        inlineAdVC?.removeFromParent()

        let adVC = PointCUSDK.makeAdViewController(type: .preOrder, delegate: self)
        inlineAdVC = adVC
        addChild(adVC)

        let adView = adVC.view!
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.layer.cornerRadius = 12
        adView.clipsToBounds = true
        view.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            adView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            adView.widthAnchor.constraint(equalToConstant: 300),
            adView.heightAnchor.constraint(equalToConstant: 250),
        ])
        adVC.didMove(toParent: self)

        // 닫기 버튼
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        closeBtn.layer.cornerRadius = 12
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            closeBtn.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            closeBtn.widthAnchor.constraint(equalToConstant: 24),
            closeBtn.heightAnchor.constraint(equalToConstant: 24),
        ])
        closeBtn.addTarget(self, action: #selector(dismissInlineAd), for: .touchUpInside)
    }

    @objc private func dismissInlineAd() {
        inlineAdVC?.willMove(toParent: nil)
        inlineAdVC?.view.removeFromSuperview()
        inlineAdVC?.removeFromParent()
        inlineAdVC = nil
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
        toast.text               = message
        toast.font               = .systemFont(ofSize: 14)
        toast.textColor          = .white
        toast.textAlignment      = .center
        toast.backgroundColor    = UIColor.black.withAlphaComponent(0.75)
        toast.layer.cornerRadius = 20
        toast.clipsToBounds      = true
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
        print("게임 오류 [\(error.code.rawValue)] \(error.message)")
    }
    func onGameComplete(winPoint: Int) {
        print("게임 완료 — \(winPoint)P 획득")
    }
    func onGameClose() {
        print("게임 종료")
    }
}

// MARK: - PointCUAdDelegate

extension ViewController: PointCUAdDelegate {
    func onAdShow(type: Point4uAd?) {
        // 광고 배너 로드 완료
        print("onAdShow")
    }
    func onAdFail(type: Point4uAd?, error: PointCUError) {
        // 광고 로드 실패
        print("onAdFail")
    }
    func onAdClose(type: Point4uAd?) {
        // 팝업 닫힘
        print("onAdClose")
    }
    func onAdEarned(type: Point4uAd?) {
        // 광고 페이지에 5초 이상 머물렀을 경우
        print("onAdEarned")
    }
    func onAdClick(type: Point4uAd?) {
        // 광고 배너 클릭
        print("onAdClick")
    }
}

// MARK: - PointCUAdViewDelegate (makeAdViewController 콜백)
// 신상품(present), 예약구매(UIView 직접) 방식에서 사용

extension ViewController: PointCUAdViewDelegate {
    func onAdLoaded() {
        print("[AdView] 광고 로드 성공")
    }
    func onAdFailed(error: PointCUError) {
        print("[AdView] 광고 실패: \(error.message)")
        dismissInlineAd()
    }
    func onAdClicked() {
        print("[AdView] 광고 클릭")
    }
    func onAdEarned() {
        print("[AdView] 이동 후 복귀 (5초 이상 체류)")
    }
    func onAdReturned() {
        print("[AdView] 이동 후 복귀 (5초 미만 체류)")
    }
}

// MARK: - PointCUFinishDelegate

extension ViewController: PointCUFinishDelegate {
    func onMoveInventory() {
        // SDK가 이미 dismiss 완료 후 호출됨
        // 재고조회 ViewController로 이동
        showToast("재고 조회로 이동합니다.")
    }
}

// MARK: - 재고조회 광고 커스텀 팝업 (addChild 방식 예시)
// SDK에서 제공하는 광고 뷰(PointCUAdViewController)를 addChild로 삽입하고
// 타이틀 바·닫기 버튼 등 팝업 UI는 메인앱에서 직접 구성한 예시입니다.

final class AdCustomPopupViewController: UIViewController {

    private let adType: Point4uAd
    private var adVC:   PointCUAdViewController?
    private var adContainerPlaceholder: UIView?

    init(type: Point4uAd) {
        self.adType = type
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupPopupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard adVC == nil, let placeholder = adContainerPlaceholder else { return }
        let adVC = PointCUSDK.makeAdViewController(type: adType, delegate: self)
        self.adVC = adVC
        addChild(adVC)
        adVC.view.translatesAutoresizingMaskIntoConstraints = false
        placeholder.addSubview(adVC.view)
        NSLayoutConstraint.activate([
            adVC.view.topAnchor.constraint(equalTo: placeholder.topAnchor),
            adVC.view.bottomAnchor.constraint(equalTo: placeholder.bottomAnchor),
            adVC.view.leadingAnchor.constraint(equalTo: placeholder.leadingAnchor),
            adVC.view.trailingAnchor.constraint(equalTo: placeholder.trailingAnchor),
        ])
        adVC.didMove(toParent: self)
    }

    private func setupPopupLayout() {
        // 팝업 컨테이너 — 메인앱에서 원하는 대로 디자인 가능
        let popupView = UIView()
        popupView.backgroundColor    = .white
        popupView.layer.cornerRadius = 16
        popupView.clipsToBounds      = true
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        // 상단 타이틀 바
        let titleBar = UIView()
        titleBar.backgroundColor = .systemBlue
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(titleBar)

        let titleLabel = UILabel()
        titleLabel.text      = "재고조회"
        titleLabel.textColor = .white
        titleLabel.font      = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleBar.addSubview(titleLabel)

        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        titleBar.addSubview(closeBtn)

        // 광고 뷰 placeholder — 실제 adVC는 viewDidAppear에서 addChild
        let placeholder = UIView()
        placeholder.backgroundColor = .white
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(placeholder)
        adContainerPlaceholder = placeholder

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 320),

            titleBar.topAnchor.constraint(equalTo: popupView.topAnchor),
            titleBar.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
            titleBar.trailingAnchor.constraint(equalTo: popupView.trailingAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 16),

            closeBtn.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            closeBtn.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -16),
            closeBtn.widthAnchor.constraint(equalToConstant: 36),
            closeBtn.heightAnchor.constraint(equalToConstant: 36),

            placeholder.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            placeholder.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 10),
            placeholder.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10),
            placeholder.heightAnchor.constraint(equalToConstant: 250),
            placeholder.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -10),
        ])
    }

    @objc private func closePopup() { dismiss(animated: true) }
}

extension AdCustomPopupViewController: PointCUAdViewDelegate {
    func onAdLoaded()                    { print("[AdPopup] 광고 로드 성공") }
    func onAdFailed(error: PointCUError) { dismiss(animated: true) }
    func onAdClicked()                   { print("[AdPopup] 광고 클릭") }
    func onAdEarned()                    { print("[AdPopup] 이동 후 복귀 (5초 이상 체류)") }
    func onAdReturned()                  { print("[AdPopup] 이동 후 복귀 (5초 미만 체류)") }
}
