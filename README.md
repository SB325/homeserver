# HOMESERVER 
This repository contains the deployment of several services that support data management and workflows throughout my projects.

### Services:
| Service   |      Purpose      |  Currently Operational  |
|----------|:-------------:|------:|
| proxy |  NGINX Reverse Proxy | :heavy_check_mark: |
| telemetry |    Observability   |   :heavy_check_mark: |
| jenkins | CICD Pipelines |     |
| invokeai | AI Image Generator | :heavy_check_mark:   |
|   kafka    |   Pub-Sub Data Logger    |   :heavy_check_mark:  |
|   redis    |   In-Memory Cache    |   :heavy_check_mark:    |
|   spark    |   Scaled Data Processor    |       |
|   registry    |   local container registry    |   :heavy_check_mark:    |
|   neo4j    |   Graph Database/Triplestore    |   :heavy_check_mark:    |
|   minio    |   S3 Bucket Store    |          |
|    milvus   |   Vector Database    |   :heavy_check_mark:    |
|    ollama   |   Open Source LLM Framework   |   :heavy_check_mark:    |
|    postgres   |   SQL Database  |  :heavy_check_mark:   |
|    pgadmin   |   Postgres Administration GUI   |   :heavy_check_mark:  |

When the intent is to run applications like `SEC EDGAR ETL` (a.k.a. Market Reader), you'll want to run postgres, kafka, redis, and optionally, pgadmin, telemetry, and proxy.
