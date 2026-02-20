-- =============================================================
-- MODULE: Gestion Administrative Académique
-- =============================================================
-- Tables pour la gestion des années académiques, cycles,
-- filières, niveaux, classes et semestres

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Table: Années académiques
CREATE TABLE AnneeAcademique (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL, -- Ex: '2023-2024'
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    est_active BOOLEAN DEFAULT FALSE,
    CONSTRAINT date_coherence CHECK (date_fin > date_debut)
);

COMMENT ON TABLE AnneeAcademique IS 'Années académiques du système';

-- Table: Cycles d'études

CREATE TABLE Cycle (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL,          -- L, M, D
    designation VARCHAR(100) NOT NULL,         -- Licence, Master, Doctorat
    diplome VARCHAR(150) NOT NULL,             -- Licence en ..., Master en ...
    duree_annees INTEGER NOT NULL CHECK (duree_annees > 0),
    credits_total INTEGER CHECK (credits_total > 0),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

COMMENT ON TABLE Cycle IS 'Cycles d''études (Licence, Master, Doctorat)';

-- Table: Filières/Programmes d'études
CREATE TABLE Filiere (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL,
    designation VARCHAR(100) NOT NULL,
    cycle_id UUID REFERENCES Cycle(id),
    credit_total INTEGER,
    description TEXT DEFAULT 'Aucune description' NOT NULL
);

COMMENT ON TABLE Filiere IS 'Filières et programmes d''études';

-- Table: Niveaux académiques
CREATE TABLE Niveau (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_id UUID REFERENCES Cycle(id),
    code VARCHAR(10) UNIQUE NOT NULL, -- Ex: 'L1', 'M1'
    ordre INTEGER NOT NULL, -- Pour le tri (1, 2, 3...)
    frais_scolarite DECIMAL(10,2),
    CONSTRAINT niveau_cycle_unique UNIQUE (cycle_id, code)
);

COMMENT ON TABLE Niveau IS 'Niveaux d''études dans chaque cycle';

-- Table: Classes
CREATE TABLE Classe (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL, -- Ex: 'L1-MATH'
    niveau_id UUID REFERENCES Niveau(id),
    filiere_id UUID REFERENCES Filiere(id),
    capacite_max INTEGER
);

COMMENT ON TABLE Classe IS 'Classes d''enseignement';

-- Table: Semestres
CREATE TABLE Semestre (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    annee_id UUID REFERENCES AnneeAcademique(id),
    code VARCHAR(10) NOT NULL, -- 'S1', 'S2'
    date_debut DATE,
    date_fin DATE,
    est_actif BOOLEAN DEFAULT FALSE,
    CONSTRAINT semestre_unique UNIQUE (annee_id, code)
);

COMMENT ON TABLE Semestre IS 'Semestres académiques';

-- Table: Promotions
CREATE TABLE promotions (
    id CHAR(5) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    niveau VARCHAR(50) NOT NULL,
    filiere_id UUID NOT NULL REFERENCES Filiere(id),
    annee_id UUID NOT NULL REFERENCES AnneeAcademique(id),
    CONSTRAINT promotion_unique UNIQUE (libelle, annee_id)
);

COMMENT ON TABLE promotions IS 'Promotions d''étudiants';



-- =============================================================
-- MODULE: Gestion des Ressources Humaines
-- =============================================================
-- Tables pour enseignants, départements, contrats et qualifications


-- Table: Départements
CREATE TABLE departements (
    id CHAR(5) PRIMARY KEY,
    designation VARCHAR(255) NOT NULL,
    categorie VARCHAR(50) NOT NULL CHECK (categorie IN ('Scientifique', 'Lettres', 'Technique')),
    directeur_id CHAR(5) NULL, -- Référence à ajouter après création enseignants
    date_creation DATE DEFAULT CURRENT_DATE
);

COMMENT ON TABLE departements IS 'Départements académiques';

-- Table: Enseignants
CREATE TABLE enseignants (
    id CHAR(5) PRIMARY KEY,
    departement_id CHAR(5) NOT NULL REFERENCES departements(id),
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    datenais DATE NOT NULL CHECK (datenais > '1900-01-01'),
    lieunais VARCHAR(100),
    sexe CHAR(1) CHECK (sexe IN ('M', 'F')),
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    tel1 VARCHAR(20) NOT NULL,
    tel2 VARCHAR(20),
    matrimonial VARCHAR(15) CHECK (matrimonial IN ('Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)'))
);

COMMENT ON TABLE enseignants IS 'Profils des enseignants';

ALTER TABLE departements 
ADD CONSTRAINT fk_directeur 
FOREIGN KEY (directeur_id) REFERENCES enseignants(id) ON DELETE SET NULL;

-- Table: Diplômes des enseignants
CREATE TABLE diplomes_enseignants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enseignant_id VARCHAR(5) NOT NULL REFERENCES enseignants(id) ON DELETE CASCADE,
    intitule VARCHAR(255) NOT NULL,
    specialite VARCHAR(255),
    etablissement VARCHAR(255) NOT NULL,
    annee_obtention INTEGER NOT NULL CHECK (annee_obtention BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    niveau VARCHAR(50) CHECK (niveau IN ('Licence', 'Master', 'Doctorat', 'HDR'))
);

COMMENT ON TABLE diplomes_enseignants IS 'Diplômes et qualifications des enseignants';

-- Table: Types de contrats
CREATE TABLE types_contrat (
    code VARCHAR(3) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    duree_max_mois INTEGER
);

COMMENT ON TABLE types_contrat IS 'Types de contrats de travail';

-- Table: Contrats des enseignants
CREATE TABLE contrats (
    id VARCHAR(5) PRIMARY KEY,
    enseignant_id VARCHAR(5) NOT NULL REFERENCES enseignants(id),
    type_contrat VARCHAR(3) NOT NULL REFERENCES types_contrat(code),
    annee_id UUID NOT NULL REFERENCES AnneeAcademique(id),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    heures_statutaires INTEGER NOT NULL CHECK (heures_statutaires > 0),
    CONSTRAINT dates_coherentes CHECK (date_fin > date_debut)
);

COMMENT ON TABLE contrats IS 'Contrats de travail des enseignants';

-- Table: Historique des contrats
CREATE TABLE historique_contrats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrat_id CHAR(5) NOT NULL,
    date_modif TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modifie_par VARCHAR(100) NOT NULL,
    anciennes_valeurs JSONB NOT NULL
);

