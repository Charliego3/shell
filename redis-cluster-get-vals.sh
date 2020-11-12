#!/usr/bin/env bash

cluster_address="$1"

if [[ -z "${cluster_address}" ]]; then
	echo "请输入Redis集群地址, eg: 127.0.0.1:6379"
	exit
fi

if [[ ! "${cluster_address}" =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5]).([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5]).([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5]).([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5]):[0-9]{1,}$ ]]; then
	echo "输入的地址不对, (IP:PORT) eg: 127.0.0.1:6379"
	exit
fi

ip=$(echo "${cluster_address}" | cut -d ":" -f 1)
port=$(echo "${cluster_address}" | cut -d ":" -f 2)

content=$(redis-cli --cluster call "${ip}":"${port}" cluster info)

declare -a cluster_ports
while read -r line; do
	if [[ "${line}" =~ ^${ip} && -n "${line}" ]]; then
		port=$(echo "${line}" | cut -d ":" -f 2)
		index=${#cluster_ports[@]}
		cluster_ports[${index}]="${port}"
	fi
done < <(echo "${content}")

echo "${cluster_ports[@]}"

inputKeys="$2"
keysContent=$(redis-cli --cluster call "${ip}":"${port}" keys "${inputKeys}")
declare -a keys

function containsKey() {
	for key in "${keys[@]}"; do
		if [[ $1 == "${key}" ]]; then
			return 0
		fi
	done
	return 1
}

while read -r line; do
	if [[ "${line}" =~ ^${ip} ]]; then
#		echo "${line}"
		key=$(echo "${line}" | cut -d ":" -f 3)
		key=$(echo "${key}" | grep -o "[^ ]\+\( \+[^ ]\+\)*")
		if [[ -n "${key}" ]]; then
			index=${#keys[@]}
			if ! containsKey "${key}"; then
				keys[${index}]="${key}"
			fi
		fi
	fi
done < <(echo "${keysContent}")

echo "Keys:" "${keys[@]}"
echo "${#keys[@]}"
