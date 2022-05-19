# Deploying tutorial

## Preapre the repository

1. Clone: `git clone https://gitlab.com/ocmoxa/ocmoxa.com`.
2. Open it in VS code: `code ocmoxa.com`.

## Publish an image

```sh
export DOCKER_BUILDKIT=1 # Enable multiplatform build, because our server is amd64.
docker build \
  --progress=plain \
  --platform=linux/amd64 \
  -t registry.gitlab.com/ocmoxa/ocmoxa.com .
docker push registry.gitlab.com/ocmoxa/ocmoxa.com
```

## Create namespace

`kubectl create namespace ocmoxa-prod`

## Create docker pull secret

It is required, so k8s will be able to pull images from our private gitlab registry.

Go to **gitlab repository** -> **settings** -> **deploy tokens**. Create a deploy token with registry read access.

Create a secret in the `ocmoxa-prod` namespaces as it is described [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

```sh
kubectl create secret \
    docker-registry regcred \
    --docker-server=registry.gitlab.com \
    --docker-username=gitlab+deploy-token-1043061 \
    --docker-password=s4iytgNG7vdN2Z8XyEpw \
    --docker-email=hedhyw@ocmoxa.com \
    -n ocmoxa-prod
```

## Create deployment

1. Read about [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
2. Let's define our deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ocmoxa-web
  labels:
    app: ocmoxa-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ocmoxa-web
  template:
    metadata:
      labels:
        app: ocmoxa-web
    spec:
      containers:
        - name: nginx
          image: registry.gitlab.com/ocmoxa/ocmoxa.com:latest # This is our image.
          ports:
            - containerPort: 80 # Container port.
      imagePullSecrets: # For public images we don't need this, but our image is in the private registry.
        - name: regcred # We defined the same name before.
```
3. Put it to `deployment.yaml`.
4. Create deployment:  
`kubectl create -n ocmoxa-prod -f deployment.yaml`.
5. Check deployment:  
`kubectl get deployments -n ocmoxa-prod`.
6. Check pod:  
`kubectl get pods -n ocmoxa-prod`.
7. Try to connect to the pod:  
`kubectl port-forward deployment/ocmoxa-web -n ocmoxa-prod 8080:80`.
8. Open http://localhost:8080.

## Create service

1. Read about [services](https://kubernetes.io/docs/concepts/services-networking/service/).
2. Let's define our service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ocmoxa-web
  labels:
    app: ocmoxa-web
spec:
  selector:
    app: ocmoxa-web
  type: ClusterIP # Exposes the Service on a cluster-INTERNAL IP.
  ports:
    - protocol: TCP
      port: 80
```
3. Put it to `service.yaml`.
4. Create service: `kubectl create -n ocmoxa-prod -f service.yaml`.
5. Check service:  
`kubectl get services -n ocmoxa-prod`.
6. Try to connect to the service:  
 `kubectl port-forward svc/ocmoxa-web -n ocmoxa-prod 8080:80`.
7. Open http://localhost:8080.

## Create ingress

1. Read about [ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/).
2. Let's define our ingress:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ocmoxa-web
  labels:
    app: ocmoxa-web
spec:
  rules:
    - host: ocmoxa.com # Our domain points to k8s IP.
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ocmoxa-web # Our service name from the previous step.
                port:
                  number: 80 # Our service port from the previous step.
```
3. Put it to `ingress.yaml`.
4. Create ingress:  
`kubectl create -n ocmoxa-prod -f ingress.yaml`.
5. Check ingress:  
`kubectl get ingresses -n ocmoxa-prod`.
6. Open http://ocmoxa.com/.
7. 😊

## That is not all
1. Try to delete everything by label:  
`kubectl delete deployments,pods,services,ingresses -n ocmoxa-prod -l app=ocmoxa-web`
2. Create a file k8s.yaml and put here contents of [deployment.yaml](deployment.yaml), [ingress.yaml](ingress.yaml) and [service.yaml](service.yaml) divded by "\n---\n".
You will got:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ocmoxa-web
  labels:
    app: ocmoxa-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ocmoxa-web
  template:
    metadata:
      labels:
        app: ocmoxa-web
    spec:
      containers:
        - name: nginx
          image: registry.gitlab.com/ocmoxa/ocmoxa.com:latest # This is our image.
          ports:
            - containerPort: 80 # Container port.
      imagePullSecrets:
        - name: regcred # We defined the same name before.
---
apiVersion: v1
kind: Service
metadata:
  name: ocmoxa-web
  labels:
    app: ocmoxa-web
spec:
  selector:
    app: ocmoxa-web
  type: ClusterIP # Exposes the Service on a cluster-INTERNAL IP.
  ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ocmoxa-web
  labels:
    app: ocmoxa-web
spec:
  rules:
    - host: ocmoxa.com # Our domain points to k8s IP.
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ocmoxa-web # Our service name from the previous step.
                port:
                  number: 80 # Our service port from the previous step.
```
3. Create everything: `kubectl create -n ocmoxa-prod -f k8s.yaml`.
4. Wait until pod is available.
5. Check http://ocmoxa.com/.
6. Create makefile that will preapre deploy to k8s. It should:
    1. create namespace;
    2. create pull secret;
    3. create everything from [k8s.yaml](k8s.yaml).

Congratulations on completing the tutorial!

＼ʕ◕ᴥ◕＼ʔ
