# HOMESERVER 
This repository contains the deployment of several services that support data management and workflows throughout my projects.

### Services:
| Service   |      Purpose      |  Currently Operational  |
|----------|:-------------:|------:|
| proxy |  NGINX Reverse Proxy | - [x] |
| telemetry |    Observability   |   - [x] |
| jenkins | CICD Pipelines | - [ ] |
| invokeai | AI Image Generator | - [x]    |
|   kafka    |   Pub-Sub Data Logger    |   - [x]   |
|   redis    |   In-Memory Cache    |   - [x]    |
|   spark    |   Scaled Data Processor    |    - [ ]   |
|   registry    |   local container registry    |   - [x]    |
|   neo4j    |   Graph Database/Triplestore    |   - [x]    |
|   minio    |   S3 Bucket Store    |   - [ ]    |
|    milvus   |   Vector Database    |   - [x]    |
|    ollama   |   Open Source LLM Framework   |   - [x]    |
|    postgres   |   SQL Database  |   - [x]    |
|    pgadmin   |   Postgres Administration GUI   |   - [x]    |

When the intent is to run applications like `SEC EDGAR ETL` (a.k.a. Market Reader), you'll want to run postgres, kafka, redis, and optionally, pgadmin, telemetry, and proxy.