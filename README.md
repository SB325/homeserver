# HOMESERVER 
This repository contains the deployment of several services that support data management and workflows throughout my projects.

### Services:
| Service   |      Purpose      |  Currently Operational  |
|----------|:-------------:|------:|
|   proxy       |  NGINX Reverse Proxy  | :heavy_check_mark:    |
|   telemetry   |    Observability      |   :heavy_check_mark:  |
|   langsmith   |   Agent Observability Platform   |     |
|   kafka       |   Pub-Sub Data Logger    |   :heavy_check_mark:  |
|   redis       |   In-Memory Cache     |   :heavy_check_mark:    |
|   jenkins     |   CICD Pipelines              |                           |
|   registry    |   local container registry    |   :heavy_check_mark:      |
|   invokeai    | AI Image Generator | :heavy_check_mark:   |
|    ollama     |   Open Source LLM Framework   |   :heavy_check_mark:    |
|    triton     |   Triton Inference Server   |   :heavy_check_mark:    |
|  agentgateway  |  MCP/A2A Gateway Service |           |
|   spark    |   Scaled Data Processor    |       |
|   neo4j    |   Property Graph Database/ Triplestore    |   :heavy_check_mark:    |
|   minio    |   S3 Bucket Store    |          |
|    milvus   |   Vector Database    |   :heavy_check_mark:    |
|    postgres   |   SQL Database  |  :heavy_check_mark:   |
|    pgadmin   |   Postgres Administration GUI   |   :heavy_check_mark:  |
|    virtuoso   |   RDF Graph Database/ Triplestore   |    |

When the intent is to run applications like `SEC EDGAR ETL` (a.k.a. Market Reader), you'll want to run postgres, kafka, redis, pgadmin, telemetry, and proxy.
