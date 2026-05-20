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

## 사용 예시

### SDK 메인 화면 실행

```swift
import PointCUSDK

let vc = PointCUSDK.makeMainViewController(
    userId:         "user_id_here",
    birth:          "1990-01-01",   // 또는 age: 35
    gender:         .male,
    finishDelegate: self
)
vc.modalPresentationStyle = .fullScreen
present(vc, animated: true)
```

### 게임 단독 실행

```swift
// 등록 여부 확인 후 실행
if PointCUSDK.isRegistered() {
    PointCUSDK.startGameRoulette(delegate: self)
    PointCUSDK.startGameLottery(delegate: self)
}
```

### CU 자체 광고

```swift
PointCUSDK.startPoint4uAdvertise(
    type:       .eat,
    delegate:   self,
    onComplete: { print("완료") },
    onFail:     { print("실패") }
)
```

---

## 문의

point4udevelop@adwon.co
