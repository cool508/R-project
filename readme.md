# R-project 2022
### 602277108배종범 

## 0921
<details>
<summary>요청 목록 생성</summary>

### 요청 목록 만들기
```R
url_list <- list() # 빈 리스트 생성됨
cnt <- 0 # 반복문 제어 변수 초기값 0
```

### 요청 목록 채우기
> 요청 목록(url_list)은 '프로토콜 + 주소 + 포트번호 + 리소스 경로 + 요청 내역' <br>
> 요청 내역은 대상 지역과 기간 조건에 따라 변동 ∴ 중첩 반복문 필요

```R
for(i in 1:nrow(loc)){          # 외부반복: 25개 자치구
  for(j in 1:length(datelist)){ # 내부반복: 12개월
    cnt <- cnt + 1              # 반복누적 카운팅
    
    # 요청 목록 채우기 (25*12=300)
    url_list[cnt] <- paste0("http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?",

        "LAWD_CD=", loc[i,1],       # 지역코드
        "&DEAL_YMD=", datelist[j],  # 수집월
        "&numOfRows=", 100,         # 한번에 가져올 최대 자료 수
        "&serviceKey=", service_key # 인증키
    )  
  } 
  Sys.sleep(0.1) # 0.1초간 멈춤
  # 알림메시지
  msg <- paste0("[", i,"/",nrow(loc), "]  ", loc[i,3], " 의 크롤링 목록이 생성됨 => 총 [", cnt,"] 건")
  cat(msg, "\n\n")
```

### 요청 목록 확인하기
```R
length(url_list)               # 요청목록 개수 확인
browseURL(paste0(url_list[1])) # 정상작동 확인
```
</details>
<details>
<summary>크롤러 제작</summary>

### 임시 저장 리스트 만들기
```R
# install.packages()는 설치 후 주석 처리 
install.packages("XML")
install.packages("data.table")
install.packages("stringr")

library(XML)
library(data.table)
library(stringr)
raw_data <- list()        # xml 임시 저장소
root_Node <- list()       # 거래내역 추출 임시 저장소
total <- list()           # 거래내역 정리 임시 저장소
dir.create("02_raw_data") # 새로운 폴더 만들기
```
</details>

## 0914
<details>
<summary>vscode 내 R 개발 환경 세팅</summary>
 
> vscode plugin : R Extension 설치

> 설정 > 확장 > R > Rpath: Windows(운영체제 확인 필요) > C:\Program file\R\R-4.2.1\bin\x64 입력
</details>

<details>
<summary>크롤링 준비</summary>

#### [실습파일 다운로드](https://drive.google.com/file/d/10Cvmme8oxQ9upMMnPwn07V9MXenYjKeD/view)

### 작업 폴더 설정
```R
install.packages("rstudioapi") # rstudioapi 설치                         
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) # 작업폴더 설정
getwd() # 확인
```

### 수집 대상 지역 설정하기
```R
loc <- read.csv("./sigun_code.csv", fileEncoding="UTF-8") # 지역코드
loc$code <- as.character(loc$code) # 행정구역명 문자 변환
head(loc, 2) # 확인
```

### 수집 기간 설정하기
```R
datelist <- seq(from = as.Date('2021-01-01'), # 시작
                to   = as.Date('2021-12-31'), # 종료
                by    = '1 month')            # 단위
datelist <- format(datelist, format = '%Y%m') # 형식변환(YYYY-MM-DD => YYYYMM) 
datelist[1:3]                                 # 확인
```

### 인증키 입력하기
```R
service_key <- "발급받은 인증키 입력"
```

</details>

## 0907
<details>
<summary>실거래자료 활용 신청</summary>

- [공공데이터포털](https://www.data.go.kr) 국토교통부_아파트매매 실거래자료 검색 및 신청
- 요청 메세지 확인
> http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?LAWD_CD=11110&DEAL_YMD=201512&serviceKey=서비스키

</details>

<details>
<summary>Text Mining</summary>

> 비정형 텍스트에서 의미있는 정보를 찾아내는 mining 기술
</details>

<details>
<summary>워드 클라우드</summary>

```R
installed.packages() # 설치된 패키지 확인
install.packages("wordcloud") # wordcloud 패키지 설치
# source 클릭 실행
```
</details>