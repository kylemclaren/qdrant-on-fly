# Highly Available Qdrant Cluster on Fly.io

[![Lint](https://github.com/kylemclaren/qdrant-on-fly/actions/workflows/lint.yml/badge.svg?branch=master)](https://github.com/kylemclaren/qdrant-on-fly/actions/workflows/lint.yml)

[Qdrant](https://qdrant.tech/) is a search engine and database that specializes in finding similarities between vectors. It has an API that allows you to store, search, and manage vectors along with additional information. Qdrant is designed to support advanced filtering capabilities, making it useful for tasks like neural network matching, faceted search, and other applications.

Qdrant is built using the Rust programming language, which ensures [fast](https://qdrant.tech/benchmarks/) and reliable performance even when dealing with a large amount of data. You can use Qdrant to transform embeddings or neural network encoders into powerful applications for tasks such as matching, searching, recommending, and more. Notably, vector databases (Qdrant in particular) have seen a surge in popularity for their use as a vector store in combination with modern LLMs. See the [ChatGPT Retrieval Plugin](https://github.com/openai/chatgpt-retrieval-plugin/) for a good example of this.

This repository contains all the files and configuration necessary to run a Highly Available (HA) Qdrant cluster on a [Fly.io](https://fly.io/) organization's private network with peer-to-peer (P2P) communication and discovery.

___

## Prepare a New Fly.io Application and Deploy the First Peer

Begin by creating a new Fly application in your preferred region. Execute the following commands within your fork or clone of this repository. But first, be sure to set your primary region (and app name) in the `fly.toml` file.

Using the [Fly CLI](https://fly.io/docs/flyctl/) run the following:

```
fly launch --no-public-ips --from https://github.com/kylemclaren/qdrant-on-fly
````

This command creates a new Fly application with one runnning machine and an attached volume. When prompted, select `yes` to copy the existing configuration to the newly generated app. Do not create a PostgreSQL database or Upstash Redis instance.

## Add a New Peer

Expand the cluster by cloning the first machine. Currently, `fly scale count` does not support scaling Machines with persistent storage volumes. We'll use 'fly machine clone' to scale our cluster.

1. `fly machine clone --region ord --select`
2. `fly status`

## Add a Peer in Another Region

Scale the setup to another region by cloning a machine there. Now you should have two peers in `ord` and another in `jnb`.

1. `fly machine clone --region jnb --select`
2. `fly status`

## Connecting

### Connecting from a Client Application

Fly applications within the same organization can connect to your Qdrant database using the following URI:

```sh
http://<fly-app-name>.flycast:6333
```

First, you'll need to allocate a private [Flycast](https://fly.io/docs/networking/private-networking/#flycast-private-fly-proxy-services) IP address to your app. You can do this by running the following command:

```sh
fly ips allocate-v6 --private
```

### Public IP

If you need your app to be publicly accessible outside of the Fly Private network, you can simply [allocate a public IP](https://fly.io/docs/reference/services/#shared-ipv4) to the Fly app and start using the Fly Proxy to connect as normal (ie. `https://<fly-app-name>.fly.dev`)

> **Warning**
> If you do this, be sure to set the `QDRANT__SERVICE__API_KEY` secret.

### Connecting to Qdrant from Your Local Machine

1. Forward the server port to your local system with [`fly proxy`](https://fly.io/docs/flyctl/proxy/):

```sh
fly proxy 6333:6333 -a <fly-app-name>
```

2. Use your favorite API testing tool (like Postman or `curl`) to connect to your Qdrant instance on the forwarded port. Refer to the [Fly documentation](https://fly.io/docs/reference/volumes/) on volumes for more details on how to safely handle the volumes that store your vector data.

```sh
curl -H "Content-Type: application/json" http://localhost:6333/cluster | jq
```
<details>
<summary>Result</summary>
<br>

```json
{
  "result": {
    "status": "enabled",
    "peer_id": 8961156852769025,
    "peers": {
      "8961156852769025": {
        "uri": "http://e286376be66286.vm.qdrant-6pn.internal:6335/"
      },
      "6238012613461344": {
        "uri": "http://568370dc75418e.vm.qdrant-6pn.internal:6335/"
      },
      "2504460418660966": {
        "uri": "http://148e722b75d789.vm.qdrant-6pn.internal:6335/"
      }
    },
    "raft_info": {
      "term": 1314,
      "commit": 3510,
      "pending_operations": 0,
      "leader": 8961156852769025,
      "role": "Leader",
      "is_voter": true
    },
    "consensus_thread_status": {
      "consensus_thread_status": "working",
      "last_update": "2023-06-20T22:23:48.543413978Z"
    },
    "message_send_failures": {}
  },
  "status": "ok",
  "time": 4.125e-05
}
```
</details>

Head over to http://localhost:6333/dashboard to see the new Qdrant dashbaord and interact with your data there.

## Advanced Usage

### Data Storage

By default, Qdrant data and snapshots are stored in `/data/qdrant/`. If you need to change the default storage location, you can adjust the `QDRANT__STORAGE__SNAPSHOTS_PATH` and `QDRANT__STORAGE__STORAGE_PATH` variables in the [fly.toml](./fly.toml)

### Qdrant Sharding and Replication

### Globally-distributed Clusters

WIP

### FAQ

>Is this a good idea?
 
Probably not `¯\_(ツ)_/¯`
___

## Having Trouble?

If you're facing difficulties or have any queries, feel free to create an issue [here](https://github.com/kylemclaren/qdrant-on-fly/issues).

It is recommended to enable DEBUG logging before filing an issue: `fly secrets set QDRANT__DEBUG=true QDRANT__LOG_LEVEL=DEBUG`

Alternatively, you can ask questions at the community page [here](https://community.fly.io/).

## Contributing

If you're looking to contribute to the project, fork it and feel free to send pull requests.
