# Asm4pg - fork for cluster mtp(io-cpu)



## Les nouvelles fonctionnalités de préprocessing

On a integrer deux étapes de préprocessing **optionnelles** pour optimiser la qualité et l'efficacité des assemblages :

### Séparation  des reads mitochondriaux/nucléaires

**Pipeline scientifique :**
1. **Alignement** des reads contre une référence mitochondriale avec `minimap2`
2. **Classification automatique** : reads alignés → mitochondriaux, reads non-alignés → nucléaires
3. **Extraction parallèle** des deux populations avec `samtools` et `seqtk`



### Downsampling  avec préservation des reads longs

**Pipeline scientifiquement informé :**
1. **Estimation de la taille du génome** avec `Jellyfish` (comptage k-mers) + `GenomeScope`
2. **Calcul** du ratio de downsampling pour atteindre la couverture cible (current_cov = tot bases / genome size, ratio)
3. **Sous-échantillonnage** des reads avec `SeqKit`
4. **Préservation ** des reads ultra-longs (≥20kb) du reste des données

** Les reads longs sont extraits du **pool non-échantillonné**, maximisant ainsi la récupération des reads informatifs !




### Gestion  des sorties haploïdes


**AVANT :  Assumait toujours une sortie diploïde standard** 
* Échec si sortie haploïde !
* Échec si hap2 absent !
```bash
#
hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" --ont "$INPUT_FQ"
mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"   
mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"  
```

**MAINTENANT Support des ultra-long reads conditionnels**  
```bash

UL_OPT=""
if [ -n "$INPUT_LONG" ]; then
    UL_OPT="--ul $INPUT_LONG"  # Ajoute --ul seulement si disponible
fi
hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" --ont "$INPUT_FQ" $UL_OPT

# 2. Détection  des patterns de sortie
if [ -f "${PREFIX}.p_ctg.gfa" ]; then
    #  Cas 1: Sortie haploïde standard (ex: -l0 ou données faible hétérozygotie)
    mv "${PREFIX}.p_ctg.gfa" "$OUT1"
    cp "$OUT1" "$OUT2"  # Duplique pour satisfaire Snakemake
    
elif [ -f "${PREFIX}.bp.hap1.p_ctg.gfa" ]; then
    #  Cas 2: Sortie diploïde standard
    mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
    if [ -f "${PREFIX}.bp.hap2.p_ctg.gfa" ]; then
        mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"
    else
        cp "$OUT1" "$OUT2"  # Sécurité si hap2 manquant
    fi
    
elif [ -f "${PREFIX}.bp.p_ctg.gfa" ]; then
    # Cas 3: Haploïde avec préfixe 'bp.' 
    mv "${PREFIX}.bp.p_ctg.gfa" "$OUT1"
    cp "$OUT1" "$OUT2"
    
else
    # Cas d'erreur avec diagnostic
    echo "ERREUR: Aucun fichier d'assemblage trouvé !"
    exit 1
fi
```

#### ** Intégration au snakemake **

**AVANT**  :
```python
# Seulement FASTQ principal
shell: """./hifiasm_call.sh {params.mode} ... {params.fastqgz}"""
```

**MAINTENANT** (support ultra-long reads) :
```python
params:
    # Ajout du paramètre longreads conditionnel
    longreads = os.path.join(output_dir, "{sample}_results", "00_preprocess", 
                           "downsampling", "reads_{sample}_longreads.fastq.gz")
resources:
    mem_mb=450000 

shell: """
./hifiasm_call.sh {params.mode} ... {params.fastqgz} {params.longreads}
"""
```

#### **avantages de cette approche**

- Gestion des **paramètres de purge** variables (-l0 à -l3)
- **Ultra-long reads conditionnels** : utilise `--ul` seulement si disponible
   - **Mémoire adaptée** : 450GB pour supporter les ultra-long reads
   - **Prévention des échecs** : vérifications système avancées