COMMENT ON TABLE historique_contrats IS 'Historique des modifications de contrats';



-- =============================================================
-- MODULE: Gestion des Utilisateurs et Sécurité
-- =============================================================
-- Tables pour authentification et gestion des accès

-- Table: Utilisateurs
CREATE TABLE Utilisateur (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50),
    actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Utilisateur IS 'Comptes utilisateurs (legacy)';

-- Table: Utilisateurs (version actualisée)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50),
    actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS 'Utilisateurs du système';

-- Table: Pays/Nationalités
CREATE TABLE pays (
    code_iso CHAR(2) PRIMARY KEY,
    nom_pays VARCHAR(100) NOT NULL,
    nationalite VARCHAR(100) NOT NULL
);

COMMENT ON TABLE pays IS 'Référentiel des pays';

-- Table: Logs d'import
CREATE TABLE import_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_import VARCHAR(50) NOT NULL,
    fichier_source VARCHAR(255) NOT NULL,
    nombre_enregistrements INTEGER,
    nombre_erreurs INTEGER,
    statut VARCHAR(20),
    date_import TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE import_logs IS 'Historique des imports de données';


-- =============================================================
-- MODULE: Gestion Pédagogique et Emploi du Temps
-- =============================================================
-- Tables pour modules, cours, horaires et ressources pédagogiques

-- Table: Modules/Cours
CREATE TABLE Module (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL,
    designation VARCHAR(100) NOT NULL,
    credit INTEGER NOT NULL,
    coefficient INTEGER DEFAULT 1,
    volume_horaire INTEGER, -- en heures
    responsable_id VARCHAR(5) REFERENCES enseignants(id)
);

COMMENT ON TABLE Module IS 'Modules d''enseignement';

-- Table: Lien Module-Classe-Enseignant
CREATE TABLE ModuleClasse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES Module(id),
    classe_id UUID REFERENCES Classe(id),
    semestre_id UUID REFERENCES Semestre(id),
    enseignant_id CHAR(5) REFERENCES enseignants(id),
    CONSTRAINT module_classe_unique UNIQUE (module_id, classe_id, semestre_id, enseignant_id)
);

COMMENT ON TABLE ModuleClasse IS 'Association module-classe-enseignant';

CREATE TABLE salles (
    id CHAR(5) PRIMARY KEY,
    batiment VARCHAR(50) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    capacite INTEGER CHECK (capacite > 0),
    type VARCHAR(50) CHECK (type IN ('Amphi', 'Cours', 'TD', 'TP', 'Labo'))
);

COMMENT ON TABLE salles IS 'Salles de classe et amphithéâtres';

-- Table: Types de cours
CREATE TABLE types_cours (
    code CHAR(2) PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL,
    couleur VARCHAR(7) DEFAULT '#FFFFFF'
);

COMMENT ON TABLE types_cours IS 'Types de cours (Amphi, TD, TP, etc.)';

