# Створіть секрет з токеном вашого бота
```
kubectl create secret generic kbot-secrets --from-literal=tele-token='ВАШ_ТЕЛЕГРАМ_ТОКЕН' -n default
```

# Застосуйте створений файл
```
kubectl apply -f dev-monitoring.yaml
```

# Встановіть Fluent Bit через Helm
```
helm repo add fluent https://fluent.github.io/helm-charts && helm repo update
```
```
helm install fluent-bit fluent/fluent-bit \
  --namespace monitoring \
  --set config.outputs="[OUTPUT]\n    Name loki\n    Match *\n    Host loki.monitoring.svc.cluster.local\n    Port 3100\n    LineFormat json\n    Auto_Kubernetes_Labels on"
```


# Прокиньте порт до Grafana:
```
kubectl port-forward svc/grafana 3002:3002 -n monitoring
```