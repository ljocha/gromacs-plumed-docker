# Tune parameters for maximal performance

Based on [this tutorial](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/static-ray-cluster-without-kuberay.html)

Proof-of-concept implementations, only numbers of MPI processes and OMP threads tuned in this version, with simple exhaustive grid search. For possible extensions see [Ray Tune documentation](https://docs.ray.io/en/latest/tune/index.html)

### Build docker image

I've already built the image and published it at Dockerhub. No need to run these steps unless the Gromacs container is changed, other Ray version used etc.

    docker build -t ljocha/gromacs:2023-2-ray .
    docker push ljocha/gromacs:2023-2-ray

### Install Ray
    pip3 install 'ray[default]'

### Start Ray cluster in Kubernetes

This is more or less example setup, static cluster with two workernodes, each with 8 CPUs and 1 GPU (Mig). 
Edit [static-cluster.yaml](static-cluster.yaml) for changing it.

Production setup should use autoscaling cluster shared by more experiments eventually, see [Ray K8 deployment docs](https://docs.ray.io/en/latest/cluster/kubernetes/index.html). It requires admin privileges, though.

Set NAMESPACE properly and run:

    kubectl -n $NAMESPACE apply -f static-cluster.yaml

Eventually, if the default K8s network policy is closed, adjust it according to the
[tutorial](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/static-ray-cluster-without-kuberay.html).

Wait until the head and worker node pods go up, images are huge, downloading them takes a while.

Set up port forwarding in another shell (keep it open). Unauthenticated, relying on localhost to be safe!


    kubectl -n $NAMESPACE port-forward --address 127.0.0.1 service/service-ray-cluster 8265:8265

Go to http://localhost:8265 for dashboard

Hellow world job to check everything is up.

    ray job submit --address http://localhost:8265 -- python -c "import ray; ray.init(); print(ray.cluster_resources())"

### Setup and tuning experiment

To do anything useful, replace sample Gromacs inputs in this directory with real ones. The experiment expects:
- npt.gro -- simulated system description
- npt.cpt -- starting checkpoint, typically the result of isothermal-isobaric equilibration
- md.tpr -- processed parameters (grompp output) for the MD run

Edit [tune.py](tune.py) to adjust tuning parameters: number of MPI processes and OMP threads (these multiply, beware of not exceeding size of your worker node), number of simulation steps eventually. 

Run the experiment finally

    ray job submit --working-dir . --address http://localhost:8265 -- python3 tune.py 

The evaluated metric is "nanoseconds per day" as reported in Gromacs log. It's quite normal that some setups fail, smaller simulated systems may not be decomposable to higher number of domains (MPI procersses).

### Cleanup

Release allocated resources of the static cluster:

    kubectl -n $NAMESPACE delete -f static-cluster.yaml