#### **Cas d'usage**

| Paramètre | Type de données | Sortie Hifiasm | Gestion pipeline |
|-----------|----------------|----------------|------------------|
| `-l0` | Haploïde/faible hétérozygotie | `.p_ctg.gfa` |  Détecté et dupliqué |
| `-l1` à `-l3` | Diploïde standard | `.bp.hap1/2.p_ctg.gfa` |  Haplotypes séparés |


#### **Support conditionnel des ultra-long reads**

**Objectif :** Maximiser la contiguïté d'assemblage en utilisant les reads les plus grands.

```bash
# Dans le script hifiasm_call.sh - Nouveau paramètre INPUT_LONG
INPUT_LONG=${11}  # 11ème paramètre (ultra-long reads depuis downsampling)

# Support conditionnel 
UL_OPT=""
if [ -n "$INPUT_LONG" ] && [ -f "$INPUT_LONG" ] && [ -s "$INPUT_LONG" ]; then
    UL_OPT="--ul $INPUT_LONG"
    echo "🔹 Asm4pg -> Using ultra-long reads: $INPUT_LONG"
fi

# Commande Hifiasm enrichie
hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" --ont "$INPUT_FQ" $UL_OPT
```

- **N50 amélioré** : Les ultra-long reads (≥20kb) créent des connexions longue-distance

### Flux de données intégré

```
Reads bruts (ex: 250x de couverture)
    ↓
[separate_reads] → Séparation mito/nucléaire intelligente
    ↓                  (reads nucléaires purifiés)
    ↓
[downsample_reads] → Downsampling scientifique (50x) + extraction ultra-long reads (≥20kb)
    ↓                  ↓                                    ↓
    ↓             reads_downsampled.fastq.gz    reads_longreads.fastq.gz
    ↓                  ↓                                    ↓
[input_conversion] → FASTA (assemblage) + FASTQ (mode ONT)      ↓
    ↓                  ↓                                    ↓
    ↓                  ↓                    ┌───────────────┘
    ↓                  ↓                    ↓
[hifiasm] → hifiasm --ont reads.fastq.gz --ul longreads.fastq.gz
    ↓              ↓
    ↓         Détection automatique sortie (haploïde/diploïde)
    ↓              ↓
Assemblages finaux  (contiguïté maximale)
```

**Points clés du flux :**
1. **Données préservées** : Ultra-long reads extraits du **pool non-échantillonné**
2. **Assemblage hybride** : Couverture optimale (50x) + reads ultra-informatifs

On peut activer/désactiver ces étapes indépendamment via la configuration(masterconfig.yaml).
```yaml
  smpl_x:
    run_downsampling: True
    run_mito_separation: True


```

## 📂 Structure du dépôt

```bash
├── README.md
├── asm4pg  # <- script d'exécution
├── doc
├── workflow
│   ├── scripts
|   └── Snakefile
└──  .config
    ├── snakemake_profile
    └── masterconfig.yaml # <- fichier configuration
```

## Prérequis

