---
# yamllint disable rule:line-length
name: Pull Request
on:
  pull_request:
  workflow_dispatch:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          token: ${ token }
          fetch-depth: '0'
      - name: Terraform Init
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version: ${ terraform }
          tf_actions_subcommand: init
          tf_actions_working_dir: ${ targetdir }
      - name: Terraform Validate
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version: ${ terraform }
          tf_actions_subcommand: validate
          tf_actions_working_dir: ${ targetdir }
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          token: ${ token }
          fetch-depth: '0'
      - uses: actions/setup-python@v2
        with:
          python-version: 3.8
      - run: |
          pip3 install lastversion
          lastversion terraform-docs --assets -d --verbose
          mkdir $GITHUB_WORKSPACE/bin
          tar -xvf terraform-docs*.tar.gz --directory $GITHUB_WORKSPACE/bin
          chmod +x $GITHUB_WORKSPACE/bin/terraform-docs
          echo "$GITHUB_WORKSPACE/bin" >> $GITHUB_PATH    
      - uses: pre-commit/action@v2.0.0
