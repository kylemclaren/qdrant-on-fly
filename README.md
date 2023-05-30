# Highly Available Qdrant Cluster on Fly.io

[![Lint](https://github.com/kylemclaren/qdrant-on-fly/actions/workflows/lint.yml/badge.svg?branch=master)](https://github.com/kylemclaren/qdrant-on-fly/actions/workflows/lint.yml)

[Qdrant](https://qdrant.tech/) is a search engine and database that specializes in finding similarities between vectors. It has an API that allows you to store, search, and manage vectors along with additional information. Qdrant is designed to support advanced filtering capabilities, making it useful for tasks like neural network matching, faceted search, and other applications.

Qdrant is built using the Rust programming language, which ensures [fast](https://qdrant.tech/benchmarks/) and reliable performance even when dealing with a large amount of data. You can use Qdrant to transform embeddings or neural network encoders into powerful applications for tasks such as matching, searching, recommending, and more. Notably, vector databases (Qdrant in particular) have seen a surge in popularity for their use as a vector store in combination with modern LLMs. See the [ChatGPT Retrieval Plugin](https://github.com/openai/chatgpt-retrieval-plugin/) for a good example of this.

This repository contains all the files and configuration necessary to run a Highly Available (HA) Qdrant cluster on a [Fly.io](https://fly.io/) organization's private network using Tailscale for peer-to-peer (P2P) communication and discovery. These resources are built into Docker images, allowing  smooth upgrades as new features and improvements are rolled out.

___

## Prepare a New Fly.io Application

Begin by creating a new Fly application in your preferred region. Execute the following commands within your fork or clone of this repository. But first, be sure to set your primary region in the `fly.toml` file.

### `fly launch --no-deploy`

This command generates a new Fly application and a related configuration file. When prompted, select `yes` to copy the existing configuration to the newly generated app.

## Tailscale Integration

The cluster uses [Tailscale](https://tailscale.com/) for P2P communication and discovery. Tailscale is a private WireGuard® network that provides secure, easy-to-setup networking between servers. You'll need to to create a new Tailscale organization. The recommended approach is to create a new GitHub organization, then use that to sign-in to Tailscale.

### Why not use Fly private networking or Flycast?

During initial testing, I encountered some issues with Qdrant's underlying networking libraries. They didn't play nice with IPv6! Using Tailscale allows us to leverage predictable, static DNS names (thanks to [MagicDNS](https://tailscale.com/kb/1081/magicdns/)) for P2P communication. This turned out to be a great move as it additionally makes discovery a little less tricky when bootstrapping peers.

## Set Secrets

This setup requires several environment variables:

- **QDRANT__SERVICE__API_KEY**: Qdrant supports a simple form of client authentication using a static API key. The API key will need to be set via the `api_key` header in any client request to the cluster. More [here](https://qdrant.tech/documentation/guides/security/).
- **TAILNET_DOMAIN**: Your Tailscale unique [tailnet name](https://tailscale.com/kb/1217/tailnet-name/).
- **TAILSCALE_AUTHKEY**: Your Tailscale pre-authentication ([**auth key**](https://tailscale.com/kb/1085/auth-keys/)) key to let you register new nodes. Needs to be `reusable` and `ephemeral`.

Set them using `fly secrets set`

## Deploy the First Peer

Start by deploying one instance in your preferred region.

1. `fly volumes create qdrant_data --region ord --size 10`
2. `fly deploy --ha=false --no-public-ips`
3. `fly status`

## Add a New Peer

Expand the cluster by cloning the first machine. Currently, `fly scale count` does not support scaling Machines with persistent storage volumes. We'll use 'fly machine clone' to scale our cluster.

1. `fly machine clone --region ord --select --process-group app`
2. `fly status`

## Add a Peer in Another Region

Scale the setup to another region by cloning a machine there. Now you should have two peers in `ord` and another in `jnb`.

1. `fly machine clone --region jnb --select --process-group app`
2. `fly status`

## Connecting

### Connecting from a Client Application

Fly applications within the same organization can connect to your Qdrant database using the following URI:

```sh
http://<fly-app-name>.internal:6333
```

### Public IP

If you need your app to be publicly accessible outside of the Fly Private network or your Tailnet, you can sinply add a public IP to the Fly app and start using the Fly Proxy to connect as normal (ie. `https://<fly-app-name>.fly.dev`)

### Connecting to Qdrant from Your Local Machine

1. Forward the server port to your local system with [`fly proxy`](https://fly.io/docs/flyctl/proxy/):

```sh
fly proxy 6333:6333 -a <fly-app-name>
```

2. Use your favorite API testing tool (like Postman or `curl`) to connect to your Qdrant instance on the forwarded port. Be sure to set the `api_key` header to the same value that you specified for `QDRANT__SERVICE__API_KEY`. Refer to the [Fly documentation](https://fly.io/docs/reference/volumes/) on volumes for more details on how to safely handle the volumes that store your vector data.

```sh
curl -H "api-key: <YOUR_API_KEY>" http://localhost:6333/cluster | jq
```
<details>
<summary>Result</summary>
<br>

```json
{
  "result": {
    "status": "enabled",
    "peer_id": 3556574999046494,
    "peers": {
      "3556574999046494": {
        "uri": "http://qdrant-peer-e784ee56ad1218-ord.pygmy-koi.ts.net:6335/"
      },
      "2310430634584339": {
        "uri": "http://qdrant-peer-4d8940dc6ee487-ord.pygmy-koi.ts.net:6335/"
      },
      "187138089536499": {
        "uri": "http://qdrant-peer-9080716a655387-jnb.pygmy-koi.ts.net:6335/"
      }
    },
    "raft_info": {
      "term": 1,
      "commit": 3,
      "pending_operations": 0,
      "leader": 3556574999046494,
      "role": "Leader",
      "is_voter": true
    },
    "consensus_thread_status": {
      "consensus_thread_status": "working",
      "last_update": "2023-05-29T21:30:45.579649708Z"
    },
    "message_send_failures": {}
  },
  "status": "ok",
  "time": 3.183e-05
}
```
</details>

### Advanced

#### Data Storage

By default, Qdrant data and snapshots are stored in `/data/qdrant/`. If you need to change the default storage location, you can adjust the `QDRANT__STORAGE__SNAPSHOTS_PATH` and `QDRANT__STORAGE__STORAGE_PATH` variables in the [fly.toml](./fly.toml)

#### Qdrant Sharding and Replication

WIP

### FAQ

WIP
___

## Having Trouble?

If you're facing difficulties or have any queries, feel free to create an issue [here](https://github.com/kylemclaren/qdrant-on-fly/issues).

Alternatively, you can ask questions at the community page [here](https://community.fly.io/).

## Contributing

If you're looking to contribute to the project, fork it and feel free to send pull requests.
