# Cluster

The application cluster for WaffleHacks powered by [Nomad](https://www.nomadproject.io/) and [Consul](https://www.consul.io/).


### Directories

- `/deployment` - manages the underlying infrastructure


### Permissions

The provided token must have at least the following permissions:

| Access       | Read | Write |
|--------------|:----:|:-----:|
| Events       | x    |       |
| Firewalls    | x    | x     |
| Linodes      | x    | x     |
| StackScripts | x    | x     |
