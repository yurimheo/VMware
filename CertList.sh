#!/bin/bash

echo "--------------------------------------------------------"
echo "  vCenter 인증서 요약 (이름, 생성일, 만료일)"
echo "--------------------------------------------------------"

# 헤더 출력
printf "%-30s %-30s %-30s\n" "이름" "생성일 (Not Before)" "만료일 (Not After)"
printf "%s\n" "-----------------------------------------------------------------------------------------------------

# 인증서 정보 추출
for store in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list | grep -v TRUSTED_ROOT_CRLS); do
    /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $store --text | \
    grep -E 'Alias|Not Before|Not After' | \
    awk '
        BEGIN {
            Alias = "";
            NB = "";
            NA = "";
        }
        /Alias/ {
            # Alias 값 추출
            Alias = $NF;
        }
        /Not Before/ {
            # 날짜와 시간만 추출: $3 (월) $4 (일) $6 (년)
            NB = $3 " " $4 " " $6;
        }
        /Not After/ {
            # 날짜와 시간만 추출: $3 (월) $4 (일) $6 (년)
            NA = $3 " " $4 " " $6;

            # 이름, 생성일, 만료일을 테이블 포맷으로 출력
            printf "%-30s %-30s %-30s\n", Alias, NB, NA;

            # 다음 항목을 위해 변수 초기화
            Alias = "";
            NB = "";
            NA = "";
        }
    '
done

echo "------------------------------------------------------------------------------------------------------"
