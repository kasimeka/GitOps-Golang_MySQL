# go-serve gitops deployment

- [go-serve gitops deployment](#go-serve-gitops-deployment)
    - [Challenge rubric](#challenge-rubric)
        - [Main criteria](#main-criteria)
        - [Bonus criteria](#bonus-criteria)
    - [Deployment instructions](#deployment-instructions)
        - [Prerequisites](#prerequisites)

## Challenge rubric

### Main criteria
| criterion | completed | artifacts |
|---|---|---|
| Dockerfile that build the app and try to make it as lightweight as you can. | yes | [Dockerfile](./Dockerfile) |
| Pipeline job (jenkinsfile) to build the app using dockerfile and reports if any errors happened in the build. The output of the build step should be a docker image pushed to dockerhub or any docker repo you want. | yes | [Jenkinsfile](./Jenkinsfile), [error notification](./README.d/jenkins-fail.png), [published docker image](https://hub.docker.com/r/janw4ld/go-serve/) |
| Docker compose file that contains both application and mysql database so you can run the app locally. | yes | [docker-compose.yml](./docker-compose.yml) |
| Helm manifests for kubernetes to deploy the app using them on kubernetes with adding config to support high availability and volume persistence and exposing service to the public (you can use minikube to test). | yes | [chart](./chart) |

---
### Bonus criteria
| criterion | completed | artifacts |
|---|---|---|
| Add autoscaling manifest for number of replicas. | yes | [hpa.yaml](./chart/templates/hpa.yaml) |
| Add argocd app that points to helm manifests to apply gitops concept. | yes | [application.yml](./application.yml) |
| Fix a bug in the code that would appear when you test the api | yes | [commit](https://github.com/janw4ld/go-serve/commit/2156557abdb8eacd93cbc4dbdbf0c557391e1758), [app demo](./README.d/app-demo.png) |
| Secure your containers as much as you can. | subjective |  |

## Deployment instructions
### Prerequisites

- Client prerequisites:
    - [docker](https://docs.docker.com/get-docker/)
    - [helm](https://helm.sh/)
    - [argocd cli](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

- On-cluster prerequisites:
    - [SealedSecrets](https://artifacthub.io/packages/helm/bitnami-labs/sealed-secrets/2.9.0?modal=install)
    - [metrics-server](https://artifacthub.io/packages/helm/metrics-server/metrics-server/3.10.0?modal=install)
    - [haproxy](https://artifacthub.io/packages/helm/haproxytech/haproxy/1.19.0?modal=install)
    - [argocd](https://argo-cd.readthedocs.io/en/stable/)

<!--TODO for detailed instructions on prerequisite installation see [here]() -->