- **Miniforge/conda (pour Snakemake>=8.4.7 et le plugin SLURM)**
- **Singularity/Apptainer** (pour l'exécution containerisée)

> **Note :** Tous les autre outils externes sont automatiquement gérés par Snakemake et seront téléchargés en tant qu'images Singularity/Apptainer (~6GB au total).

le clusters  :

- Si Conda ne peut pas écrire son cache de paquets (NoWritablePkgsDirError), on fait uncache accessible en écriture dans HOME :
```bash
module load anaconda/python3.8
mkdir -p $HOME/.conda/{pkgs,envs}
conda config --remove-key pkgs_dirs || true
conda config --prepend pkgs_dirs $HOME/.conda/pkgs
conda config --prepend envs_dirs $HOME/.conda/envs
```
- Si Apptainer/Singularity échoue à télécharger les images en raison de permissions ou d'OOM, fait un cache dans HOME et on augmente la mémoire du contrôleur :
  ```bash
  export APPTAINER_CACHEDIR=$HOME/.apptainer
  export SINGULARITY_CACHEDIR=$HOME/.apptainer
  mkdir -p "$APPTAINER_CACHEDIR"
  ```

---

## Comment utiliser (guide rapide)

### 1. Configuration

On clone le dépôt Git :
```bash
git clone https://forge.inrae.fr/asm4pg/GenomAsm4pg/ && cd GenomAsm4pg && mkdir slurm_logs
```

- à partir du fichier d'environnement fourni on crée un environnement pour snakemake  on rencontre des conflits de résolveur Conda sur notre cluster:

```bash
conda config --set channel_priority flexible
cat > .config/wf_env_fixed.yaml << 'EOF'
name: wf_env
channels:
  - conda-forge
  - bioconda
dependencies:
  - python=3.11
  - snakemake=8.4.7
  - snakemake-executor-plugin-slurm
  - pandas>=2.2.3,<3
  - pip
EOF

conda env create -n wf_env -f .config/wf_env_fixed.yaml
```

- On met à jour le fichier `asm4pg` avec les chemins corrects vers les modules **Singularity/Apptainer** lignes 45-46 :
```bash
echo '🔹 Asm4pg -> Activating execution environment'
case "${SLURM_SUBMIT_HOST:-$(hostname)}" in
    **io-**)
    echo '🔹 Asm4pg -> Identified io cluster'
    module purge
    module load bioinfo-ifb            # rend apptainer module dispo si besoin
    eval "$(/storage/replicated/cirad/binaries/ifb/miniconda3/bin/conda shell.bash hook)"
    conda activate wf_env
    export APPTAINER_CACHEDIR=$HOME/.apptainer
    export SINGULARITY_CACHEDIR=$HOME/.apptainer
    ;;
esac
```

### Configuration cluster SLURM "io"


On clone le dépôt Git :
```bash
git clone https://forge.inrae.fr/asm4pg/GenomAsm4pg/ && cd GenomAsm4pg && mkdir slurm_logs
```

- à partir du fichier d'environnement fourni on crée un environnement pour snakemake  on rencontre des conflits de résolveur Conda sur notre cluster:

```bash
conda config --set channel_priority flexible
cat > .config/wf_env_fixed.yaml << 'EOF'
name: wf_env
channels:
  - conda-forge
  - bioconda
dependencies:
  - python=3.11
  - snakemake=8.4.7
  - snakemake-executor-plugin-slurm
  - pandas>=2.2.3,<3
  - pip
EOF

conda env create -n wf_env -f .config/wf_env_fixed.yaml
```

Sur "io", ces paramètres fonctionnent  :

1) On s'assure que les caches Conda sont accessibles en écriture et on crée l'environnement :
```bash
mkdir -p $HOME/.conda/{pkgs,envs}
conda config --remove-key pkgs_dirs || true
conda config --prepend pkgs_dirs $HOME/.conda/pkgs
conda config --prepend envs_dirs $HOME/.conda/envs
conda config --set channel_priority flexible
conda env create -n wf_env -f .config/wf_env_fixed.yaml  # voir ci-dessus
```

2) Dans `asm4pg`, on ajoute un cas d'hôte et on définit les caches :
```bash
case "${SLURM_SUBMIT_HOST:-$(hostname)}" in
    **io-**)
        echo '🔹 Asm4pg -> Cluster io identifié'
        module purge
        module load bioinfo-ifb
        eval "$(/storage/replicated/cirad/binaries/ifb/miniconda3/bin/conda shell.bash hook)"
        conda activate wf_env
        export APPTAINER_CACHEDIR=$HOME/.apptainer
        export SINGULARITY_CACHEDIR=$HOME/.apptainer
        ;;
esac
```

