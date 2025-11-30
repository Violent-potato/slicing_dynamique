UE_NAME=$1
SST_ID=$2
CHART_PATH="./5g_core/oai-upf" 
RELEASE_NAME="upf-$UE_NAME"
NAMESPACE="nexslice"
TEMP_VALUES_FILE="/tmp/values-$RELEASE_NAME.yaml"

if [ -z "$UE_NAME" ] || [ -z "$SST_ID" ]; then
    echo "Erreur: Nom de l'UE et SST_ID manquants. Utilisa>
    exit 1
fi


IP_INDEX=$(echo $UE_NAME | grep -o '[0-9]*$') 
if [ -z "$IP_INDEX" ]; then IP_INDEX=1; fi

N3_IP_SUFFIX=$((100 + $IP_INDEX))
N3_IP="172.21.8.${N3_IP_SUFFIX}"

echo "-> Préparation de la version Helm : $RELEASE_NAME (S>

cat << EOF > $TEMP_VALUES_FILE
enabled: true

start:
  spgwu: true 

multus:
  n3Interface:
    create: true
    ipAdd: "$N3_IP"
    netmask: "22"
    name: "n3"
    hostInterface: "eth0"
  n4Interface:
    create: false
  n6Interface:
    create: false
EOF
helm install $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    -f $TEMP_VALUES_FILE \
    --set config.sst=$SST_ID

echo " UPF $RELEASE_NAME créé. Vérifiez les pods."




