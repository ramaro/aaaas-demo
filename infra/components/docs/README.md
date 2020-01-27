{% set i = inventory.parameters %}

# Welcome to the README!

## Getting Started

You are running a version of `aaaas-demo` running in {{i.platform}}

Remember to run `$ kapitan compile` whenever you change any code to ensure it is updated before deploying.


## Deploying aaaas-demo

To deploy, run:

```shell
$ ./compiled/{{i.target}}/scripts/deploy
```

## Listing running processes

To list processes , run:

```shell
$ ./compiled/{{i.target}}/scripts/ps
```


## Stopping it

To stop, run:

```shell
$ ./compiled/{{i.target}}/scripts/stop
```
## Running platform specific commands

Run:

```shell
$ ./compiled/{{i.target}}/scripts/ps --help
```