-- Table: Cours planifiés
CREATE TABLE cours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_classe_id UUID NOT NULL REFERENCES ModuleClasse(id),
    type_cours_code CHAR(2) REFERENCES types_cours(code),
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL,
    salle_id CHAR(5) REFERENCES salles(id),
    CONSTRAINT cours_unique UNIQUE (module_classe_id, date_debut, date_fin)
);

COMMENT ON TABLE cours IS 'Sessions de cours planifiées';

-- Table: Créneaux horaires (simples)
CREATE TABLE creneaux (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enseignant_id CHAR(5) NOT NULL REFERENCES enseignants(id),
    module_id UUID NOT NULL REFERENCES Module(id),
    salle_id CHAR(5) NOT NULL REFERENCES salles(id),
    type_cours CHAR(2) NOT NULL REFERENCES types_cours(code),
    semestre_id UUID NOT NULL REFERENCES Semestre(id),
    jour VARCHAR(8) NOT NULL CHECK (jour IN ('LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI')),
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    CONSTRAINT duree_valide CHECK (heure_fin > heure_debut),
    CONSTRAINT pas_chevauchement UNIQUE (salle_id, jour, heure_debut, heure_fin)
);

COMMENT ON TABLE creneaux IS 'Créneaux horaires réguliers';

-- Table: Emploi du temps (avec classe)
CREATE TABLE schedule (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enseignant_id CHAR(5) NOT NULL REFERENCES enseignants(id),
    module_id UUID NOT NULL REFERENCES Module(id),
    salle_id CHAR(5) NOT NULL REFERENCES salles(id),
    classe_code VARCHAR(10) NOT NULL REFERENCES Classe(code),
    type_cours CHAR(2) NOT NULL REFERENCES types_cours(code),
    semestre_id UUID NOT NULL REFERENCES Semestre(id),
    jour VARCHAR(8) NOT NULL CHECK (jour IN ('LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI')),
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    CONSTRAINT duree_valide CHECK (heure_fin > heure_debut),
    CONSTRAINT pas_chevauchement_schedule UNIQUE (classe_code, jour, heure_debut, heure_fin),
    CONSTRAINT pas_chevauchement_horaire UNIQUE (enseignant_id, jour, heure_debut, heure_fin)
);

COMMENT ON TABLE schedule IS 'Emploi du temps avec classe';

-- Table: Supports de cours
CREATE TABLE support_de_cours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creneau_id UUID NOT NULL REFERENCES creneaux(id) ON DELETE CASCADE,
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('PDF', 'PPT', 'DOC', 'VIDEO', 'LIEN', 'AUTRE')),
    chemin_fichier VARCHAR(255),
    url VARCHAR(255),
    date_depot TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    visible BOOLEAN DEFAULT TRUE,
    auteur_id CHAR(5) NOT NULL REFERENCES enseignants(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE support_de_cours IS 'Ressources pédagogiques (cours, slides, etc.)';

-- =============================================================
-- MODULE: Gestion des Concours
-- =============================================================
-- Tables pour concours, candidatures et résultats

-- Table: Types de concours
CREATE TABLE types_concours (
    code VARCHAR(20) PRIMARY KEY,
    libelle VARCHAR(255) NOT NULL,
    dossier_requis BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE types_concours IS 'Types de concours (admission, recrutement, etc.)';

-- Table: Concours
CREATE TABLE concours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    designation VARCHAR(255) NOT NULL,
    type_concours VARCHAR(20) NOT NULL REFERENCES types_concours(code),
    description TEXT,
    annee_id UUID NOT NULL REFERENCES AnneeAcademique(id),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    date_limite_inscription DATE NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'planifié' 
        CHECK (statut IN ('planifié', 'ouvert', 'clôturé', 'annulé')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dates_coherentes CHECK (date_fin >= date_debut)
);

COMMENT ON TABLE concours IS 'Concours d''admission et de recrutement';

-- Table: Épreuves de concours
CREATE TABLE epreuves_concours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concours_id UUID NOT NULL REFERENCES concours(id) ON DELETE CASCADE,
    designation VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    coefficient INTEGER NOT NULL DEFAULT 1 CHECK (coefficient > 0),
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    ordre INTEGER DEFAULT 1 CHECK (ordre > 0),
    type_epreuve VARCHAR(20) CHECK (type_epreuve IN ('écrit', 'oral', 'pratique')),
    description TEXT
);

COMMENT ON TABLE epreuves_concours IS 'Épreuves d''un concours';

-- Table: Candidats
CREATE TABLE candidats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concours_id UUID NOT NULL REFERENCES concours(id),
    filiere VARCHAR(4) NOT NULL CHECK (filiere IN ('LAP', 'INF', 'DUT', 'AM', 'MT', 'ING')),
    matricule VARCHAR(20) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    datenais DATE NOT NULL CHECK (datenais > '1900-01-01'),
    lieunais VARCHAR(100) NOT NULL,
    sexe VARCHAR(10) NOT NULL,
    tel VARCHAR(20) NOT NULL CHECK (tel ~ '^\+?[0-9]{10,15}$'),
    email VARCHAR(255) CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    adresse TEXT,
    ville VARCHAR(100) NOT NULL,
    nationnalite VARCHAR(100) DEFAULT 'CONGOLAISE',
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unicite_candidature UNIQUE (nom, prenom, datenais, concours_id)
);

