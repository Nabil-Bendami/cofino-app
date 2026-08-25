# Cahier des charges — SaaS Café Maroc

Ce dossier contient le cahier des charges LaTeX et ses douze diagrammes UML PlantUML.

## Structure

- `cahier_des_charges.tex` : source principale du document.
- `cahier_des_charges.pdf` : document compilé, prêt à présenter.
- `uml/*.puml` : sources PlantUML des diagrammes.
- `uml/*.png` : rendus intégrés au PDF.
- `images/` : emplacement réservé à d’éventuels visuels de marque.

## Prérequis

- XeLaTeX (TeX Live ou MacTeX) ;
- PlantUML et Java pour régénérer les diagrammes.

## Compilation

Depuis le dossier `docs` :

```bash
plantuml -tpng uml/*.puml
xelatex -interaction=nonstopmode -halt-on-error cahier_des_charges.tex
xelatex -interaction=nonstopmode -halt-on-error cahier_des_charges.tex
```

La première commande produit les fichiers PNG à partir des sources `.puml`. Les deux passages XeLaTeX mettent à jour la table des matières, les références croisées et les numéros de pages.

## Vérification rapide

Après compilation, le fichier `cahier_des_charges.pdf` doit inclure les 12 diagrammes suivants : 3 cas d’utilisation, 1 diagramme de classes, 3 séquences, 1 activité, 1 état, 1 composants, 1 déploiement et 1 modèle entité-association.
