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
- Automatyczne powoływanie instancji EC2 w chmurze AWS (app, monitoring, Jenkins controller, Jenkins agent).
- Konfiguracja sieci (VPC, Subnets, Internet Gateway).
- Zarządzanie bezpieczeństwem przez Security Groups (SSH ograniczone do jednego CIDR, HTTP/8080 dla appki, 8080 dla Jenkinsa, 3000 dla Grafany, 3100/9100 tylko między serwerami nawzajem - nigdy z internetu).
- Dynamiczne generowanie pliku `inventory.ini` dla Ansible (adresy publiczne i prywatne wszystkich 4 maszyn).

### 2. Zarządzanie Konfiguracją (Ansible)
- W pełni zautomatyzowany provisioning czystych maszyn Ubuntu.
- Instalacja i konfiguracja środowiska Docker oraz narzędzi systemowych.
- Automatyczne wdrożenie i konfiguracja serwera Jenkins (JCasC) + dedykowanego agenta budującego (SSH node).
- Bezpieczne przechowywanie i aplikowanie haseł (np. root dla MySQL, Grafana, Docker Hub, Discord) przy pomocy Ansible Vault (`ansible/group_vars/all.yml`).
- Baza MySQL na `app_server` jest stawiana raz, przy provisioningu, i żyje niezależnie od deployów appki (Jenkins tylko podmienia kontener appki, nigdy nie rusza bazy).

### 3. Potok CI/CD (Jenkinsfile)
- **Wyzwalanie automatyczne:** Integracja z GitHub Webhooks (reakcja na push do dowolnej gałęzi; deployment tylko dla `master`/`main`).
- **Budowanie (Build):** Kompilacja i testy paczki `.jar` za pomocą Mavena, na dedykowanym agencie Jenkinsa (nie na kontrolerze).
- **Konteneryzacja (Docker):** Budowanie obrazu aplikacji, tagowanie numerem buildu i wysyłanie do Docker Hub.
- **Wdrożenie (Deploy):** `docker compose pull app && docker compose up -d app` na `app_server` - zawsze ściąga i uruchamia dokładnie ten obraz, który pipeline przed chwilą zbudował, bez ruszania bazy danych.
- **Powiadomienia:** Automatyczne alerty o statusie potoku (sukces/porażka) na Discord.

### 4. Monitoring i logi
- **Prometheus** (na dedykowanym serwerze monitoringu) scrape'uje Node Exporter (`:9100`) ze wszystkich czterech maszyn - metryki systemowe (CPU, RAM, dysk) dla appki, Jenkinsa, agenta i samego serwera monitoringu.
- **Grafana** (`:3000`, publicznie dostępna) ma automatycznie skonfigurowane oba źródła danych (Prometheus + Loki) przez provisioning - nic nie trzeba klikać ręcznie po `terraform apply` + `ansible-playbook`.
- **Loki + Promtail**: Promtail działa jako kontener na `app_server`, `jenkins_server` i `jenkins_agent`, czyta logi wszystkich kontenerów Dockera i wysyła je do Loki na serwerze monitoringu - logi z całej infrastruktury widoczne w jednym miejscu w Grafanie.

---

## Jak uruchomić środowisko?

```bash
# 1. Infrastruktura (4 instancje EC2 + sieć + security groups)
terraform init
terraform apply

# 2. Sekrety (jednorazowo)
cd ansible
cp group_vars/all.yml.example group_vars/all.yml
nano group_vars/all.yml              # wypełnij prawdziwymi wartościami
ansible-vault encrypt group_vars/all.yml

# 3. Konfiguracja wszystkich czterech maszyn: Docker, Jenkins + JCasC + agent,
#    MySQL, Prometheus + Grafana + Loki, Promtail
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

Po zakończeniu:
- Jenkins: `http://<jenkins_public_ip>:8080` (login z `jenkins_admin_user`/`jenkins_admin_password`)
- Grafana: `http://<monitoring_public_ip>:3000` (login `admin` / `grafana_admin_password`)
- Appka (po pierwszym udanym pushu do `main`): `http://<app_public_ip>:8080`

Pierwszy deployment appki wymaga, żeby obraz już istniał na Docker Hub - pierwszy push do `main` go stworzy.