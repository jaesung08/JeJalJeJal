# ![Alt text](</assets/제잘제잘 로고.png>)

**제주도 말을 잘 이해하고 제주도 말을 잘 소통하자**

## 서비스 개요
본 프로젝트는 경남119센터의 AI 음성인식 신고 접수 서비스를 통해 사투리의 언어적 장벽을 허물고, 더 빠르고 정확한 소통으로 출동 지연을 개선한 사례에서 영감을 받았습니다. 이 프로젝트는 사투리 중 특히 이해하기 어려운 제주도 사투리를 통역하는 제주어 AI 통역 시스템을 개발하여, 제주도민과의 의사소통 정확성을 높이고자 합니다. 이를 통해 콜센터 및 신고센터 등에서 향상된 의사소통 기능을 지원하는 것을 목표로 합니다.


## 목차
1. [**소개 영상**](#1)
2. [**서비스 화면**](#2)
3. [**주요 기능 소개**](#3)
4. [**프로젝트 기간**](#4)
5. [**주요 기술 스택**](#5)
6. [**프로젝트 산출물**](#6)
7. [**개발 멤버 소개**](#7)

<div id="1"></div>

## 소개 영상
**UCC 소개 영상 보러가기(링크넣기)**

<div id="2"></div>

## 서비스 화면
### 메인 페이지(전화 통역)

### 메인 페이지(파일 통역)

### 전화 통역 기록 상세 페이지

### 파일 통역 결과 페이지

<div id="3"></div>

## 주요 기능

### 1. 제주방언 통화 실시간 통역
- **내용**: 제주방언 통화를 실시간으로 녹음하고 번역합니다.
- **기능 과정**: 
  1. 실시간 녹음 파일 전송
  2. 손상된 녹음 파일 복원 (metadata 복원)
  3. 복원된 음성 파일을 텍스트로 변환 (STT)
  4. 텍스트 내 제주방언 번역
  5. 번역된 텍스트를 클라이언트에게 전송
  6. 유저에게 번역된 텍스트 표시
- **사용 기술**:
  - **Untrunc**: 손상된 음원 파일 복원
    - FFmpeg를 활용하여 손상된 m4a 파일을 복원
    - 참조 파일을 기반으로 메타데이터와 파일 구조를 복원
  - **Clova Speech**: 음성 파일을 텍스트로 변환 (STT)
    - 복원된 음원 파일을 텍스트로 변환
    - 제주도 방언 인식을 위해 키워드 부스팅 적용
  - **Clova Studio**: 텍스트 내 제주방언 번역 (AI 모델)
    - 제주 사투리를 표준어로 번역
    - 한국어 학습에 최적화된 모델 사용

### 2. 제주방언 음성(녹음) 파일 통역
- **내용**: 통화 녹음 및 음성 파일 내 제주방언을 번역합니다.
- **기능 과정**:
  1. 음성 파일 전송
  2. 음성 파일을 텍스트로 변환 (STT)
  3. 텍스트 내 제주방언 번역
  4. 번역된 텍스트를 클라이언트에게 전송
  5. 유저에게 번역된 텍스트 표시
- **사용 기술**:
  - **Clova Speech**: 음성 파일을 텍스트로 변환 (STT)
    - 음성 파일을 텍스트로 변환
    - 제주도 방언 인식을 위해 키워드 부스팅 적용
  - **Clova Studio**: 텍스트 내 제주방언 번역 (AI 모델)
    - 제주 사투리를 표준어로 번역
    - 한국어 학습에 최적화된 모델 사용

## 부가 기능
- 최근 통역 통화한 연락처 표시
- 통화 및 파일 통역 내용 저장
- 통화 통역 ON/OFF 가능
- 위젯을 이용한 번역 창 간편 관리

## 기술 상세 설명

### Untrunc
- **개요**: Untrunc는 손상된 m4a 파일을 복원하기 위해 FFmpeg를 활용하는 기술입니다.
- **작동 원리**:
  1. 손상된 파일과 멀쩡한 참조 파일을 사용하여 손상된 파일의 메타데이터와 구조를 복원합니다.
  2. FFmpeg를 통해 복원된 파일을 생성합니다.
  3. 기준 시간만큼 복원 후 자연스러운 맥락을 위해 이전 파일의 마지막 일부분을 추가합니다.
- **복원 과정**:
  1. 참조 파일 분석
  2. 메타데이터 복원
  3. 파일 구조 재구성
  4. FFmpeg 사용
  5. 음성 파일 자연스럽게 구성
- **장점**: 효율성, 유연성, 신뢰성

### Clova Speech
- **개요**: Clova Speech는 음성 파일을 텍스트로 변환하는 STT(음성 인식) 기술입니다.
- **특징**:
  - Untrunc에서 복원된 음원 파일을 STT로 변환
  - 제주도 방언 인식을 위해 키워드 부스팅 적용
  - AI Hub 제주도방언 음성 데이터에서 추출한 상위 1000개의 단어를 키워드 부스팅에 사용

### Clova Studio
- **개요**: Clova Studio는 텍스트 내 제주 사투리를 표준어로 번역하는 AI 모델입니다.
- **특징**:
  - 한국어 학습에 최적화된 HCX-003 모델 사용
  - 제주 사투리를 표준어로 번역
  - 입력된 텍스트가 제주 사투리인지 표준어인지 구분하여 번역 또는 표준어로 처리


<div id="4"></div>

## 프로젝트 기간
### 24.04.08 ~ 24.05.17 (6주)
- 기획 및 설계 :  04.08 ~ 04.23
- 기능 구현 전 테스트 : 04.12 ~ 04.23
- 프로젝트 구현: 04.24 ~ 05.15
- 버그 수정 및 산출물 정리: 05.15 ~ 05.19

<div id="5"></div>

## 주요 기술 스택(개발환경)
 
| **카테고리**               | **기술**                                | **버전**          |
|----------------------------|-----------------------------------------|-------------------|
| **# IDE (통합 개발 환경)**    |                                         |                   |
|                            | ![Intellij IDEA](https://img.shields.io/badge/Intellij_IDEA-3776AB?style=for-the-badge&logo=IntellijIDEA&logoColor=white)                        | ![2023.3.3](https://img.shields.io/badge/2023.3.3-3776AB?style=for-the-badge&logo=none)          |
|                            | ![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=VisualStudioCode&logoColor=white)           | ![1.85.1](https://img.shields.io/badge/1.85.1-007ACC?style=for-the-badge&logo=none)            |
|                            | ![Android Studio](https://img.shields.io/badge/android_studio-34A853?style=for-the-badge&logo=androidstudio&logoColor=white)                | ![2023.3.1](https://img.shields.io/badge/2023.3.1-34A853?style=for-the-badge&logo=none)          |
| **# Backend**                |                                         |                   |
| - Untrunc (Flask)          |                                         |                   |
|                            | ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)                                  | ![3.7.5](https://img.shields.io/badge/3.7.5-3776AB?style=for-the-badge&logo=none)             |
|                            | ![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)                                   | ![2.2.5](https://img.shields.io/badge/2.2.5-000000?style=for-the-badge&logo=none)             |
|                            | ![Werkzeug](https://img.shields.io/badge/Werkzeug-581845?style=for-the-badge&logo=Werkzeug&logoColor=white)                                | ![2.2.3](https://img.shields.io/badge/2.2.3-581845?style=for-the-badge&logo=none)             |
|                            | ![Untrunc](https://img.shields.io/badge/untrunc-E61845?style=for-the-badge&logo=untrunc&logoColor=white) ![FFmpeg](https://img.shields.io/badge/FFmpeg-007808?style=for-the-badge&logo=FFmpeg&logoColor=white)                                 | ![3.3.9](https://img.shields.io/badge/3.3.9-E61845?style=for-the-badge&logo=none)             |
| - JeJal (Spring Boot)      |                                         |                   |
|                            | ![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=SpringBoot&logoColor=white)                            | ![3.2.5](https://img.shields.io/badge/3.2.5-6DB33F?style=for-the-badge&logo=none)             |
|                            | ![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)                                    | ![17.0.9](https://img.shields.io/badge/17.0.9-ED8B00?style=for-the-badge&logo=none)            |
|                            | ![Querydsl](https://img.shields.io/badge/Querydsl-352?style=for-the-badge&logo=Querydsl&logoColor=white)                                | ![5.0.0](https://img.shields.io/badge/5.0.0-352?style=for-the-badge&logo=none)             |
|                            | ![Spring Dependency Management](https://img.shields.io/badge/Spring_Dependency_Management-6DB33F?style=for-the-badge&logo=spring&logoColor=white)           | ![1.1.4](https://img.shields.io/badge/1.1.4-6DB33F?style=for-the-badge&logo=none)             |
| - Build Tools              |                                         |                   |
|                            | ![Gradle](https://img.shields.io/badge/Gradle-02303A.svg?style=for-the-badge&logo=Gradle&logoColor=white)                                  | ![8.7](https://img.shields.io/badge/8.7-02303A?style=for-the-badge&logo=none)              |
| - Database                 |                                         |                   |
|                            | ![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)                                 | ![10.3.3](https://img.shields.io/badge/10.3.3-003545?style=for-the-badge&logo=none)            |
| **# Frontend**               |                                         |                   |
|                            | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)                                 | ![3.19.6](https://img.shields.io/badge/3.19.6-02569B?style=for-the-badge&logo=none)            |
|                            | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)                                    | ![3.3.4](https://img.shields.io/badge/3.3.4-0175C2?style=for-the-badge&logo=none)            |
| - Tools                    |                                         |                   |
|                            | ![Flutter DevTools](https://img.shields.io/badge/Flutter_Devtools-02569B?style=for-the-badge&logo=flutter&logoColor=white)                       | ![2.31.1](https://img.shields.io/badge/2.31.1-02569B?style=for-the-badge&logo=none)            |
|                            | ![Kotlin](https://img.shields.io/badge/Kotlin-0095D5?style=for-the-badge&logo=kotlin&logoColor=white)                        |                   |
| **# Infra & Server**         |                                         |                   |
| - Operating System         |                                         |                   |
|                            | ![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)                                  | ![20.04.6](https://img.shields.io/badge/20.04.6-E95420?style=for-the-badge&logo=none)           |
|                            | ![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=NGINX&logoColor=white)                                 | ![1.18.0](https://img.shields.io/badge/1.18.0-009639?style=for-the-badge&logo=none)            |                               
|                            | ![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)                                 | ![2.456](https://img.shields.io/badge/2.456-D24939?style=for-the-badge&logo=none)             |
| - Containerization         |                                         |                   |
|                            | ![Docker](https://img.shields.io/badge/docker-0db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)                                  | ![26.1.0](https://img.shields.io/badge/26.1.0-0db7ed?style=for-the-badge&logo=none)            |
|                            | ![docker-compose](https://img.shields.io/badge/docker_compose-0db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)                         | ![1.29.2](https://img.shields.io/badge/1.29.2-0db7ed?style=for-the-badge&logo=none)            |
| **# Cooperation & Communication** |                                   |                   |
|                            | ![GitLab](https://img.shields.io/badge/gitlab-FC6D26?style=for-the-badge&logo=GitLab&logoColor=white)                                  |                   |
|                            | ![Jira](https://img.shields.io/badge/Jira-0052CC?style=for-the-badge&logo=Jira&logoColor=white)                                    |                   |
|                            | ![Mattermost](https://img.shields.io/badge/Mattermost-005123?style=for-the-badge&logo=Mattermost&logoColor=white)                             |                   |
|                            | ![Notion](https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=notion&logoColor=white)                                  |                   |




<div id="6"></div>

## 프로젝트 산출물
### 시스템 아키텍쳐
![아키텍쳐](</assets/제잘제잘 아키텍쳐.png>)
### ERD 다이어그램
![ERD](</assets/제잘제잘 ERD.png>)
- 좌) 서버 mariaDB 
- 우) 안드로이드 sqlite
### 와이어 프레임
![figma](</assets/제잘제잘 초기FIGMA.png>)
### API 문서
![API명세서](</assets/제잘제잘 api명세서.png>)
### 포팅 메뉴얼
- [포팅 메뉴얼 바로가기](/exec/포팅메뉴얼.md)

<div id="7"></div>

## 👨‍👩‍👧‍👦멤버 소개

<table>
    <tr>
        <td height="140px" align="center"> <a href="https://github.com/Cho-yool">
            <img src="./assets/image/ㅅㅎ.jpg" /> <br><br> 👑 조성호 <br>(Front-End) </a> <br></td>
        <td height="140px" align="center"> <a href="https://github.com/zoonghyun">
            <img src="./assets/image/ㅈㅎ.jpeg" /> <br><br> 박중현 <br>(Front-End) </a> <br></td>
        <td height="140px" align="center"> <a href="https://github.com/hjjj99">
            <img src="./assets/image/ㅎㅈ.jpeg" /> <br><br> 김현지 <br>(Front-End) </a> <br></td>
        <td height="140px" align="center"> <a href="https://github.com/so2043">
            <img src="./assets/image/ㅅㅇ.jpg" /> <br><br> 정소영 <br>(Back-End) </a> <br></td>
        <td height="140px" align="center"> <a href="https://github.com/jaesung08">
            <img src="./assets/image/ㅈㅅ.jpg" /> <br><br> 장재성 <br>(Back-End) </a> <br></td>
        <td height="140px" align="center"> <a href="https://github.com/leeejw00">
            <img src="./assets/image/ㅈㅇ.jpg" /> <br><br> 이지우 <br>(Back-End) </a> <br></td>
    </tr>
    <tr>
        <td align="center">작성 예정 <br/> 작성예정</td>
        <td align="center">작성 예정 <br/> 작성예정</td>
        <td align="center">작성 예정 <br/> 작성예정</td>
        <td align="center">작성 예정 <br/> 작성예정</td>
        <td align="center">작성 예정 <br/> 작성예정</td>
        <td align="center">작성 예정 <br/> 작성예정</td>
    </tr>
</table>