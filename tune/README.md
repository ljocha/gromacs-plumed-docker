Based on https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/static-ray-cluster-without-kuberay.html

    pip3 install 'ray[default]'
    kubectl apply -f network.yaml
    kubectl apply -f static-cluster.yaml

In another shell (keep it open)

    kubectl port-forward --address 0.0.0.0 service/service-ray-cluster 8265:8265

Go to http://localhost:8265 for dashboard

Hellow world job

    ray job submit --address http://localhost:8265 -- python -c "import ray; ray.init(); print(ray.cluster_resources())"




https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/raycluster-quick-start.html#kuberay-raycluster-quickstart
does not work out-of-box, needs admin privileges (CRD)


