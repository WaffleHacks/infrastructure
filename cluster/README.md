# Cluster

The application cluster for WaffleHacks consisting of 2 node classes: storage and worker.

The storage nodes hold all persistent data for the applications running on the worker nodes.
They primarily run the PostgreSQL database and Redis cache.
The also act as the [K3S](https://k3s.io) master nodes for the workers.

The worker nodes run the applications required to power WaffleHacks.
They also have a local read-only replica of the PostgreSQL database and Redis cache.
This is to ensure low response times for read-heavy applications at the expense of consistency.
