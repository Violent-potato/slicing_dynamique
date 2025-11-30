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
- Déploiement automatisé des UEs et du gNodeB via UERANSIM  
- Détection automatique de l’absence d’UPF dans les logs du SMF  
- Génération automatique d’un UPF dédié pour chaque UE via un script Bash  
- Configuration automatique des interfaces N3 avec IP unique pour chaque UPF  
- Association dynamique entre UPF et slice (via SST)  
- Suppression automatique d’un UPF lorsque l’UE est désinstallé  
- Documentation complète et système facilement reproductible
  
---

## 3. État de l'Art



## 4. Architecture Globale

### Flux de fonctionnement dynamique
1. L'UE se connecte → SMF cherche un UPF  
2. Aucun UPF trouvé → les logs affichent qu'aucun UPF n'a été trouvé   
3. Le script lit les logs → déclenche la création d'un UPF  
4. L'UPF est déployé via Helm + Multus  
5. L'UPF s’enregistre au NRF  
6. Le SMF trouve l’UPF → PDU session établie  

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

