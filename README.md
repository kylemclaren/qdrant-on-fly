# Highly Available Qdrant Cluster on Fly.io

[![Lint](https://github.com/kylemclaren/qdrant-on-fly/actions/workflows/lint.yml/badge.svg?branch=master)](https://github.com/kylemclaren/qdrant-on-fly/actions/workflows/lint.yml)

[Qdrant](https://qdrant.tech/) is a search engine and database that specializes in finding similarities between vectors. It has an API that allows you to store, search, and manage vectors along with additional information. Qdrant is designed to support advanced filtering capabilities, making it useful for tasks like neural network matching, faceted search, and other applications.

Qdrant is built using the Rust programming language, which ensures [fast](https://qdrant.tech/benchmarks/) and reliable performance even when dealing with a large amount of data. You can use Qdrant to transform embeddings or neural network encoders into powerful applications for tasks such as matching, searching, recommending, and more. Notably, vector databases (Qdrant in particular) have seen a surge in popularity for their use as a vector store in combination with modern LLMs. See the [ChatGPT Retrieval Plugin](https://github.com/openai/chatgpt-retrieval-plugin/) for a good example of this.

This repository contains all the files and configuration necessary to run a Highly Available (HA) Qdrant cluster on a [Fly.io](https://fly.io/) organization's private network using Tailscale for peer-to-peer (P2P) communication and discovery. These resources are built into Docker images, allowing  smooth upgrades as new features and improvements are rolled out.

## Prepare a New Fly.io Application

Begin by creating a new Fly application in your preferred region. Execute the following commands within your fork or clone of this repository. But first, be sure to set your primary region in the `fly.toml` file.

### `fly launch --no-deploy`

This command generates a new Fly application and a related configuration file. When prompted, select `yes` to copy the existing configuration to the newly generated app.

## Tailscale Integration

The cluster uses [Tailscale](https://tailscale.com/) for P2P communication and discovery. Tailscale is a private WireGuard® network that provides secure, easy-to-setup networking between servers. You'll need to to create a new Tailscale organization. The recommended approach is to create a new GitHub organization, then use that to sign-in to Tailscale.

## Set Secrets

This setup requires several environment variables:

- **QDRANT__SERVICE__API_KEY**: Qdrant supports a simple form of client authentication using a static API key. This can be used to secure your instance. The API key will need t be set via the `api_key` header in any client request to the cluster. More [here](https://qdrant.tech/documentation/guides/security/).
- **TAILNET_DOMAIN**: Your Tailscale unique [tailnet name](https://tailscale.com/kb/1217/tailnet-name/).
- **TAILSCALE_AUTHKEY**: Your Tailscale pre-authentication ([**auth key**](https://tailscale.com/kb/1085/auth-keys/)) key to let you register new nodes. Needs to be `reusable` and `ephemeral`.

Set them using `fly secrets set`

## Deploy the First Peer

Start by deploying one instance in your preferred region.

1. `fly volumes create qdrant_data --region ord --size 10`
2. `fly deploy --ha=false`
3. `fly status`

## Add a New Peer

Expand the cluster by cloning the first machine. Currently, `fly scale count` does not support scaling Machines with persistent storage volumes. We'll use 'fly machine clone' to scale our cluster.

1. `fly machine clone --region ord --select --process-group app`
2. `fly status`

## Add a Peer in Another Region

Scale the setup to another region by cloning a machine there. Now you should have two peers in `ord` and another in `jnb`.

1. `fly machine clone --region jnb --select --process-group app`
2. `fly status`

## Having Trouble?

If you're facing difficulties or have any queries, feel free to create an issue [here](https://github.com/kylemclaren/qdrant-on-fly/issues).

Alternatively, you can ask questions at the community page [here](https://community.fly.io/).

## Contributing

If you're looking to contribute to the project, fork it and feel free to send pull requests.