COMMENT ON TABLE candidats IS 'Candidats aux concours';

-- Table: Dossiers de candidature v2
CREATE TABLE dossiers_candidaturev2 (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    candidat_id UUID NOT NULL UNIQUE REFERENCES candidats(id) ON DELETE CASCADE,
    chemin_photo VARCHAR(255) NOT NULL,
    date_depot TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(20) DEFAULT 'incomplet' CHECK (statut IN ('incomplet', 'complet', 'verifie', 'rejete')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dossiers_candidaturev2 IS 'Dossiers de candidature';

-- Table: Pièces jointes
CREATE TABLE pieces_jointes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dossier_id UUID NOT NULL REFERENCES dossiers_candidaturev2(id) ON DELETE CASCADE,
    type_piece VARCHAR(50) NOT NULL CHECK (
        type_piece IN ('DIPLOME', 'ATTESTATION', 'PHOTO', 'CV', 'LETTRE', 'AUTRE')
    ),
    chemin_fichier VARCHAR(255) NOT NULL,
    est_obligatoire BOOLEAN DEFAULT TRUE,
    date_depot TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pieces_dossier ON pieces_jointes(dossier_id);
CREATE INDEX idx_pieces_type ON pieces_jointes(type_piece);

COMMENT ON TABLE pieces_jointes IS 'Pièces jointes aux dossiers';

-- Table: Résultats de concours v3
CREATE TABLE resultats_concoursv3 (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concours_id UUID NOT NULL REFERENCES concours(id) ON DELETE CASCADE,
    designation VARCHAR(255) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'en attente' CHECK (
        statut IN ('en attente', 'publié', 'archivé')
    ),
    date_publication TIMESTAMP,
    commentaire TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE resultats_concoursv3 IS 'Résultats compilés des concours';

-- Table: Notes des candidats
CREATE TABLE notes_candidats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    candidat_id UUID NOT NULL REFERENCES candidats(id) ON DELETE CASCADE,
    epreuve_id UUID NOT NULL REFERENCES epreuves_concours(id) ON DELETE CASCADE,
    note DECIMAL(5,2) CHECK (note >= 0 AND note <= 20),
    appreciation TEXT,
    correcteur VARCHAR(100),
    date_notation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unicite_note UNIQUE (candidat_id, epreuve_id)
);

COMMENT ON TABLE notes_candidats IS 'Notes des candidats pour chaque épreuve';

-- Table: Historique des concours
CREATE TABLE historique_concours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_affectee VARCHAR(50) NOT NULL CHECK (table_affectee IN ('concours', 'candidats', 'resultats')),
    operation CHAR(1) NOT NULL CHECK (operation IN ('I', 'U', 'D')),
    id_entite UUID NOT NULL,
    utilisateur VARCHAR(100) NOT NULL,
    horodatage TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    anciennes_valeurs JSONB,
    nouvelles_valeurs JSONB,
    ip_adresse INET
);

COMMENT ON TABLE historique_concours IS 'Audit et traçabilité des concours';


-- =============================================================
-- MODULE: Gestion des Étudiants
-- =============================================================
-- Tables pour profils étudiants, dossiers et parcours

-- Table: Étudiants
CREATE TABLE Etudiant (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matricule VARCHAR(20) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    sexe VARCHAR(10) NOT NULL,
    date_naissance DATE,
    lieu_naissance VARCHAR(255) NOT NULL,
    telephone VARCHAR(20),
    email VARCHAR(255) CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    ville VARCHAR(255) NOT NULL,
    filiere_id UUID REFERENCES Filiere(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Etudiant IS 'Profils des étudiants';

-- Table: Photos d'étudiants
CREATE TABLE photo_etudiant (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id) ON DELETE CASCADE,
    chemin_fichier VARCHAR(500) NOT NULL,
    nom_fichier VARCHAR(255),
    type_mime VARCHAR(50),
    taille INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(etudiant_id)
);

COMMENT ON TABLE photo_etudiant IS 'Photos d''identité des étudiants';

-- Table: Pièces de dossier
CREATE TABLE pieces_dossier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_piece VARCHAR(50) NOT NULL CHECK (type_piece IN ('DIPLOME', 'ATTESTATION', 'PHOTO', 'AUTRE')),
    chemin TEXT NOT NULL CHECK (chemin ~ '^/uploads/.*\.(pdf|jpg|png)$'),
    date_depot TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(20) DEFAULT 'EN_ATTENTE' CHECK (statut IN ('EN_ATTENTE', 'VALIDE', 'REJETE'))
);

COMMENT ON TABLE pieces_dossier IS 'Pièces constitutives du dossier';

-- Table: Dossiers étudiants
CREATE TABLE dossiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_etudiant UNIQUE (etudiant_id)
);

