# Використання плагіну
```
chmod +x ./kubeplugin
./kubeplugin
```

# Приклад виводу
```
Resource, Namespace, Name, CPU, Memory
pods, kube-system, coredns-ccb96694c-htgm5, 3m, 16Mi
pods, kube-system, local-path-provisioner-5cf85fd84d-7tzvx, 1m, 8Mi
pods, kube-system, metrics-server-5985cbc9d7-vsldv, 7m, 23Mi
pods, kube-system, svclb-traefik-669680d7-9kc2p, 0m, 0Mi
pods, kube-system, svclb-traefik-669680d7-cjdpt, 0m, 0Mi
pods, kube-system, svclb-traefik-669680d7-jxhx8, 0m, 0Mi
pods, kube-system, traefik-5d45fc8cc9-kdt9d, 1m, 31Mi
```

# Як встановити в систему 
```
cp kubeplugin kubectl-kubeplugin
sudo mv kubectl-kubeplugin /usr/local/bin/
kubectl kubeplugin
```

# Демо

![Демо плагіну](demo.gif)