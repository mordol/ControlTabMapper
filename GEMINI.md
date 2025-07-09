MacOS용 프로그램 ‘ControlTabMapper ‘을 Swift를 사용하여 개발했습니다.

이 프로그램은 상단 바에 상주하면서 다음 일련의 동작을 수행할 수 있습니다.
- Control + tab 키 입력을 발생시킵니다.
- Control 키 입력은 유지(pressed)하고 tab 입력은 바로 해지됩니다.
- 키보드의 esc 입력이 발생하면 Control 키 입력도 해지됩니다.
- Mouse 모든 button 입력은 정상적으로 focus 된 program에 전달되어 처리되고 이후 esc key event를 발생시켜 esc에 대한 처리와 control 키 입력 해지도 진행됩니다.

그리고 다음 기능을 포함합니다.
- 설정에서 윈도우가 있는 실행중인 프로그램 목록을 보여주고 특정 프로그램을 선택할 수 있습니다.
- 선택된 프로그램이 focus 된 상태에서만 키입력 event 동작을 수행합니다.
- 다른 프로그램에서 ControlTabMapper의 키입력 event 동작을 trigger할 수 있습니다. (예를 들어 mouse button 3 입력이 발생하면 ControlTabMapper를 trigger하는 LinearMouse 같은 서드파티앱)

이 프로젝트를 개발하기 위한 단계를 sequential thinking을 사용해 계획하고 수행하세요.
Swift와 기타 필요한 library들은 contex7을 사용해 최신 API를 적용하세요.
각 진행 단계 마다 동작 확인 후 문제가 없으면 git commit 해주세요.

  사용 방법:
   1. 앱이 실행되면 상단 메뉴 막대에 키보드 아이콘이 나타납니다.
   2. 아이콘을 클릭하고 "Settings..."를 선택하여 설정 창을 엽니다.
   3. 설정 창에서 Control+Tab 기능을 활성화할 프로그램을 선택합니다.
   4. 선택한 프로그램으로 전환하면 Control+Tab 기능이 활성화됩니다.
   5. 마우스 버튼을 클릭하거나 ESC 키를 누르면 눌려있던 Control 키가 해제됩니다.
   6. 다른 앱(예: LinearMouse)에서 controltabmapper://trigger URL을 호출하면 Control+Tab 이벤트가 발생합니다.