COMMENT ON TABLE dossiers IS 'Dossiers d''inscription des étudiants';

-- Table: Tuteurs/Responsables légaux
CREATE TABLE tuteurs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id) ON DELETE CASCADE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    tel1 VARCHAR(20) NOT NULL CHECK (tel1 ~ '^\+?[0-9]{10,15}$'),
    tel2 VARCHAR(20) CHECK (tel2 IS NULL OR tel2 ~ '^\+?[0-9]{10,15}$'),
    email VARCHAR(255) CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    nationalite CHAR(2) NOT NULL,
    adresse VARCHAR(50) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    lien_parente VARCHAR(50) CHECK (lien_parente IN ('PERE', 'MERE', 'TUTEUR', 'ONCLE', 'TANTE', 'FRERE', 'SOEUR', 'AUTRE')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tuteurs IS 'Responsables légaux des étudiants';

-- Table: Liaison dossier-pièces
CREATE TABLE dossier_pieces (
    dossier_id UUID NOT NULL REFERENCES dossiers(id) ON DELETE CASCADE,
    piece_id UUID NOT NULL REFERENCES pieces_dossier(id),
    PRIMARY KEY (dossier_id, piece_id)
);

COMMENT ON TABLE dossier_pieces IS 'Lien entre dossier et pièces jointes';

-- Table: Historique des dossiers
CREATE TABLE historique_dossiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dossier_id UUID NOT NULL,
    action VARCHAR(20) CHECK (action IN ('CREATION', 'MODIFICATION', 'VALIDATION')),
    details JSONB NOT NULL,
    utilisateur VARCHAR(100) NOT NULL,
    horodatage TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE historique_dossiers IS 'Suivi des modifications des dossiers';

-- Table: Cursus (parcours académiques)
CREATE TABLE Cursus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID REFERENCES Etudiant(id),
    classe_id UUID REFERENCES Classe(id),
    annee_academique_id UUID REFERENCES AnneeAcademique(id),
    date_inscription TIMESTAMP DEFAULT NOW(),
    statut VARCHAR(20) DEFAULT 'actif' CHECK (statut IN ('actif', 'abandon', 'diplômé')),
    CONSTRAINT cursus_unique UNIQUE (etudiant_id, classe_id, annee_academique_id)
);

COMMENT ON TABLE Cursus IS 'Parcours académiques des étudiants';

-- Table: Historique du cursus
CREATE TABLE HistoriqueCursus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID REFERENCES Etudiant(id),
    ancienne_classe_id UUID REFERENCES Classe(id),
    nouvelle_classe_id UUID REFERENCES Classe(id),
    ancienne_annee_academique_id UUID REFERENCES AnneeAcademique(id),
    nouvelle_annee_academique_id UUID REFERENCES AnneeAcademique(id),
    ancienne_niveau_id UUID REFERENCES Niveau(id),
    nouveau_niveau_id UUID REFERENCES Niveau(id),
    date_changement TIMESTAMP DEFAULT NOW(),
    raison_changement TEXT
);

COMMENT ON TABLE HistoriqueCursus IS 'Suivi des changements de classe/niveau';

-- Table: Diplômes des étudiants
CREATE TABLE diplomes_etudiant (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id) ON DELETE CASCADE,
    intitule VARCHAR(255) NOT NULL,
    specialite VARCHAR(255),
    etablissement VARCHAR(255) NOT NULL,
    annee_obtention INTEGER NOT NULL CHECK (annee_obtention BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    niveau VARCHAR(50) CHECK (niveau IN ('Licence', 'Master', 'Doctorat', 'Autre')),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE diplomes_etudiant IS 'Diplômes antérieurs des étudiants';

-- Table: Attestations de diplômes
CREATE TABLE attestations_diplomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id) ON DELETE CASCADE,
    diplome_id UUID NOT NULL REFERENCES diplomes_etudiant(id) ON DELETE CASCADE,
    reference VARCHAR(50) UNIQUE NOT NULL,
    date_emission DATE NOT NULL DEFAULT CURRENT_DATE,
    signature VARCHAR(255) NOT NULL,
    statut VARCHAR(20) DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'validée', 'rejetée')),
    observations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE attestations_diplomes IS 'Attestations de diplômes remises';

