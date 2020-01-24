local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local params = inv.parameters;

local main_compose = if params.platform == "compose" then {
  "api": {
    version: "3",
    services: {
      api: {
        image: params.api.image,
        ports: [ "%(bind_port)d:%(bind_port)d" % params.api, ],
        command: [ "%s" % c for c in params.api.args ], //cast all to string
      }
    }
  }
}
else {};

local main_kubernetes = if params.platform == "kubernetes" then {
  local containers = [
    {
      name: "api",
      image: params.api.image,
      ports: [{containerPort: params.api.bind_port}],
      args: ["%s" % arg for arg in params.api.args ], // TODO remove and hardcode args/styles for demo
    },
  ],

  local deployment = {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
        name: "api",
        namespace: inv.parameters.target,
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: { app: "api" },
        },
        template: {
            metadata: {
                labels: { app: "api" },
            },
            spec: {
                containers: containers,
            },
        },
    },
  },

  local service = {
      apiVersion: "v1",
      kind: "Service",
      spec: {
          ports: [
              {
                name: "http",
                port: 8080,
                targetPort: params.api.bind_port
              },
          ],
          selector: { app: "api" },
          type: "NodePort", // TODO hardcode nodeport and open firewall!!!
      },

      metadata: {
          name: "api",
          namespace: inv.parameters.target,
          labels: { name: "api" },
      },
  },

  "api-deployment": deployment,
  "api-service": service,


}
else {};

main_compose + main_kubernetes

