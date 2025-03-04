# Cosmo
![cover](https://github.com/user-attachments/assets/40c84f67-d401-4e9a-9fa6-ac0ff94da732)  

## 📷 Previews  

<p align="left">
<img src="https://github.com/user-attachments/assets/9c70082d-382e-4bdd-93be-e94f00b6811c" alt="drawing" width="200px" />
</p>

## ⚙️ Troubleshooting  

### AI 최적화  
### 1. 응답 요청 -> UI 노출까지 소요되는 시간 개선  

초기 단계에선 '응답 요청부터 UI 노출'까지 '21s'가 소요되었습니다. 소요 시간을 단축하기 위해 다음과 같은 AI 최적화 방법을 적용하고 있습니다.  

- **문제 요청 분할**: N문제를 한 번에 요청하지 않고, n문제씩 나누어 요청 (예: 3, 3, 4).  
- **요청 데이터 최소화**: (질문 + 답변 + 해설) 대신 (질문 + 답변)만 요청.  
- **답변 포맷화**: 미리 정의된 포맷을 요청 (프롬프트 엔지니어링).  
- **실시간 UI 노출**: AI의 응답 스크립트 스트림을 실시간 UI 노출.  

위 방법을 통해 '응답 요청 -> UI 노출'까지 소요되는 시간을 약 '16s' 단축했습니다.

### 2. AI에 대한 신뢰성 개선  

AI가 제공하는 질문 및 답변에 대한 신뢰성을 보장하기 위해 다음과 같은 방법을 적용하고 있습니다.  

- **공신력 있는 데이터 학습**: CS 면접 대비 저서, star +1000개 CS 면접 질문 아카이빙 레포지토리 학습 (파인튜닝).  
- **질문 생성 위임**: 비교적 간단한 질문은 AI에게 생성 위임(객관식), 어려운 질문은 학습된 데이터를 활용 (주관식).  
- **크로스체킹**: 2가지 버전의 AI를 제공하여 상호 검증 (예: GPT, Claude).  

#### Cosmo는 앞으로도 AI 최적화를 지속적으로 개선하여, 더 빠르고 신뢰성 높은 서비스를 제공할 계획입니다. 🚀  

## 🛠 Tech Stack & Libraries 

## ⭐️ Did you find this repository helpful?  
- 소중한 STAR(⭐️) 감사합니다 :)  

## ✨ Contributors  

## 🏆 Academic Achievements & Paper Publication
- 본 프로젝트 관련 연구가 [**한국통신학회**](https://conf.kics.or.kr/2025w)에 공식 게재되었습니다.  
- 📑 **논문 제목:** "AI 기반 전공 지식 학습 지원 서비스 설계 및 구현"    
- 🔢 **논문 번호:** 19B-P-36    
- 📚 **게재 학회/저널:** 한국통신학회 2025년도 동계종합학술발표회   
- 🔗 [**논문 링크**](https://conf.kics.or.kr/2025w/program?q=19B-P-36#program)
