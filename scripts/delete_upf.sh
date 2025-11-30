UE_NAME=$1
RELEASE_NAME="upf-$UE_NAME"
NAMESPACE="nexslice"

if [ -z "$UE_NAME" ]; then
    echo "Erreur: Nom de l'UE manquant. Utilisation: $0 <n>
    exit 1
fi

echo "-> Suppression de la version Helm : $RELEASE_NAME..."
helm uninstall $RELEASE_NAME -n $NAMESPACE

TEMP_VALUES_FILE="/tmp/values-$RELEASE_NAME.yaml"
if [ -f "$TEMP_VALUES_FILE" ]; then
    rm $TEMP_VALUES_FILE
fi

echo "UPF $RELEASE_NAME supprimé."