-- Table: Inscriptions
CREATE TABLE inscription (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id),
    classe_id UUID NOT NULL REFERENCES Classe(id),
    annee_academique_id UUID NOT NULL REFERENCES AnneeAcademique(id),
    date_inscription TIMESTAMP DEFAULT NOW(),
    statut VARCHAR(20) DEFAULT 'en attente' CHECK (statut IN ('en attente', 'validée', 'annulée')),
    gestionnaire_id UUID REFERENCES users(id),
    commentaire TEXT,
    CONSTRAINT inscription_unique UNIQUE (etudiant_id, classe_id, annee_academique_id)
);

COMMENT ON TABLE inscription IS 'Inscriptions annuelles des étudiants';

-- Table: Paiements d'inscription
CREATE TABLE paiement_inscription (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inscription_id UUID NOT NULL REFERENCES inscription(id) ON DELETE CASCADE,
    montant DECIMAL(10,2) NOT NULL CHECK (montant > 0),
    date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mode_paiement VARCHAR(50) CHECK (mode_paiement IN ('espece', 'mobile money', 'virement', 'chèque')),
    reference_transaction VARCHAR(100) UNIQUE,
    statut VARCHAR(20) DEFAULT 'en attente' CHECK (statut IN ('en attente', 'confirmé', 'échoué'))
);

COMMENT ON TABLE paiement_inscription IS 'Paiements liés aux inscriptions';


-- =============================================================
-- MODULE: Évaluations et Notes
-- =============================================================
-- Tables pour l'évaluation des étudiants et gestion des notes

-- Table: Évaluations
CREATE TABLE Evaluation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES Module(id),
    type VARCHAR(20) NOT NULL,  -- 'CC', 'TP', 'Examen', 'Projet'
    coefficient DECIMAL(3,2) DEFAULT 1.00,
    date_prevue DATE,
    ponderation INTEGER  -- Ex: 30 pour 30% du module
);

COMMENT ON TABLE Evaluation IS 'Types d''évaluation';

-- Table: Sessions d'évaluation
CREATE TABLE session_evaluation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    semestre_id UUID REFERENCES Semestre(id),
    annee_id UUID REFERENCES AnneeAcademique(id),
    code VARCHAR(20) UNIQUE NOT NULL,
    designation VARCHAR(100) NOT NULL,
    est_rappel BOOLEAN DEFAULT FALSE,
    etat VARCHAR(10) CHECK (etat IN ('inactive', 'active', 'archivé')),
    date_debut DATE,
    date_fin DATE,
    responsable VARCHAR(50) NOT NULL
);

COMMENT ON TABLE session_evaluation IS 'Sessions d''évaluation et examens';

-- Table: Notes
CREATE TABLE note (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID REFERENCES Etudiant(id),
    module_id UUID REFERENCES Module(id),
    classe_id UUID REFERENCES Classe(id),
    session_id UUID REFERENCES session_evaluation(id),
    note_controle DECIMAL(4,2) CHECK (note_controle BETWEEN 0 AND 20),
    note_partiel DECIMAL(4,2) CHECK (note_partiel BETWEEN 0 AND 20),
    note_rappel DECIMAL(4,2) CHECK (note_rappel IS NULL OR (note_rappel BETWEEN 0 AND 20)),
    statut VARCHAR(20) DEFAULT 'saisie' CHECK (statut IN ('saisie', 'validée', 'publiée')),
    CONSTRAINT unicite_notes UNIQUE (etudiant_id, module_id, session_id)
);

COMMENT ON TABLE note IS 'Notes des étudiants par module';


-- Table: Résultats
CREATE TABLE resultats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID REFERENCES Etudiant(id),
    semestre_id UUID REFERENCES Semestre(id),
    total_coef INTEGER DEFAULT 0,
    total_general DECIMAL(6,2) DEFAULT 0,
    moyenne DECIMAL(5,2) DEFAULT 0,
    rang INTEGER DEFAULT 0,
    effectif INTEGER DEFAULT 0,
    decision VARCHAR(50),  -- 'Admis', 'Rattrapage', 'Échec'
    date_publication TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT resultats_unique UNIQUE (etudiant_id, semestre_id)
);

COMMENT ON TABLE resultats IS 'Résultats globaux par semestre';

-- Table: Résultats de semestre (détaillés)
CREATE TABLE resultat_semestre (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id),
    semestre_id UUID NOT NULL REFERENCES Semestre(id),
    moyenne_generale DECIMAL(5,2),
    credits_obtenus INTEGER DEFAULT 0,
    credits_total INTEGER,
    total_coef INTEGER DEFAULT 0,
    total_general DECIMAL(6,2) DEFAULT 0,
    decision VARCHAR(50) CHECK (decision IN ('Admis', 'Ajourné', 'Passable', 'Assez Bien', 'Bien', 'Très Bien')),
    rang INTEGER,
    date_publication TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT resultat_unique UNIQUE (etudiant_id, semestre_id)
);

