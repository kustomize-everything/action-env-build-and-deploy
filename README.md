# action-env-build-and-diff

[![CodeScene general](https://codescene.io/images/analyzed-by-codescene-badge.svg)](https://codescene.io/projects/44667)

Build and diff a Kustomize Environment overlay with GitHub Actions

## Usage

### Pre-requisites

- Github repo where your Kustomize deployment files reside e.g. [kustomize-everything/guestbook-deploy](https://github.com/kustomize-everything/guestbook-deploy)

### Inputs

Refer to [action.yml](./action.yml)

### Outputs

Refer to [action.yml](./action.yml)

### Example Workflow

For a complete example, please refer to [kustomize-everything/guestbook-deploy](https://github.com/kustomize-everything/guestbook-deploy).

```yaml
---
name: Render Manifests
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  render-manifests:
    name: Render manifests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        env: [dev, prod]

    steps:
      - uses: actions/checkout@v3
        with:
          # fetch-depth: 0 needed to get all branches
          fetch-depth: 0

      - name: Render manifests and comment with diff
        uses: kustomize-everything/action-env-build-and-deploy@v1.2.1
        if: github.event_name == 'pull_request'
        with:
          dry-run: 'true'
          environment: ${{ matrix.env }}
          push-environment-regex: dev
          pr-environment-regex: prod

      - name: Render manifests and push branch
        uses: kustomize-everything/action-env-build-and-deploy@v1.2.1
        if: github.event_name == 'push'
        with:
          dry-run: 'false'
          environment: ${{ matrix.env }}
          push-environment-regex: dev
          pr-environment-regex: prod
```

## Contributing

We would love for you to contribute to kustomize-everything/actions-env-build-and-deploy, pull requests are welcome!

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).
