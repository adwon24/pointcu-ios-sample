# PointCU iOS SDK Sample

ADWON POINT4U 포켓CU 어플리케이션용 iOS SDK 샘플 프로젝트입니다.

SDK 저장소: https://github.com/adwon24/pointcu-ios

---

## 프로젝트 구성

| 파일 | 설명 |
|---|---|
| `AppDelegate.swift` | NAMSDK 초기화, GFPAdManagerDelegate 구현 |
| `ViewController.swift` | SDK 메인 화면 실행, 게임/광고 단독 실행 샘플 |
| `SceneDelegate.swift` | Scene 설정 |
| `Info.plist` | 권한 및 ATS 설정 |
| `Assets.xcassets/` | 앱 아이콘 및 이미지 리소스 |
| `LaunchScreen.storyboard` | 런치 스크린 |
| `PointCUDemo-Bridging-Header.h` | Objective-C 브릿지 헤더 |
| `NAMAdapter.h` | NAMAdapter 헤더 |
| `NAMAdapter.m` | NAMAdapter 구현 (keyWindow deprecated 수정 포함) |
| `GFPNativeSimpleAdView.xib` | NAM 네이티브 광고 뷰 레이아웃 |

---

## 설치 방법

### 1. 저장소 클론

```bash
git clone https://github.com/adwon24/pointcu-ios-sample.git
```

### 2. PointCUSDK 패키지 추가

```
Xcode → File → Add Package Dependencies
URL: https://github.com/adwon24/pointcu-ios.git
Dependency Rule: Range of Versions  0.0.1 ..< 3.0.0
Product: PointCUSDK → 타겟에 추가
```

### 3. NAMSDK 설치 (CocoaPods)

```ruby
# Podfile
target 'PointCUDemo' do
  pod 'NAMSDK'
end
```

```bash
pod install
```

### 4. NAMAdapter 파일 추가

`NAMAdapter/` 폴더의 파일들을 Xcode 프로젝트에 추가합니다.

```
NAMAdapter.h
NAMAdapter.m
GFPNativeSimpleAdView.xib
```

### 5. Bridging Header 설정

```
Build Settings → Swift Compiler - General
→ Objective-C Bridging Header
→ PointCUDemo/PointCUDemo-Bridging-Header.h
```

### 6. Build Settings 설정

| 설정 항목 | 값 |
|---|---|
| User Script Sandboxing | No |

---

## 샘플 화면 구성

| 섹션 | 버튼 | 설명 |
|---|---|---|
| 서버 환경 | STG / AWS / 상용 | 서버 환경 전환. 전환 시 토큰 초기화 |
| SDK 메인 | SDK START | SDK 메인 화면 실행 |
| SDK 메인 | USER ID | 테스트용 userId 선택 |
| SDK 메인 | 오늘 걸음수 조회 | 현재 걸음수 확인 |
| 게임 | ROULETTE / LOTTERY | 게임 단독 실행 |
| CU 자체 광고 | 오늘뭐먹지 | startPoint4uAdvertise 방식 (팝업) |
| CU 자체 광고 | 재고조회 | makeAdViewController — addChild 방식 |
| CU 자체 광고 | 신상품 | makeAdViewController — present(pageSheet) 방식 |
| CU 자체 광고 | 예약구매 | makeAdViewController — UIView 직접 삽입 방식 |
| 계정 | 사용자 데이터 삭제 | SDK 내부 사용자 데이터 초기화 |

---

## 사용 예시

### SDK 메인 화면 실행

```swift
let vc = PointCUSDK.makeMainViewController(
    userId:         "user_id_here",
    birth:          "1990-01-01",
    gender:         .male,
    finishDelegate: self
)
vc.modalPresentationStyle = .fullScreen
present(vc, animated: true)
```

### 걸음 수 확인

```swift
PointCUSDK.getStepCount { steps in
    if steps == -1 {
        self.showToast("모션 권한 없음")
    } else {
        self.showToast("오늘 걸음수: \(steps)보")
    }
}
```

### 게임 단독 실행

```swift
PointCUSDK.startGameRoulette(delegate: self)
PointCUSDK.startGameLottery(delegate: self)
```

### CU 자체 광고 — 팝업 방식 (오늘뭐먹지)

```swift
PointCUSDK.startPoint4uAdvertise(type: .eat, delegate: self)
```

---

## CU 자체 광고 — 뷰 단독 제공 방식 (makeAdViewController)

SDK는 **300×250 광고 뷰만** 제공합니다.  
테두리, 닫기 버튼 등 컨테이너 UI는 메인앱에서 직접 구성합니다.  
샘플에서는 재고조회 / 신상품 / 예약구매 각각 다른 방식으로 구현되어 있습니다.

