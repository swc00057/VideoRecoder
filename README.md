# ios-wanted-VideoRecorder

<table>
    <tr align="center">
        <td><B>휘양(신동원)<B></td>
        <td><B>dahee(홍다희)<B></td>
    </tr>
    <tr align="center">
        <td width= 170px>
            <img src="https://user-images.githubusercontent.com/33388081/194698936-8386e827-4021-4909-84a5-953e5382ba27.jpeg" width="60%">
        </td>
        <td width= 170px>
            <img src="https://github.com/betterhee.png" width="60%">
        </td>
    </tr>
</table>



## 역할 분담 및 앱에서 기여한 부분

### 휘양

- 녹화 영상 화면
  - 영상 녹화 뷰 디자인
  - AVFoundation을 활용한 영상 녹화 기능 구현
  - 앨범버튼 및 카메라 position변경 기능 구현
- 녹화 영상 목록 화면
  - 영상 5초 미리 보기 재생 구현
- 영상 재생 화면
  - 커스텀 비디오 뷰 

### dahee

- 녹화 영상 목록 화면
  -   테이블뷰 디자인 및 레이아웃 구현 
  -   테이블뷰 Swipe Action 구현
  -   테이블뷰 Context Menu 구현
  -   Pagination 구현
- 영상 재생 화면
    - 선택된 영상을 보여주는 뷰와 영상 컨트롤러 구현 (AVPlayerViewController 활용)



## 뷰 구성 정보 및 기능

| Pagination                                                   | Delete <br />(Swipe Action)                                  | Preview <br />(Context Menu)                                 | Record                                                       | Play                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="https://user-images.githubusercontent.com/36187265/195813169-c00a9cec-17a7-49da-88d4-ce03e2bf6143.gif" alt="pagination" width="100"/> | <img src="https://user-images.githubusercontent.com/36187265/195813282-0db673d7-4cd2-4b23-9df4-3705c7303314.gif" alt="delete" width="100"/> | <img src="https://user-images.githubusercontent.com/36187265/195813542-fe4dc727-1f0a-42a9-be94-2eac0dd9ed67.gif" alt="preview" width="100"/> | <img src="https://user-images.githubusercontent.com/36187265/195817424-8ced6ff0-0f57-469a-8ef9-8f3d4493a5d2.gif" alt="record" width="100"/> | <img src="https://user-images.githubusercontent.com/36187265/195813617-5b1fc4c0-ff8e-49b4-ac92-13c02ee45ff5.gif" alt="play" width="100"/> |



## 프로젝트 후기 및 고찰

### 휘양

- AVFoundation
  - 처음 사용해보는 프레임워크 였는데, 간단한 구조와 달리 코드 자체는 간단하지 않았던 것 같다. 카메라 오디오 기능은 많은 앱에서 쉽게 접할수 있는 기능이기에 좀더 깊히 탐구해봐야 할 것 같다.
- PhotoKit
  - UIimagePickerController를 이용해 사진을 가져오는 것만 해보았었는데, PhotoKit은 기능을 잘 사용한다면 훨씬 더 고급 작업이 가능한 것 같다. 추후 나만의 완전한 새 앨범을 구성해보고 싶다.
- AVPlayer
  - 이번 프로젝트 최대의 난관 이었다. 영상 재생까지는 쉬울지 몰라도, 여러 기능을 넣을려니 쉽지 않았다. 이슈도 많이 발생하였는데 특히 AVPlayerViewController의 옵저버 관련 이슈가 생각난다. 특히 생명주기에 관련된 이슈였는데, 이건 나중에 블로그에 정리 해봐야 할 것 같다.

### dahee

- 녹화 영상 목록 화면

    - UITableViewDelegate 프로토콜을 사용하여 정말 다양한 기능을 관리할 수 있다는 것을 알 수 있었다. 앱 개발에 있어서 테이블뷰 사용 빈도가 높음에도 불구하고 Delegate 문서를 전반적으로 훑어보지 않고 그때 그때 필요한 기능만 찾아 구현했었다. 편의를 위해 이미 만들어진 기능이 있음에도 불구하고 알지 못해서 이를 잘 활용하지 못했었는데, 이번 프로젝트를 통해 관련 문서를 전반적으로 읽고 제공되는 메서드들에 대해 알게되어서 앞으로 테이블뷰를 더 잘 활용할 수 있겠다는 생각이 들었다. 
    - PHPhotoLibrary 권한을 요청하거나 앨범이 존재하는지 확인하고 앨범의 비디오들을 불러오는 코드들이 영상 녹화 화면에 중복되어 있는데 별도로 분리해서 중복 코드를 제거하도록 개선하면 좋을 것 같다. 

- 영상 재생 화면

    - ContainerViewController(VideoPlayerViewController)에서 AVPlayerViewController를 childViewController로 설정하도록 구현했는데 VideoPlayerViewController가 화면에서 사라질 때 아래와 같은 문제가 발생했었다.

        ```swift
        Cannot remove an observer <NSKeyValueObservance 0x2831ba430> for the key path \"currentItem.forwardPlaybackEndTime\" from <AVPlayer 0x283c82920>, 
        most likely because the value for the key \"currentItem\" has changed without an appropriate KVO notification being sent. 
        Check the KVO-compliance of the AVPlayer class."
        ```

    - VideoPlayerViewController가 화면에서 사라질 때 AVPlayerViewController가 내부적으로 등록한 Observer를 제거하지 않은채 뷰 계층에서 제거되어서 발생하는 문제인줄 알았으나 화면에서 사라질 때 Observer을 제거해주어도 계속해서 동일한 문제가 발생했다.

    - 결국 원인을 찾지 못해 커스텀 뷰에 AVPlayerLayer를 이용하는 방법으로 수정했는데, AVPlayerViewController의 AVPlayer가 deinit되지 않는 것까지 확인하고 추후 시간적 여유가 될때 메모리 할당에 대해 알아보고 원인을 알아봐야겠다.

