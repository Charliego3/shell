#!/usr/bin/env bash

content=">>> Calling cluster info
172.16.100.123:4000: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:1
cluster_stats_messages_ping_sent:64036581
cluster_stats_messages_pong_sent:64368577
cluster_stats_messages_publish_sent:7
cluster_stats_messages_sent:128405165
cluster_stats_messages_ping_received:64368577
cluster_stats_messages_pong_received:64036581
cluster_stats_messages_received:128405158

172.16.100.123:4003: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:9
cluster_stats_messages_ping_sent:64706488
cluster_stats_messages_pong_sent:63846527
cluster_stats_messages_sent:128553015
cluster_stats_messages_ping_received:63846527
cluster_stats_messages_pong_received:64706488
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:128553016

172.16.100.123:4004: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:9
cluster_stats_messages_ping_sent:63518294
cluster_stats_messages_pong_sent:65961201
cluster_stats_messages_sent:129479495
cluster_stats_messages_ping_received:65961201
cluster_stats_messages_pong_received:63518294
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:129479496

172.16.100.123:4007: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:2
cluster_stats_messages_ping_sent:64282719
cluster_stats_messages_pong_sent:63759253
cluster_stats_messages_sent:128041972
cluster_stats_messages_ping_received:63759253
cluster_stats_messages_pong_received:64282719
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:128041973

172.16.100.123:4002: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:3
cluster_stats_messages_ping_sent:64822424
cluster_stats_messages_pong_sent:64085189
cluster_stats_messages_sent:128907613
cluster_stats_messages_ping_received:64085189
cluster_stats_messages_pong_received:64822424
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:128907614

172.16.100.123:4006: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:1
cluster_stats_messages_ping_sent:64408139
cluster_stats_messages_pong_sent:63654421
cluster_stats_messages_sent:128062560
cluster_stats_messages_ping_received:63654421
cluster_stats_messages_pong_received:64408139
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:128062561

172.16.100.123:4001: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:2
cluster_stats_messages_ping_sent:64027245
cluster_stats_messages_pong_sent:64783166
cluster_stats_messages_sent:128810411
cluster_stats_messages_ping_received:64783166
cluster_stats_messages_pong_received:64027245
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:128810412

172.16.100.123:4005: cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:8
cluster_size:4
cluster_current_epoch:10
cluster_my_epoch:3
cluster_stats_messages_ping_sent:64660775
cluster_stats_messages_pong_sent:64004331
cluster_stats_messages_sent:128665106
cluster_stats_messages_ping_received:64004331
cluster_stats_messages_pong_received:64660775
cluster_stats_messages_publish_received:1
cluster_stats_messages_received:128665107
"

declare -a cluster_ports
ip="172.16.100.123"
while read -r line; do
	if [[ ! "${line}" =~ ^\>\>\> ]]; then
		if [[ "${line}" =~ ^${ip} ]]; then
			port=$(echo "${line}" | cut -d ":" -f 2)
			index=${#cluster_ports[@]}
			cluster_ports[${index}]="${port}"
		fi
	fi
done < <(echo "${content}")

echo "${cluster_ports[@]}"