COMMENT ON TABLE resultat_semestre IS 'Résultats détaillés par semestre';

-- Table: Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id),
    message TEXT NOT NULL,
    date_envoi TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    lu BOOLEAN DEFAULT FALSE,
    type_notification VARCHAR(20) CHECK (type_notification IN ('alerte', 'information', 'rappel')),
    date_limite TIMESTAMPTZ
);

COMMENT ON TABLE notifications IS 'Notifications envoyées aux étudiants';

-- Table: Historique des notifications
CREATE TABLE historique_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id),
    date_modification TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modifie_par VARCHAR(100) NOT NULL,
    anciennes_valeurs JSONB NOT NULL,
    nouvelles_valeurs JSONB NOT NULL
);

COMMENT ON TABLE historique_notifications IS 'Suivi des modifications de notifications';


-- =============================================================
-- MODULE: Gestion Financière
-- =============================================================
-- Tables pour frais, paiements et audit financier

-- Table: Frais académiques
CREATE TABLE frais_academiques (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('SOUTENANCE', 'DIPLOME', 'BIBLIOTHEQUE')),
    montant DECIMAL(7,2) NOT NULL CHECK (montant > 0),
    montant_paye DECIMAL(7,2) NOT NULL DEFAULT 0 CHECK (montant_paye <= montant),
    date_emission TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_echeance DATE,
    statut VARCHAR(20),
    UNIQUE (etudiant_id, type)
);

COMMENT ON TABLE frais_academiques IS 'Frais académiques (soutenance, diplôme, etc.)';

-- Table: Frais de scolarité
CREATE TABLE frais_scolarite (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filiere_id UUID REFERENCES Filiere(id),
    annee VARCHAR(10) REFERENCES AnneeAcademique(code),
    montant_annuel NUMERIC(10,2) NOT NULL,
    montant_mensuel NUMERIC(10,2) NOT NULL,
    UNIQUE (filiere_id, annee)
);

COMMENT ON TABLE frais_scolarite IS 'Montants de scolarité par filière et année';

-- Table: Paiements de scolarité
CREATE TABLE paiement_scolarite (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference VARCHAR(50) UNIQUE,
    etudiant_id UUID REFERENCES Etudiant(id),
    classe_code VARCHAR(10) REFERENCES Classe(code),
    date_paiement DATE NOT NULL DEFAULT CURRENT_DATE,
    montant NUMERIC(10,2) NOT NULL,
    mode_paiement VARCHAR(50),
    type_paiement VARCHAR(20) CHECK (type_paiement IN ('mensuel', 'annuel')) NOT NULL,
    mois CHAR(7) NOT NULL CHECK (mois ~ '^[0-9]{4}-(0[1-9]|1[0-2])$')
);

COMMENT ON TABLE paiement_scolarite IS 'Paiements de scolarité des étudiants';

-- Table: Reçus de paiement
CREATE TABLE recus_paiement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paiement_id UUID NOT NULL REFERENCES paiement_scolarite(id),
    numero VARCHAR(20) UNIQUE,
    montant DECIMAL(10,2) NOT NULL,
    date_emission TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    qrcode BYTEA,
    signature_electronique TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE recus_paiement IS 'Reçus générés pour les paiements';

-- Table: Audit financier
CREATE TABLE audit_financier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_impactee VARCHAR(30) NOT NULL,
    action CHAR(1) NOT NULL CHECK (action IN ('C', 'U', 'D')),
    id_entite UUID NOT NULL,
    utilisateur VARCHAR(100) NOT NULL,
    anciennes_valeurs JSONB,
    nouvelles_valeurs JSONB,
    horodatage TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE audit_financier IS 'Traçabilité des opérations financières';

-- Table: Frais de soutenance
CREATE TABLE frais_soutenance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id),
    montant DECIMAL(10,2) NOT NULL CHECK (montant > 0),
    date_echeance DATE,
    statut_paiement VARCHAR(20) DEFAULT 'IMPAYE' CHECK (statut_paiement IN ('IMPAYE', 'PARTIEL', 'PAYE'))
);

COMMENT ON TABLE frais_soutenance IS 'Frais spécifiques pour les soutenances';



-- =============================================================
-- MODULE: Soutenances de Mémoire/Thèse
-- =============================================================
-- Tables pour planification et suivi des soutenances

-- Types d'état de soutenance
CREATE TYPE etat_soutenance AS ENUM (
    'PLANIFIEE', 
    'REPORTEE', 
    'ANNULEE', 
    'TERMINEE',
    'VALIDEE',
    'ECHEC'
);

