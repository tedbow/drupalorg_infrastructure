# This reconfigures staging geo via a script
Gitlab::Geo.primary_node.update!(url: "https://gitlab.code-staging.devdrupal.org/")
Gitlab::Geo.secondary_nodes.first.update!(url: "https://gitlab2.code-staging.devdrupal.org/", oauth_application_id: nil)
