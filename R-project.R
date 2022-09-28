## 작업 폴더 설정하기
install.packages("rstudioapi") # RstudioApi 설치
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) # 작업 폴더 설정
getwd() # 작업 폴더 확인


## 수집 대상 지역 설정하기
loc <- read.csv("./sampleData/01_code/sigun_code/sigun_code.csv", # 지역 코드
        fileEncoding = "UTF-8")
loc$code <- as.character(loc$code) # 행정구역명 문자 변환
head(loc, 2) # 확인

## 수집 기간 설정
datelist <- seq(from = as.Date("2021-01-01"),
                to = as.Date("2021-12-31"),
                by = "1 month")


datelist <- format(datalist, format = "%Y%m") # 형식 변환 (YYYYMM)
datelist[1:3] # 확인


## 인증키 입력
service_key <- "GVCXnGY72se2aTAOiqSxXYyEvUkbJSNsACPi12nR5O%2F6HCcsJH%2B5FHYfTeVq4Agjej5SmOtqV9vegkjkJO%2FSwA%3D%3D" # nolint 


# 요청 목록 생성
url_list <- list()

# 반복문의 제어 변수 초깃값 설정
cnt <- 0

# 요청 목록 채우기
for (i in 1:nrow(loc)) {
  for (j in 1:length(datelist)) {
    cnt <- cnt + 1
    url_list[cnt] <- paste0("http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?", #nolint
      "LAWD_CD=", loc[i, 1],
      "&DEAL_YMD=", datelist[j],
      "&numOfRows=", 100,
      "&serviceKey=", service_key)
  }
  Sys.sleep(0.1)
  msg <- paste0("[", i, "/", nrow(loc), "] ", loc[i,3], " 의 크롤링 목록이 생성됨 => 총 [ ", cnt, "] 건") #nolint
  cat(msg, "\n\n")
}

length(url_list) # 요청 목록 개수 확인
browseURL(paste0(url_list[1])) # 정상 동작 확인 (웹 브라우저 실행)

## 임시 저장 리스트 생성
# install.packages("XML")
# install.packages("data.table")
# install.packages("stringr")

library(XML)
library(data.table)
library(stringr)

raw_data <- list() # xml 임시 저장소
root_Node <- list() # 거래내역 추출 임시 저장소
total <- list() # 거래내역 정리 임시 저장소
dir.create("02_raw_data") # 새로운 폴더 만들기
