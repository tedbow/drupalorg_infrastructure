#!/bin/bash
PRIVATE_TOKEN=XWWZ2zxXvJkUWksoParK
#The api url
GITLAB_URL=gitlab1.drupalcode.org

SETTINGS=`curl -s -g --request PUT --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" "https://${GITLAB_URL}/api/v4/application/settings?default_project_visibility=public&defaul
t_snippet_visibility=public&default_group_visibility=public&import_sources[]=git&default_projects_limit=0&max_attachment_size=30&session_expire_delay=10080&user_oauth_ap
plications=false&signup_enabled=false&password_authentication_enabled_for_web=false&password_authentication_enabled_for_git=false&mirror_available=false&throttle_unauthe
nticated_enabled=true&throttle_authenticated_web_enabled=true&throttle_authenticated_api_enabled=true&prometheus_metrics_enabled=true&metrics_enabled=true&metrics_host=l
ocalhost&metrics_port=8089&metrics_pool_size=16&metrics_timeout=10&metrics_method_call_threshold=10&metrics_sample_interval=15&metrics_packet_size=1&after_sign_out_path=
&after_sign_up_text=&authorized_keys_enabled=false&auto_devops_enabled=false&auto_devops_domain=&default_branch_protection=0&default_projects_limit=100000&hide_third_par
ty_offers=true&home_page_url=&max_attachment_size=10&metrics_enabled=false&password_authentication_enabled_for_web=true&project_export_enabled=false&restricted_visibilit
y_levels[]=private&restricted_visibility_levels[]=internal&shared_runners_enabled=false&shared_runners_text=&sign_in_text=&throttle_authenticated_api_enabled=false&throt
tle_authenticated_web_enabled=false&throttle_unauthenticated_enabled=false&usage_ping_enabled=false&user_show_add_ssh_key_message=false&user_default_internal_regex=&hash
ed_storage_enabled=true"`

PROJECTGID=`curl -s -g --request POST --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" -d "name=project&path=project&visibility=public" https://${GITLAB_URL}/api/v4/groups |jq
 ".id"`
SANDBOXID=`curl -s -g --request POST --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" -d "name=sandbox&path=sandbox&visibility=public" https://${GITLAB_URL}/api/v4/groups |jq
".id"`
BOTUSERID=`curl -s -g --request POST --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" -d "name=drupalbot&username=drupalbot&email=sysops@drupal.org&admin=true&password=7pRvN3y
gzBKaRS3s" https://${GITLAB_URL}/api/v4/users |jq ".id"`
TOKEN=`curl -s -g --request POST --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" -d "name=drupalbottoken&scopes[]=api&scopes[]=read_user&scopes[]=sudo&scopes[]=read_repositor
y" https://${GITLAB_URL}/api/v4/users/${BOTUSERID}/impersonation_tokens |jq ".token"`
echo "Project Group ID is ${PROJECTGID}."
echo "Sandbox Group ID is ${SANDBOXID}."
echo "Drupalbot User ID is ${BOTUSERID}."
echo "Drupalbot Impersonation Token is ${TOKEN}."
