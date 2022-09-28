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
                to = as.Date("2021-04-30"),
                by = "1 month")

datelist <- format(datelist, format = "%Y%m") # 형식 변환 (YYYYMM)
datelist[1:3] # 확인


## 인증키 입력
service_key <- "GVCXnGY72se2aTAOiqSxXYyEvUkbJSNsACPi12nR5O%2F6HCcsJH%2B5FHYfTeVq4Agjej5SmOtqV9vegkjkJO%2FSwA%3D%3D"


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
install.packages("XML")
install.packages("data.table")
install.packages("stringr")

library(XML)
library(data.table)
library(stringr)

raw_data <- list() # xml 임시 저장소
root_Node <- list() # 거래내역 추출 임시 저장소
total <- list() # 거래내역 정리 임시 저장소
dir.create("02_raw_data") # 새로운 폴더 만들기

## 자료 요청하고 응답받기
for (i in 1 : length(url_list)) { # 요청 목록 (url_list) 반복
  raw_data[[i]] <- xmlTreeParse(url_list, useInternalNode = TRUE,
    encoding = "utf-8" # 결과 저장
  )
  root_Node[[i]] <- xmlRoot(raw_data[[i]]) # xmlRoot로 루트 노드 이하 추출


  ## 전체 거래 건수 확인하기
  items <- root_Node[[i]][[2]][["items"]] # 전체 거래 내역(items) 추출
  size <- xmlSize(items) # 전체 거래 건수 확인

  ## 거래 내역 추출
  item <- list() # 전체 거래 내역 (items) 저장 임시 리스트 생성
  item_temp_dt <- data.table() # 세부 거래 내역 (item) 저장 임시 테이블 생성
  Sys.sleep(.1)  # 0.1초 멈춤
  for (m in 1:size) { # 전체 거래 건수 (size)만큼 반복
    # 세부 거래 내역 분리
      item_temp <- xmlSApply(items[[m]], xmlValue)
      item_temp_dt <- data.table(
      year = item_temp[4], # 거래 연도
      month = item_temp[7], # 거래 월
      day = item_temp[8], # 거래 일
      price = item_temp[1], # 거래 금액
      code = item_temp[12], # 지역코드
      dong_nm = item_temp[5], # 법정동
      jibun = item_temp[11], # 지번
      con_year = item_temp[3], # 건축 연도
      apt_nm = item_temp[6], # 아파트 이름
      area = item_temp[9], # 전용면적
      floor = item_temp[13] # 층수
    )
    item[[m]] <- item_temp_dt # 분리된 거래 내역 순서대로 저장
  }
  apt_bind <- rbindlist(item) # 통합 저장

  ## 응답 내역 저장하기
  region_nm <- subset(loc, code == str_sub(url_list[i], 115, 119))$addr_1 # 지역명
  month <- str_sub(url_list[i], 130, 135) # 연월
  path <- as.character(paste0("./02_raw_data", region_nm, "_", month, ".csv"))
  write.csv(apt_bind, path)
  msg <- paste("[", i, "/", length(url_list),
    "] 수집한 데이터를 [", path,"]에 저장합니다.")
  cat(msg, "\n\n")
}

## csv 파일 통합
setwd(dirname(rstudioapi::getSourceEditorContext()$path))  # 작업폴더 설정
files <- dir("./02_raw_data")    # 폴더 내 모든 파일 이름 읽기
library(plyr)               # install.packages("plyr")
apt_price <- ldply(as.list(paste0("./02_raw_data/", files)), read.csv) # 모든 파일 하나로 결합
tail(apt_price, 2)  # 확인

## 저장
dir.create("./03_integrated")   # 새로운 폴더 생성
save(apt_price, file = "./03_integrated/03_apt_price.rdata") # 저장
write.csv(apt_price, "./03_integrated/03_apt_price.csv")