### 방식 1: addChild — 재고조회

메인앱에서 커스텀 팝업 컨테이너(타이틀바 + 닫기 버튼)를 구성하고,  
SDK 광고 뷰를 내부에 `addChild`로 삽입하는 방식입니다.

```swift
// ViewController.swift
@objc private func onAdInventory() {
    let popup = AdCustomPopupViewController(type: .inventory)
    popup.modalPresentationStyle = .overFullScreen
    popup.modalTransitionStyle   = .crossDissolve
    present(popup, animated: true)
}
```

```swift
// AdCustomPopupViewController — 파일 하단에 포함
final class AdCustomPopupViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // viewDidAppear 이후 addChild 호출 (광고 로드 보장)
        let adVC = PointCUSDK.makeAdViewController(type: adType, delegate: self)
        addChild(adVC)
        adVC.view.frame = placeholder.bounds
        placeholder.addSubview(adVC.view)
        adVC.didMove(toParent: self)
    }
}

extension AdCustomPopupViewController: PointCUAdViewDelegate {
    func onAdLoaded()                    { /* 광고 표시 완료 */ }
    func onAdFailed(error: PointCUError) { dismiss(animated: true) }
    func onAdClicked()                   { /* 클릭 */ }
    func onAdEarned()                    { /* 5초 이상 체류 → 리워드 처리 */ }
    func onAdReturned()                  { /* 5초 미만 복귀 */ }
}
```

> ※ `addChild`는 반드시 `viewDidAppear` 이후에 호출해야 광고 로드가 정상 동작합니다.

---

### 방식 2: present (pageSheet) — 신상품

시트 형태로 간단하게 표시합니다.  
`PointCUAdViewController` 자체를 `present`로 띄웁니다.

```swift
@objc private func onAdNewProduct() {
    let adVC = PointCUSDK.makeAdViewController(type: .newProduct, delegate: self)
    adVC.modalPresentationStyle = .pageSheet
    if let sheet = adVC.sheetPresentationController {
        sheet.detents = [.medium()]
        sheet.prefersGrabberVisible = true
    }
    present(adVC, animated: true)
}
```

```swift
// PointCUAdViewDelegate
extension ViewController: PointCUAdViewDelegate {
    func onAdLoaded()                    { print("[AdView] 광고 로드 성공") }
    func onAdFailed(error: PointCUError) { /* 실패 처리 */ }
    func onAdClicked()                   { print("[AdView] 광고 클릭") }
    func onAdEarned()                    { print("[AdView] 5초 이상 체류 → 리워드 처리") }
    func onAdEarned()                    { print("[AdView] 5초 미만 복귀") }
}
```

---

### 방식 3: UIView 직접 삽입 — 예약구매

현재 화면 뷰 계층에 인라인으로 삽입합니다.  
닫기 버튼을 직접 추가하여 원하는 위치에 배치할 수 있습니다.

```swift
private var inlineAdVC: PointCUAdViewController?

@objc private func onAdPreOrder() {
    // 기존 광고 뷰 제거
    inlineAdVC?.willMove(toParent: nil)
    inlineAdVC?.view.removeFromSuperview()
    inlineAdVC?.removeFromParent()

    let adVC = PointCUSDK.makeAdViewController(type: .preOrder, delegate: self)
    inlineAdVC = adVC
    addChild(adVC)

    let adView = adVC.view!
    adView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(adView)
    NSLayoutConstraint.activate([
        adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        adView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        adView.widthAnchor.constraint(equalToConstant: 300),
        adView.heightAnchor.constraint(equalToConstant: 250),
    ])
    adVC.didMove(toParent: self)

    // 닫기 버튼 (메인앱에서 직접 구성)
    let closeBtn = UIButton(type: .system)
    closeBtn.setTitle("✕", for: .normal)
    closeBtn.addTarget(self, action: #selector(dismissInlineAd), for: .touchUpInside)
    adView.addSubview(closeBtn)
}

@objc private func dismissInlineAd() {
    inlineAdVC?.willMove(toParent: nil)
    inlineAdVC?.view.removeFromSuperview()
    inlineAdVC?.removeFromParent()
    inlineAdVC = nil
}
```

---

### 서버 환경 전환

```swift
PointCUSDK.setServerType(.stg)   // 개발 서버 1
PointCUSDK.setServerType(.aws)   // 개발 서버 2 (기본값)
PointCUSDK.setServerType(.prod)  // 상용 서버
```

서버 전환 시 기존 세션이 초기화됩니다. `clearUserData()`를 함께 호출하여 재인증을 진행합니다.

```swift
PointCUSDK.setServerType(.prod)
PointCUSDK.clearUserData()
```

---

## 문의

point4udevelop@adwon.co