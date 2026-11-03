# ToggleMaster

Plataforma de feature flags dividida em 5 microsserviços, rodando localmente com Docker Compose e na AWS com Amazon EKS. Projeto do Tech Challenge Fase 2 (POSTECH DevOps).

| Serviço | Stack | Porta | Dados | Rota no Ingress |
|---|---|---|---|---|
| `auth-service` | Go | 8001 | PostgreSQL | `/auth/*` |
| `flag-service` | Python | 8002 | PostgreSQL | `/flags*` |
| `targeting-service` | Python | 8003 | PostgreSQL | `/rules*` |
| `evaluation-service` | Go | 8004 | Redis + SQS (produtor) | `/evaluate` |
| `analytics-service` | Python | 8005 | SQS (consumidor) + DynamoDB | `/analytics/*` |

## Estrutura

```
services/                 código e Dockerfile de cada serviço
docker-compose.yml        ambiente local
infra/eksctl-cluster.yaml definição do cluster EKS
infra/iam/                policies IAM dos serviços (IRSA)
infra/helm/               values do AWS Load Balancer Controller, ingress-nginx e KEDA
infra/k8s/                manifestos Kubernetes de cada serviço
```

## Rodando localmente

Pré-requisitos: Docker e Docker Compose.

```bash
docker compose up --build -d
docker compose ps
```

Sobem 10 contêineres: os 5 serviços, 3 PostgreSQL (um por serviço), Redis e DynamoDB Local. O schema dos bancos é criado na primeira subida, e o `auth-service` já vem com a chave `tm_key_local_dev`, usada pelo `evaluation-service` para chamar os outros serviços. As senhas do `docker-compose.yml` são só para uso local.

Testando o fluxo:

```bash
# cria uma chave de API (MASTER_KEY local: admin-secreto-123)
curl -X POST http://localhost:8001/admin/keys \
  -H "Authorization: Bearer admin-secreto-123" \
  -H "Content-Type: application/json" \
  -d '{"name": "teste"}'

export KEY=<chave retornada>

# cria uma flag e uma regra de 50%
curl -X POST http://localhost:8002/flags -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "novo-checkout", "description": "Novo checkout", "is_enabled": true}'

curl -X POST http://localhost:8003/rules -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"flag_name": "novo-checkout", "is_enabled": true, "rules": {"type": "PERCENTAGE", "value": 50}}'

# avalia a flag para um usuário
curl "http://localhost:8004/evaluate?user_id=user-123&flag_name=novo-checkout"
```

Para parar: `docker compose down` (ou `docker compose down -v` para apagar os dados).