# This reconfigures staging geo via a script
Gitlab::Geo.primary_node.update!(url: "https://git.code-staging.devdrupal.org/")
Gitlab::Geo.secondary_nodes.first.update!(url: "https://git2.code-staging.devdrupal.org/", oauth_application_id: nil)
