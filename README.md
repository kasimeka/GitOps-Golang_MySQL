# go-serve gitops deployment

- [go-serve gitops deployment](#go-serve-gitops-deployment)
    - [Challenge rubric](#challenge-rubric)
        - [Main criteria](#main-criteria)
        - [Bonus criteria](#bonus-criteria)
    - [Deployment instructions](#deployment-instructions)
        - [Prerequisites](#prerequisites)
        - [ArgoCD application deployment](#argocd-application-deployment)
            - [Adding the repo to argocd](#adding-the-repo-to-argocd)
            - [Creating sealed secrets for the application](#creating-sealed-secrets-for-the-application)
            - [Deploying the application](#deploying-the-application)
            - [Accessing the application](#accessing-the-application)

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
| Fix a bug in the code that would appear when you test the api | yes | [commit (diff)](https://github.com/janw4ld/go-serve/commit/2156557abdb8eacd93cbc4dbdbf0c557391e1758), [bugfix demo script](./bugfix-demo.sh), [the script's output](./README.d/app-demo.png) |
| Secure your containers as much as you can. | subjective |  |

## Deployment instructions
### Prerequisites

- On client prerequisites:
    - [docker](https://docs.docker.com/get-docker/)
    - [helm](https://helm.sh/)
    - [kubeseal](https://github.com/bitnami-labs/sealed-secrets#kubeseal)
    - [argocd cli](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

- In-cluster prerequisites:
    - [SealedSecrets](https://artifacthub.io/packages/helm/bitnami-labs/sealed-secrets/2.9.0?modal=install)
    - [argocd](https://argo-cd.readthedocs.io/en/stable/)
    - [metrics-server](https://artifacthub.io/packages/helm/metrics-server/metrics-server/3.10.0?modal=install)
    - [haproxy](https://artifacthub.io/packages/helm/haproxytech/haproxy/1.19.0?modal=install)

- Machine independent prerequisites:
    - A [Jenkins](https://www.jenkins.io/doc/) server with docker installed.

<!--TODO for detailed instructions on prerequisite installation see [here]() -->

<!--TODO ### Docker compose usage -->

<!--TODO ### CI pipeline/image build -->

### ArgoCD application deployment

#### Adding the repo to argocd

- create a github personal access token for argocd following [this guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token), a fine-grained token with only "read contents" permission for `janw4ld/go-serve` is recommended.

- add the repo to argocd cli

    ```console
    $ argocd repo add https://github.com/janw4ld/go-serve.git \
      --username <your-github-username> \
      --password <your-personal-access-token>
    Repository 'https://github.com/janw4ld/go-serve' added
    ```

#### Creating sealed secrets for the application

NOTE: sealed secrets are encrypted using a public key unique to each cluster,
with a scope limited to the namespace the sealed secret is created in and the
exact name of the secret. This means that the secrets created in this example
will only work in the cluster they were created by, and you'll have to generate
new ones for your cluster for `./application.yml` to deploy successfully.

- Make sure your kubectl context is set to the cluster you're deploying to.
- Generate raw sealed values for the database secrets using the following script

    ```bash
    new_sealed_value() {
    openssl rand -base64 24 \
    | kubeseal --raw --name db-secret \
        -n default # change default to the namespace you're deploying to
    } # random 32 character alphanumeric passwords with 205 bits of entropy
    cat <<EOF
    sealed:
    MYSQL_PASS: $(new_sealed_value)
    MYSQL_ROOT_PASSWORD: $(new_sealed_value)
    MYSQL_REPLICATION_PASSWORD: $(new_sealed_value)
    EOF
    ```

    output:

    ```yaml
    sealed:
      MYSQL_PASS: AgDF1IzWqfpzbeX3suUXU8entdd7h0aRWn5jpFMaUvboZhZDaFHR5F0Vt2jQ33Pz1DcAtaf1QnYUeYkSBD786DLgr6MF50IFMN+26oS1kRdTlhZvA2wyG6P1oPyeBMmjsmDTp+VilfBnELq1z2ZAad3pNbffMsIJnwaJs9NC3oy+fDr3vSUvJQmLmABt+Xo9i7pgtv5db6yGC3O0HoMNExAXPOlboCNnflUdJStqCjYM6jhNkTDTwwui1EENQ4cQJ8ycUxZWg3JGdllbLq8p2UwXrQh5ZSWZW+GKp7gTjC+ck8ZEUZIQWvNAVhJTgRNxIyuEUPrgEBvPRV6deChcQ/8328LbBM+Tx0V7Tm9leJv1+IeP6lzEhHvombJO1S25s2643cz2b/HhKEwXDE7INr+BV8KX0kAnahgeL+k29X8IgUvnTI45C/2IAaIS1BV+kau3WzYDoxh5U0IHi8EQ7CzeCrpTzl/gjp+rSWocquVqNFyQk90aLaCqgWFsrqW8N5a80fWj6X6EyyLosQL2vPqZ/C2zzERBS/zWM81eTWlvp38jh2Si4Iw1Abp2QPdLiyAVIYJ5qavN/yZgIkE0pXDYWXrb1A6YODyGtMe78iH5WRmSKsx8a5VJkMoQ+u9emuYTA3gSVZnRGA86hxZTHpn27cDhsTSjJ4KdKxG631C2ClKFd9itXnXp3clgCiQRNd1jVxYUEHsqAm4twcC6EeNjWLkbg3JNTAPDUmlc1aO7
      MYSQL_ROOT_PASSWORD: AgCjij1oH3rR5Kl74Npp4AzfyBaYyb9Me7auzVRM23NiBSHURAnYcWxpQpiT5eyytVz/MP9+qJIjThHuNA2n6lJFEsl3lAdwD4n/sQBP4ueXuHZzJeVLuBnD7HnttnSi1tjXi2S48Z2ZoowDstE+VHQQruFFEJvKq4fBisNcEKPPjHNED4pUf+aZ03gQRXiU9z1ZLeFG4Ms4xIP5nbDBrXo5YX1A/YhsAQQyvflPchoZxdzFlRRgX9ysIfr4G5SC5SqqkS9IOQyViD29U0r8hZtV1j9GvX6XHaqrgtYJw5hDgb5MJCYZrSQbOpraSYOrZbWfvgCU1dcVEmiJetpCPhdiP2/zOASNhwaXLJeDaMN27G6lzHwlu+OKA0lyWikfVn+Vkue4Zoc1CF3n+JPiiUhU/uBjowNF7WiauIdZbK0Yq4Xj/r47HXvGesqATpdifpvawcQ6CmCA2cgeVWrcM5GXLSUfTzMQlEqEZzXULkZqTa/2dzyAuO8GauVIwLZ5HrPOCoKaWGtJ7yDUh1VKtNb0X+o11Uam4fr0HMhHlW5cKwR/ENYxzxhMfnCQG+7WKFfOjF2CL8ADLt2fMlq+OWJW6FsZoEQeKJonxrVVQh85xPEoTZxgE0tFLPpbwvCRNxTcXgGvSt5zOzcSZUmlKbYGdwzfW/psuBhcpA3470hLX7JFjl0zyMgllxv+mtpLHggpHuPNS/XEB47IjRekKg1AlAmvG15+duK9TVa5AWLg
      MYSQL_REPLICATION_PASSWORD: AgC9s0Me6rRKrZPcrl10qKpm3h9J7Lfv/SUYWh2iwuEQq4qqWsM19zgez8ih8P5sECr/EjVxiMD9tiatUpxzunPNamTOy9u3siaseecYPn/5s3pgomirB3cBOrNPfysw+je7Hk8VCGyoRWt4Aq0K04BiGHEslfsCHp86TqL38pTRwS93SCdDXl2kmsY7NFbYeQDtt4r0pIHmVQ/5b0agfdVe+zNdX3v0R4accGQ9UAEJFhjdQom7ish3tcevmQp2AnLJicVpo8OiEE2PY3G2IcafhA1EhD2tWsEpC34alydW/1PUFXnpjniC5EnsoxU6+dKuCqFUvFhnVsVGqpXC/1Z6A3puJnJKnf+O7fl69GnCU8UKnYqjt4eqycup7aEGVnxlPPIP+mB54IyCwmeBVlPZQYBzBMsnYa+wMRz8oBBGNsLAPvhRXHCGHvcicVE4sPDtbwOlEdWplId4KsNLL2dsUcSeR7CavSZC7eZH4/UJ55b4y4S7BParF8lP6BpcjVi0jus2e423S2pMumPF/Y2A9VafJ4EHm05A+N1yFNaWg6+G73Xq4oC0mnNwQwSOn6Wtn3g70ry1YRBkV2JaEYA5kDF6GQrE47JtZVRzsM+AER7S0D6nsVf3cFa1jIvt90VdtX9JKELGw05jSJo+7lfyMKPBhuZ78xlJvDDiO7gXBSz3JvUECkXFAXtj/gO1fBnhZddeT9FA/rN2WYlktouPcVkBf48vr1qJli1jd74l
    ```

- replace `.spec.helm.values` in [`application.yml`](./application.yml) by the
previous script's output and make sure to indent it correctly

    OR:

    you can manually insert your passwords instead of generating them by echoing
    each password into kubeseal as follows:

    ```console
    $ echo -n strongandcomplicatedpassword \
    > | kubeseal --raw --name db-secret -n default
    AgChrx5sEUTnnYlD4VMn4089BF/J4Qbu1egFJp7xL7LJnW7Q9cWQwPhbBqqEncyjB0cFAwb9cHgPzQIWm2WhHuSPbFmIQlLTeCaffyfO3v+2TCYu8OUJHatbOoryeP7DGoMxLm9XaBL8DMqawS1DYDw5kitw/QC82citUt/WMTnuXsDTkSx0pkM5b/1ZFoo9U//gix8d2gsrPHQdIaASx4eVPU0g5dQ+9oVCGfvW6Vv9FAkcIDPUy2T8wfgIDTVGW9l+Z7FX3X21jX+Bu5U5CBmSms5niDCiQTnKy2j6h2bkRXDlnm2/HJUwLVqmGLgYZwY2zRqVCHBhqgLg7pFx+IPjpNLtNMxNlIUIXQegvbeAaMLB+wWUvjBNZURZ0JtPa0zLt0DuHjIiTAgH3+5SPFwtHihclcNMt5kZfRPTn8XFfEcCq3QION9eUG4YeYBEQLYqArvNWhpHixTIm/lTBUyJcWJAUrM2qCwnSgZPAWJHAayQ36kXtBwHBJntipyne2u9c8EZwGlztcEl0UWqB/bWFOiZ+3nZDAkfxY7hZOFvAvQGLINvL5mqL0ruzHEf9nZq0OXwVUKv3Lb8e1XsOMCNCuktW0CN8uNciCB1Ie/90TADZC0h6BZLM1NCk23pSGyiOgSE1oYIjG0c8gfPgrRnQUwuuoUhihXM/rRTH1NuIivFLZOOvVxl+C6gOGYrw7UGtumxcr52fR60DY1MXZVJGxgenPpnoToGM7CQ
    ```

    then copying the password into [`application.yml`](./application.yml)`:.spec.helm.values.sealed`

#### Deploying the application

- Switch default kubectl namespace to argocd (it's required by argocd cli)

    ```console
    $ kubectl config set-context --current --namespace=argocd
    Context "kubernetes-admin@kubernetes" modified.
    ```

- Apply the application manifest

    ```console
    $ kubectl apply -f application.yml \
    > && sleep 120 \
    > && kubectl -n default get po -l app.kubernetes.io/instance=go-serve
    NAME                        READY   STATUS    RESTARTS      AGE
    go-serve-764b749495-dk4vv   1/1     Running   1 (60s ago)   2m
    go-serve-764b749495-l6k77   1/1     Running   1 (45s ago)   105s
    go-serve-764b749495-rjq4k   1/1     Running   1 (45s ago)   105s
    go-serve-db-primary-0       1/1     Running   0             2m
    go-serve-db-secondary-0     1/1     Running   0             2m
    go-serve-db-secondary-1     1/1     Running   0             46s
    ```

<sup>
The restart is okay because the server doesn't wait for the database and
crashes, and crashes and restarts (instead of init containers) are the most
k8s-ish way of waiting for readiness.
</sup>

#### Accessing the application

- Get the application's ingress hostname and the ingress controller's IP address

    ```console
    $ kubectl -n default get ingresses go-serve \
    > && kubectl -n default get svc ingress-haproxy-ingress
    NAME       CLASS     HOSTS            ADDRESS   PORTS   AGE
    go-serve   haproxy   go-serve.local             80      5m
    NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
    ingress-haproxy-ingress   LoadBalancer   10.109.177.189   192.168.1.241   80:31446/TCP,443:30612/TCP   32h
    ```

    This means that the application is accessible at `go-server.local/api`, but
    note that the external IP address `192.168.1.241` is assigned automatically
    by the cluster's load balancer, and the hostname `go-server.local` is
    declared in the chart's values and should be overridden in application.yml
    to match the domain name pointing to our ingress controller.

    Since this is an on-premise demo with no DNS, we can either add the hostname
    to `/etc/hosts` by running `echo go-server.local | sudo tee -a /etc/hosts`
    or send our requests to the ingress controller at `192.168.1.241` with the
    `Host` header set to `go-server.local`

- Send requests to the application  

    <sup>
    note that the /healthcheck endpoint is not exposed outside of the cluster in
    the chart's default ingress config, but this can be overridden in
    application.yml too
    </sup>

    ```console
    $ curl -w '\n' -H 'Host: go-serve.local' 192.168.1.241/api 
    null
    $ curl -X POST -w '\n' -H 'Host: go-serve.local' 192.168.1.241/api
    OK
    $ curl -w '\n' -H 'Host: go-serve.local' 192.168.1.241/api
    [{"createdAt":"2023-06-13T15:35:53Z","id":1}]
    ```

    [output screenshot](./README.d/app-screenshot.png)
