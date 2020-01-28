# aaaas-demo
Ascii Art as a Service Demo

## Demo guide

1. *BEFORE* DEMO: Checkout `demo` branch (no targets, no compiled, README should just contain `kapitan compile`)
1. START DEMO: `cd infra`
1. create new *dev* target with classes:
  * init
  * component.api
  * component.dbrpc
  * component.redis
  * component.docs
  * component.scripts
1. `kapitan compile`
1. `git status` and inspect new files
1. open `compiled/dev/README.md`
1. `./compiled/dev/scripts/deploy` (cross fingers)
1. `./compiled/dev/scripts/ps` (do people recognise the output? - docker compose)
1. `curl localhost:8080/hello -XPOST -d 'Hello, CfgMgmtCamp!'



1. (v0.1) add `--style-title` flag
