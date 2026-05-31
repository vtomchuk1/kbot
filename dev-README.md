# для ручного дебагу було створено декілька файлів конфігів

* [Додаткові налаштування скрейпінгу Prometheus](/prometheus-additional-scrape.yaml)
* [Helm Values для OpenTelemetry Collector](/otel-values.yaml)
* [Конфігурація скрейпінгу OpenTelemetry](/otel-scrape-config.yaml)
* [ServiceMonitor для Kbot](/otel-kbot-monitor.yaml)
* [Helm Values для Fluent Bit](/fluent-bit-values.yaml)
* [Мережева політика (NetworkPolicy) Kbot до OTel](/allow-kbot-to-otel.yaml)

# [основний файл конфігурації моніторингу](/dev-monitoring.yaml)

![grafana](/grafana.png)


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