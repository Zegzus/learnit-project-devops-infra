# Dokumentacja projektu DevOps

Projekt prezentuje pełen cykl życia oprogramowania z wykorzystaniem nowoczesnych praktyk DevOps, automatyzacji infrastruktury (IaC), zarządzania konfiguracją oraz potoków CI/CD.

## Architektura Projektu

Projekt został podzielony na dwa niezależne repozytoria, co zapewnia czysty podział obowiązków między kodem aplikacji a definicją infrastruktury:

1. **`learnit-project-devops-app` (Repozytorium Aplikacji)**
   - Zawiera sourcecode aplikacji backendowej (Java / Spring Boot).
   - Definiuje środowisko kontenerowe (`Dockerfile`, `docker-compose.yml`).
   - Przechowuje pipeline (`Jenkinsfile`).

2. **`learnit-project-devops-infra` (Repozytorium Infrastruktury)**
   - Definiuje zasoby chmurowe AWS jako kod za pomocą narzędzia Terraform.
   - Zawiera playbooki i role Ansible do automatycznej konfiguracji serwerów.
   - Zarządza tajnymi zmiennymi (np. hasła do baz danych) przy użyciu Ansible Vault.

---

## Techstack

* **Cloud:** AWS
* **Infrastruktura jako Kod (IaC):** Terraform
* **Zarządzanie konfiguracją:** Ansible, Ansible Vault (przechowywanie sekretów/tokenów/haseł)
* **CI/CD:** Jenkins (Configuration as Code - JCasC)
* **Konteneryzacja:** Docker, Docker Compose
* **Rejestr obrazów:** Docker Hub
* **Aplikacja:** Java, Spring Boot, Maven
* **Baza Danych:** MySQL 8.0
* **Powiadomienia:** Discord Webhooks

---

## Zrealizowane Funkcjonalności (Obecny Status)

### 1. Automatyzacja Infrastruktury (Terraform)
- Automatyczne powoływanie instancji EC2 w chmurze AWS.
- Konfiguracja sieci (VPC, Subnets, Internet Gateway).
- Zarządzanie bezpieczeństwem przez Security Groups (otwarte porty SSH, HTTP, Jenkins).
- Dynamiczne generowanie pliku `inventory.ini` dla Ansible.

### 2. Zarządzanie Konfiguracją (Ansible)
- W pełni zautomatyzowany provisioning czystych maszyn Ubuntu.
- Instalacja i konfiguracja środowiska Docker oraz narzędzi systemowych.
- Automatyczne wdrożenie i konfiguracja serwera Jenkins (JCasC).
- Bezpieczne przechowywanie i aplikowanie haseł (np. root dla MySQL) przy pomocy Ansible Vault.

### 3. Potok CI/CD (Jenkinsfile)
- **Wyzwalanie automatyczne:** Integracja z GitHub Webhooks (reakcja na push do gałęzi `master`/`main`).
- **Budowanie (Build):** Kompilacja i budowanie paczki `.jar` za pomocą narzędzia Maven.
- **Konteneryzacja (Docker):** Budowanie obrazu aplikacji, tagowanie numerem buildu i wysyłanie do publicznego rejestru Docker Hub.
- **Wdrożenie (Deploy):** Bezpieczne połączenie SSH z serwerem produkcyjnym w AWS, transfer pliku `docker-compose.yml` oraz bezprzerwowe uruchomienie kontenerów (aplikacja + baza MySQL).
- **Powiadomienia:** Automatyczne wysyłanie alertów o statusie potoku (Sukces/Porażka) na dedykowany kanał Discord.

---

## Jak uruchomić środowisko?

-- todo 