3) Dans l'en-tête SBATCH d'`asm4pg`, on demande partition/QOS/temps/mémoire, par exemple :
```bash
#SBATCH -o slurm_logs/asm4pg_slurm_log_%j.log
#SBATCH -e slurm_logs/asm4pg_slurm_log_%j.log
#SBATCH --job-name=asm4pg
#SBATCH --partition=cpu-dedicated
#SBATCH --account=dedicated-cpu@cirad-long    # C'était ça qui manquait !
#SBATCH --qos=dedicated
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=500G
```

4) On aligne les paramètres par défaut du profil SLURM Snakemake dans `.config/snakemake/profiles/slurm/config.yaml` :
```yaml
default-resources:
  slurm_partition: cpu-dedicated
  slurm_qos: dedicated
  time: 01:00:00
  mem_mb: 25000
```

### 2. Configuration du pipeline pour nos données

- On édite le fichier `masterconfig` dans le répertoire `.config/` avec les informations de nos échantillons :
```bash
.config/masterconfig.yaml
```
- Ici on peut ajouter le chemin vers notre fichier de reads longs (fasta.gz, fasta, fastq.gz, fastq, ou bam)
- On met à jour le chemin vers le répertoire parent de sortie
- On conseille de garder les [options](doc/going_further.md) par défaut pour la première exécution

#### Configuration des nouvelles fonctionnalités de préprocessing

Pour activer les nouvelles étapes de préprocessing, on ajoute ces paramètres dans la configuration de chaque échantillon :

```yaml
samples:      
  example1:              # <- Premier niveau d'indentation = Nom de l'assemblage
    reads: example-1.fastq.gz    # <- Deuxième niveau = Toutes les options
    busco_lineage: basidiomycota_odb10
    
    # === NOUVELLES OPTIONS DE PRÉPROCESSING ===
    # Séparation mitochondriale
    run_mito_separation: True              # True/False
    mitochondrial_reference: "/path/to/reference_mito.fasta"
    
    # Downsampling intelligent
    run_downsampling: True                 # True/False
    target_coverage: 50                    # Couverture cible (défaut: 50)
    

```

**Paramètres clés :**
- **`purge_force: 0`** → Force un assemblage **haploïde** (équivaut à `-l0` dans Hifiasm)
- **`target_coverage`** → Par défaut 50X (recommandé 30-100X selon la complexité)
- **`mitochondrial_reference`** → Doit pointer vers une séquence mitochondriale de référence (FASTA)

#### **🔧 Détails techniques des améliorations**

**1. Passage des paramètres enrichi (hifiasm_call.sh)**
```bash
# AVANT : 10 paramètres
hifiasm_call.sh $MODE $PURGE_FORCE $THREADS $INPUT $RUN_1 $RUN_2 $PREFIX $OUT1 $OUT2 $INPUT_FQ

# MAINTENANT : 11 paramètres avec ultra-long reads
hifiasm_call.sh $MODE $PURGE_FORCE $THREADS $INPUT $RUN_1 $RUN_2 $PREFIX $OUT1 $OUT2 $INPUT_FQ $INPUT_LONG
#                                                                                                    ^^^^^^^^^^^
#                                                                                                   11ème paramètre
```

**2. Règle Snakemake optimisée**
```python
# AVANT : Ressources limitées, pas de long reads
resources: mem_mb=250000
shell: """./hifiasm_call.sh ... {params.fastqgz}"""

# MAINTENANT : Ressources augmentées, support long reads
resources: mem_mb=450000  # +80% mémoire pour ultra-long reads
params:
    longreads = os.path.join(..., "reads_{sample}_longreads.fastq.gz")
shell: """./hifiasm_call.sh ... {params.fastqgz} {params.longreads}"""
```

