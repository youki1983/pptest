#!/bin/sh

# Global variables
DIR_CONFIG="/etc/mysevv"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write configuration
cat << EOF > ${DIR_TMP}/mysevv.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}",
                "alterId": 0
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get mysevv executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/youki1983/pptest/blob/dev3/linux-64.zip -o ${DIR_TMP}/mysevv_dist.zip
busybox unzip ${DIR_TMP}/mysevv_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/ctl config ${DIR_TMP}/mysevv.json > ${DIR_CONFIG}/config.pb

# Install mysevv
install -m 755 ${DIR_TMP}/mysevv ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run mysevv
${DIR_RUNTIME}/mysevv -config=${DIR_CONFIG}/config.pb
