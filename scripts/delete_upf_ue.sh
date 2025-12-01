#!/bin/bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

UE_RELEASE_NAME="$1"
UPF_RELEASE_NAME="$2"
NAMESPACE="nexslice"

if [ -z "$UE_RELEASE_NAME" ] || [ -z "$UPF_RELEASE_NAME" ]; then
    echo "ERREUR: Arguments manquants."
    echo "Usage: $0 <NOM_UE> <NOM_UPF>"
    echo "Exemple: $0 ueransim-ue1 upf-ue1"
    exit 1
fi

echo "--- Démarrage de la procédure d'arrêt de la tranche ---"
echo "  UE à désinstaller : $UE_RELEASE_NAME"
echo "  UPF à désinstaller : $UPF_RELEASE_NAME"
echo "  Namespace : $NAMESPACE"
echo ""

if ! sudo kubectl get nodes > /dev/null 2>&1; then
    echo "ERREUR CRITIQUE  Le cluster K3s semble être injoignable ou à l'arrêt."
    echo "Veuillez vérifier l'état de K3s sur votre VM : sudo systemctl status k3s"
    exit 1
fi
echo "Connexion K3s vérifiée. Démarrage de la désinstallation."


echo "1. Désinstallation de l'UE $UE_RELEASE_NAME..."
sudo helm uninstall "$UE_RELEASE_NAME" -n "$NAMESPACE"

if [ $? -eq 0 ]; then
    echo "    [SUCCÈS] L'UE a été désinstallé."
else
    echo "    [AVERTISSEMENT] Échec de la désinstallation de l'UE $UE_RELEASE_NAME. Tentative de suppression de l'UPF quand même."
fi

echo "2. Désinstallation de l'UPF $UPF_RELEASE_NAME..."
sudo helm uninstall "$UPF_RELEASE_NAME" -n "$NAMESPACE"

if [ $? -eq 0 ]; then
    echo "    [SUCCÈS] L'UPF a été désinstallé."
    echo "ARRÊT COMPLET DE LA TRANCHE RÉUSSI."
    echo "Vérification des pods restants (dans 5 secondes) :"
    sleep 5
    sudo kubectl get pods -n $NAMESPACE | grep -E "(upf|ue1)" || echo "Aucun pod UE/UPF trouvé."
else
    echo "    [ERREUR FATALE] Échec de la désinstallation de l'UPF. Vérifiez manuellement : sudo helm uninstall $UPF_RELEASE_NAME -n $NAMESPACE"
    exit 1
fi

exit 0