**3. Logique de détection robuste**
```bash
# AVANT : Gestion rigide (crash si pattern inattendu)
mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"  # ❌ Peut échouer
mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"  # ❌ Peut échouer

# MAINTENANT : Cascade de détection intelligente
if [ -f "${PREFIX}.p_ctg.gfa" ]; then          # Cas haploïde standard
    mv "${PREFIX}.p_ctg.gfa" "$OUT1"
    cp "$OUT1" "$OUT2"                         # Duplication automatique
elif [ -f "${PREFIX}.bp.hap1.p_ctg.gfa" ]; then # Cas diploïde standard  
    mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
    [ -f "${PREFIX}.bp.hap2.p_ctg.gfa" ] && mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2" || cp "$OUT1" "$OUT2"
elif [ -f "${PREFIX}.bp.p_ctg.gfa" ]; then     # Cas haploïde avec préfixe
    mv "${PREFIX}.bp.p_ctg.gfa" "$OUT1"
    cp "$OUT1" "$OUT2"
else
    echo "❌ ERREUR FATALE" && exit 1          # Diagnostic explicite
fi
```



### 3. Exécution du workflow

```bash
sbatch asm4pg dry # On vérifie les avertissements
sbatch asm4pg local-run 
```



Session sans sbatch:
```bash
srun --pty --partition=cpu-dedicated --qos=dedicated -t 02:00:00 -c 8 --mem=32G bash -l
./asm4pg local-run -j 8
```

##  Utilisation du plein potentiel du workflow

Asm4pg a de nombreuses options. Si on souhaite modifier les valeurs par défaut et en savoir plus sur le workflow, on se réfère à la [documentation](doc/documentation.md).

Pour une documentation détaillée sur les nouvelles fonctionnalités de préprocessing, on consulte le fichier [INTEGRATION_PREPROCESS_DOCUMENTATION.md](workflow/INTEGRATION_PREPROCESS_DOCUMENTATION.md).

## Sortie du workflow

```bash
└── sample
    └── results
        ├── 00_preprocess               # <- NOUVEAU : Étapes de préprocessing
        │   ├── separation
        │   │   ├── reads_sample_nuclear.fastq.gz
        │   │   └── reads_sample_mito.fastq.gz
        │   └── downsampling
        │       ├── reads_sample_downsampled.fastq.gz
        │       └── reads_sample_longreads.fastq.gz
        ├── 00_converted_input
        ├── 01_raw_assembly
        │   ├── sample.fasta.gz
        │   └── sample.gfa
        ├── 02_final_assembly
        │   ├── hap1/hap2
        │   │   ├── sample.fasta.gz # <- L'assemblage final
        │   │   └── ragtag_scafold
        ├── 03_raw_data_qc
        │   ├── genometools
        │   ├── genomescope
        │   └── jellyfish
        ├── 04_assembly_qc
        │   ├── hap1/hap2
        │   │   ├── genometools
        │   │   ├── busco
        │   │   ├── katplot
        │   │   ├── LTR/LAI
        │   │   └── telomeres
        │   ├── merqury
        │   │   ├── ...
        │   │   └── meryl_database.meryl
        │   └── quast
        ├── final_report.html # <- Le rapport final
        ├── benchmark
        └── logs
```

## 📜 Comment citer asm4pg ?

En attendant la publication, on peut citer asm4pg comme suit :

Denni S\*, Piat L\*, Bouallegue S, Tran J, Smith K, Wu C, Klopp C, Bui QT, Duvaux L. Asm4pg: a workflow for efficient long-read genome assembly for pangenomics (In prep.). https://forge.inrae.fr/asm4pg/GenomAsm4pg/

\* Ces auteurs ont contribué de manière égale à ce travail.

## Licence

Le contenu de ce dépôt est sous licence <A HREF="https://choosealicense.com/licenses/gpl-3.0/">(GNU GPLv3)</A>

## ✉️ Contacts

Pour tout dépannage, problème ou suggestion de fonctionnalité, on utilise l'onglet issues de ce dépôt.
Pour toute autre question ou si on souhaite aider au développement d'asm4pg, on contacte Ludovic Duvaux à ludovic.duvaux@inrae.fr
