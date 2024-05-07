# Commit Convention

- Fix: 버그 수정
- Docs: 문서 수정 (Markdown, Image 등 문서를 생성 혹은 수정한 경우)
- Style: 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우 (logic 변경 X)
- Refactor: 코드 리팩토링
- Test: 테스트 코드, 리팩토링 테스트 코드 추가 (production code 변경 X)
- Chore: 빌드, 패키지 매니저 수정 등 (기타 모든 잡무)
- Rename: 파일 혹은 폴더명을 수정하거나 옮기는 작업만인 경우
- Design : 디자인(UI) 관련 수정
- Feat: 새로운 기능 추가
    - **ex) feat: getMemberInfo api**

# Branch Convention

- Jira issue 에서 브렌치 생성 클릭
- 이슈번호_{내용}
    - **ex) FE-member_api**
    - **ex) BE-member_api**