-- Table: Salles de soutenance
CREATE TABLE salle_soutenance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(50) NOT NULL,
    capacite INTEGER CHECK (capacite > 0),
    batiment VARCHAR(50) NOT NULL,
    equipements TEXT[]
);

COMMENT ON TABLE salle_soutenance IS 'Salles dédiées aux soutenances';

-- Table: Soutenances
CREATE TABLE soutenances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES Etudiant(id) ON DELETE CASCADE,
    soutenance_ref VARCHAR(50) UNIQUE NOT NULL,
    soutenance_etat etat_soutenance NOT NULL DEFAULT 'PLANIFIEE',
    soutenance_theme TEXT NOT NULL,
    date_soutenance TIMESTAMPTZ NOT NULL,
    salle_id UUID NOT NULL REFERENCES salle_soutenance(id),
    no_ordre VARCHAR(10) NOT NULL CHECK (no_ordre ~ '^[A-Z]{1,2}-[0-9]{3}$'),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT date_future CHECK (date_soutenance > CURRENT_TIMESTAMP - INTERVAL '1 day')
);

COMMENT ON TABLE soutenances IS 'Soutenances de mémoire/thèse';

-- Table: Procès-verbaux de soutenance
CREATE TABLE pv_soutenance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    soutenance_id UUID NOT NULL REFERENCES soutenances(id) ON DELETE CASCADE,
    redige_par CHAR(5) NOT NULL REFERENCES enseignants(id),
    contenu TEXT,
    date_redaction TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_soutenance_unique UNIQUE (soutenance_id)
);

COMMENT ON TABLE pv_soutenance IS 'Procès-verbaux des soutenances';

-- Table: Jurys de soutenance
CREATE TABLE soutenance_jurys (
    soutenance_id UUID NOT NULL REFERENCES soutenances(id) ON DELETE CASCADE,
    enseignant_id CHAR(5) NOT NULL REFERENCES enseignants(id),
    role VARCHAR(50), -- 'Président', 'Rapporteur', 'Examinateur'
    note DECIMAL(4,2) CHECK (note BETWEEN 0 AND 20),
    PRIMARY KEY (soutenance_id, enseignant_id)
);

COMMENT ON TABLE soutenance_jurys IS 'Composition des jurys de soutenance';



-- =============================================================
-- MODULE: Planification et Gestion des Examens
-- =============================================================
-- Tables pour planification et supervision des examens

-- Table: Planification des examens
CREATE TABLE planification_examen (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES session_evaluation(id),
    filiere_id UUID NOT NULL REFERENCES Filiere(id),
    annee_id UUID NOT NULL REFERENCES AnneeAcademique(id),
    description TEXT,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    responsable VARCHAR(100),
    UNIQUE (session_id, filiere_id, annee_id)
);

COMMENT ON TABLE planification_examen IS 'Planification des sessions d''examens';

-- Table: Examens planifiés
CREATE TABLE examens_planifies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    planification_id UUID NOT NULL REFERENCES planification_examen(id),
    module_id UUID NOT NULL REFERENCES Module(id),
    classe_id UUID NOT NULL REFERENCES Classe(id),
    date_examen DATE NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    salle_id CHAR(5) REFERENCES salles(id),
    superviseur_id CHAR(5) REFERENCES enseignants(id)
);

COMMENT ON TABLE examens_planifies IS 'Examens planifiés avec horaires';

-- Table: Épreuves d'examen
CREATE TABLE epreuve_examen (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    examen_id UUID NOT NULL REFERENCES examens_planifies(id),
    numero_epreuve INTEGER NOT NULL,
    designation VARCHAR(255) NOT NULL,
    coefficient DECIMAL(3,2) DEFAULT 1.00,
    duree_minutes INTEGER NOT NULL CHECK (duree_minutes > 0),
    observation TEXT
);

COMMENT ON TABLE epreuve_examen IS 'Détails des épreuves d''examen';



-- =============================================================
-- MODULE: LLM & Vector Database Integration
-- =============================================================

-- Enable pgvector extension for vector search (if not already enabled)
CREATE EXTENSION IF NOT EXISTS vector;

-- Table: LLM Embeddings
CREATE TABLE llm_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- e.g., 'document', 'student', etc.
    entity_id UUID NOT NULL,          -- Reference to the entity
    embedding vector(1536) NOT NULL,  -- Adjust dimension if needed
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast vector similarity search
CREATE INDEX IF NOT EXISTS idx_llm_embeddings_vector ON llm_embeddings USING ivfflat (embedding vector_cosine_ops);

COMMENT ON TABLE llm_embeddings IS 'Vector embeddings for LLM integration (pgvector)';

COMMIT ; 