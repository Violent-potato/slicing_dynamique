# Projet NexSlice : Slicing Dynamique du Core 5G OAI

**Projet :** 1  
**Groupe :** 12  
**Étudiants :** Amélie Buret, Alban Robert, Zakari Hadjeres 

**Année :** 2025–2026  

---

## Table des Matières
1. [Introduction](#introduction)  
2. [Objectifs](#objectifs)  
3. [État de l'Art](#état-de-lart)  
4. [Architecture Globale](#architecture-globale)  
5. [Méthodologie et Implémentation](#méthodologie-et-implémentation)  
6. [Résultats Obtenus](#résultats-obtenus)  
7. [Conclusion](#conclusion)  
---

## 1. Introduction

### Contexte
Le projet **NexSlice** s’inscrit dans le cadre de l’étude des architectures **5G** et du **Network Slicing**, un mécanisme permettant d’allouer dynamiquement des ressources réseau selon les besoins spécifiques d’un service ou d’un utilisateur.

Dans la 5G, le slicing repose principalement sur le choix dynamique du **User Plane Function (UPF)**, orchestré par le **SMF (Session Management Function)**.  
Cependant, dans le Core OAI fourni dans NexSlice, le slicing est **statique**, et les UPF sont déclarés manuellement dans les fichiers Helm.

### Problématique
Comment automatiser la création et l’association d’un UPF dédié lors du déploiement d’un nouvel UE, afin de réaliser un slicing réellement dynamique dans le Core OAI ?

---

## 2. Objectifs

Notre projet implémente un mécanisme de slicing dynamique basé sur :

- Désactivation des UPF statiques dans les charts Helm officiels d’OAI  
- Déploiement automatisé des UEs et du gNB via UERANSIM  
- Détection automatique de l’absence d’UPF dans les logs du SMF  
- Génération automatique d’un UPF dédié pour chaque UE via un script Bash  
- Suppression automatique d’un UPF lorsque l’UE est désinstallé  
  
---

## 3. État de l'Art



## 4. Architecture Globale

### Flux de fonctionnement dynamique
1. L’UE se connecte → le SMF cherche un UPF  
2. Aucun UPF trouvé → les logs affichent *"No UPF available"* et la PDU session est rejetée  
3. Le script lit les logs → déclenche la création d’un UPF (via Helm)  
4. L’UPF est déployé et s’enregistre au NRF  
5. Le SMF refait la sélection → trouve l’UPF → PDU session établie  
6. L’UE peut accéder à Internet (ping fonctionnel) 

---

## 5. Méthodologie et Implémentation

### 1. Désactivation du slicing statique
Dans le fichier de configuration Helm, il faut désactiver les UPF statiques en modifiant la valeur `enabled` à `false` :
```yaml
oai-upf:
  enabled: false
  nfimage:
    repository: docker.io/oaisoftwarealliance/oai-upf
    version: v2.1.0
    pullPolicy: IfNotPresent
  includeTcpDumpContainer: false
```
### 2. Déploiement du RAN UERANSIM 

```bash
helm install ueransim-gnb 5g_ran/ueransim-gnb -n nexslice
helm install ueransim-ue1 5g_ran/ueransim-ue1 -n nexslice
```
### 3. Tentative de PDU Session sans UPF
Les UEs tentent d’établir une session PDU, mais le SMF rejette la requête car aucun UPF n’est disponible :

```bash
[nas] [error] PDU Session Establishment Reject received
```
### 4. Script de création dynamique d’UPF
Le script :
- prend en paramètres :
le nom de l’UE, le SST (type de slice)

- génère automatiquement une IP N3 unique pour l’UPF,

- crée un fichier values.yaml temporaire avec cette configuration,

- déploie un UPF spécifique via Helm,

- associe ce UPF au slice via ```yaml
   config.sst=<SST_ID>. ```

L’UPF est alors déployé et s’enregistre correctement au NRF :
```bash
UPF upf-ue1 créé. Vérifiez les pods.
[upf_app] [info] Got successful response from NRF
[upf_app] [debug] NF Status REGISTERED
```
Pour s'assurer de la fonctionnalité de la solution, un ping Internet a été effectué avec succès :
```bash
kubectl exec -it -n nexslice ueransim-ue1-ueransim-ues-64d67cf8bd-5ctwl -- ping -c 3 -I uesimtun0 google.com

64 bytes from google.com: icmp_seq=1 ttl=253 time=11.0 ms
64 bytes from google.com: icmp_seq=2 ttl=253 time=8.75 ms
64 bytes from google.com: icmp_seq=3 ttl=253 time=6.77 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
