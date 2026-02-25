-- =============================================================
-- MODULE: Gestion Administrative Académique
-- =============================================================
-- Tables pour la gestion des années académiques, cycles,
-- filières, niveaux, classes et semestres


BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Table: Années académiques
CREATE TABLE IF NOT EXISTS academic_year (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL, -- Ex: '2023-2024'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    CONSTRAINT date_coherence CHECK (end_date > start_date)
);

COMMENT ON TABLE academic_year IS 'Années académiques du système';

-- Table: Cycles d'études

CREATE TABLE IF NOT EXISTS academic_cycle (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,          -- L, M, D
    label VARCHAR(100) NOT NULL,         -- Licence, Master, Doctorat
    diploma VARCHAR(150) NOT NULL,             -- Licence en ..., Master en ...
    duration_years INTEGER NOT NULL CHECK (duration_years > 0),
    total_credits INTEGER CHECK (total_credits > 0),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

COMMENT ON TABLE academic_cycle IS 'Cycles d''études (Licence, Master, Doctorat)';

-- Table: Filières/Programmes d'études
CREATE TABLE IF NOT EXISTS program (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    label VARCHAR(100) NOT NULL,
    cycle_id INTEGER REFERENCES academic_cycle(id),
    total_credits INTEGER,
    description TEXT DEFAULT 'Aucune description' NOT NULL
);

COMMENT ON TABLE program IS 'Filières et programmes d''études';

-- Table: Niveaux académiques
CREATE TABLE IF NOT EXISTS academic_level (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    cycle_id INTEGER REFERENCES academic_cycle(id),
    code VARCHAR(10) UNIQUE NOT NULL, -- Ex: 'L1', 'M1'
    order_num INTEGER NOT NULL, -- Pour le tri (1, 2, 3...)
    tuition_fee DECIMAL(10,2),
    CONSTRAINT level_cycle_unique UNIQUE (cycle_id, code)
);

COMMENT ON TABLE academic_level IS 'Niveaux d''études dans chaque cycle';

-- Table: Classes
CREATE TABLE IF NOT EXISTS class (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL, -- Ex: 'L1-MATH'
    level_id INTEGER REFERENCES academic_level(id),
    program_id INTEGER REFERENCES program(id),
    max_capacity INTEGER
);

COMMENT ON TABLE class IS 'Classes d''enseignement';

-- Table: Semestres
CREATE TABLE IF NOT EXISTS semester (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    year_id INTEGER REFERENCES academic_year(id),
    code VARCHAR(10) NOT NULL, -- 'S1', 'S2'
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT FALSE,
    CONSTRAINT semester_unique UNIQUE (year_id, code)
);

COMMENT ON TABLE semester IS 'Semestres académiques';

-- Table: Promotions
CREATE TABLE IF NOT EXISTS promotions (
    id CHAR(5) PRIMARY KEY,
    label VARCHAR(100) NOT NULL,
    level VARCHAR(50) NOT NULL,
    program_id INTEGER NOT NULL REFERENCES program(id),
    year_id INTEGER NOT NULL REFERENCES academic_year(id),
    CONSTRAINT promotion_unique UNIQUE (label, year_id)
);

COMMENT ON TABLE promotions IS 'Promotions d''étudiants';



-- =============================================================
-- MODULE: Gestion des Ressources Humaines
-- =============================================================
-- Tables pour enseignants, départements, contrats et qualifications


CREATE TABLE IF NOT EXISTS department (
    id CHAR(5) PRIMARY KEY,
    label VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('Scientifique', 'Lettres', 'Technique')),
    director_id CHAR(5) NULL, -- Référence à ajouter après création enseignants
    created_date DATE DEFAULT CURRENT_DATE
);

COMMENT ON TABLE department IS 'Départements académiques';

CREATE TABLE IF NOT EXISTS teacher (
    id CHAR(5) PRIMARY KEY,
    department_id CHAR(5) NOT NULL REFERENCES department(id),
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL CHECK (birth_date > '1900-01-01'),
    birth_place VARCHAR(100),
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    phone1 VARCHAR(20) NOT NULL,
    phone2 VARCHAR(20),
    marital_status VARCHAR(15) CHECK (marital_status IN ('Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)'))
);

COMMENT ON TABLE teacher IS 'Profils des enseignants';

ALTER TABLE department 
ADD CONSTRAINT fk_director 
FOREIGN KEY (director_id) REFERENCES teacher(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS teacher_degree (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    teacher_id VARCHAR(5) NOT NULL REFERENCES teacher(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    specialty VARCHAR(255),
    institution VARCHAR(255) NOT NULL,
    graduation_year INTEGER NOT NULL CHECK (graduation_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    level VARCHAR(50) CHECK (level IN ('Licence', 'Master', 'Doctorat', 'HDR'))
);

COMMENT ON TABLE teacher_degree IS 'Diplômes et qualifications des enseignants';

CREATE TABLE IF NOT EXISTS contract_type (
    code VARCHAR(3) PRIMARY KEY,
    label VARCHAR(100) NOT NULL,
    max_duration_months INTEGER
);

COMMENT ON TABLE contract_type IS 'Types de contrats de travail';

CREATE TABLE IF NOT EXISTS teacher_contract (
    id VARCHAR(5) PRIMARY KEY,
    teacher_id VARCHAR(5) NOT NULL REFERENCES teacher(id),
    contract_type VARCHAR(3) NOT NULL REFERENCES contract_type(code),
    year_id INTEGER NOT NULL REFERENCES academic_year(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    statutory_hours INTEGER NOT NULL CHECK (statutory_hours > 0),
    CONSTRAINT valid_dates CHECK (end_date > start_date)
);

COMMENT ON TABLE teacher_contract IS 'Contrats de travail des enseignants';

CREATE TABLE IF NOT EXISTS contract_history (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    contract_id CHAR(5) NOT NULL,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(100) NOT NULL,
    old_values JSONB NOT NULL
);
COMMENT ON TABLE contract_history IS 'Historique des modifications de contrats';


-- =============================================================
-- MODULE: Gestion des Utilisateurs et Sécurité
-- =============================================================
-- Tables pour authentification et gestion des accès

CREATE TABLE IF NOT EXISTS user_legacy (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE user_legacy IS 'Comptes utilisateurs (legacy)';

CREATE TABLE IF NOT EXISTS user_account (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE user_account IS 'Utilisateurs du système';

CREATE TABLE IF NOT EXISTS country (
    iso_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(100) NOT NULL
);

COMMENT ON TABLE country IS 'Référentiel des pays';

CREATE TABLE IF NOT EXISTS import_log (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    import_type VARCHAR(50) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    record_count INTEGER,
    error_count INTEGER,
    status VARCHAR(20),
    import_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE import_log IS 'Historique des imports de données';


-- =============================================================
-- MODULE: Gestion Pédagogique et Emploi du Temps
-- =============================================================
-- Tables pour modules, cours, horaires et ressources pédagogiques

CREATE TABLE IF NOT EXISTS course_module (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    label VARCHAR(100) NOT NULL,
    credits INTEGER NOT NULL,
    coefficient INTEGER DEFAULT 1,
    hours_volume INTEGER, -- en heures
    teacher_id VARCHAR(5) REFERENCES teacher(id)
);

COMMENT ON TABLE course_module IS 'Modules d''enseignement';

CREATE TABLE IF NOT EXISTS module_class (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    module_id INTEGER REFERENCES course_module(id),
    class_id INTEGER REFERENCES class(id),
    semester_id INTEGER REFERENCES semester(id),
    teacher_id CHAR(5) REFERENCES teacher(id),
    CONSTRAINT module_class_unique UNIQUE (module_id, class_id, semester_id, teacher_id)
);

COMMENT ON TABLE module_class IS 'Association module-classe-enseignant';

CREATE TABLE IF NOT EXISTS classroom (
    id CHAR(5) PRIMARY KEY,
    building VARCHAR(50) NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    capacity INTEGER CHECK (capacity > 0),
    type VARCHAR(50) CHECK (type IN ('Amphi', 'Cours', 'TD', 'TP', 'Labo'))
);

COMMENT ON TABLE classroom IS 'Salles de classe et amphithéâtres';

CREATE TABLE IF NOT EXISTS course_type (
    code CHAR(2) PRIMARY KEY,
    label VARCHAR(50) NOT NULL,
    color VARCHAR(7) DEFAULT '#FFFFFF'
);

COMMENT ON TABLE course_type IS 'Types de cours (Amphi, TD, TP, etc.)';

CREATE TABLE IF NOT EXISTS planned_course (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    module_class_id INTEGER NOT NULL REFERENCES module_class(id),
    course_type_code CHAR(2) REFERENCES course_type(code),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    classroom_id CHAR(5) REFERENCES classroom(id),
    CONSTRAINT planned_course_unique UNIQUE (module_class_id, start_date, end_date)
);

COMMENT ON TABLE planned_course IS 'Sessions de cours planifiées';

CREATE TABLE IF NOT EXISTS time_slot (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    teacher_id CHAR(5) NOT NULL REFERENCES teacher(id),
    module_id INTEGER NOT NULL REFERENCES course_module(id),
    classroom_id CHAR(5) NOT NULL REFERENCES classroom(id),
    course_type CHAR(2) NOT NULL REFERENCES course_type(code),
    semester_id INTEGER NOT NULL REFERENCES semester(id),
    day VARCHAR(8) NOT NULL CHECK (day IN ('LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT valid_duration CHECK (end_time > start_time),
    CONSTRAINT no_overlap UNIQUE (classroom_id, day, start_time, end_time)
);

COMMENT ON TABLE time_slot IS 'Créneaux horaires réguliers';

CREATE TABLE IF NOT EXISTS class_schedule (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    teacher_id CHAR(5) NOT NULL REFERENCES teacher(id),
    module_id INTEGER NOT NULL REFERENCES course_module(id),
    classroom_id CHAR(5) NOT NULL REFERENCES classroom(id),
    class_code VARCHAR(10) NOT NULL REFERENCES class(code),
    course_type CHAR(2) NOT NULL REFERENCES course_type(code),
    semester_id INTEGER NOT NULL REFERENCES semester(id),
    day VARCHAR(8) NOT NULL CHECK (day IN ('LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT valid_duration CHECK (end_time > start_time),
    CONSTRAINT no_overlap_schedule UNIQUE (class_code, day, start_time, end_time),
    CONSTRAINT no_overlap_teacher UNIQUE (teacher_id, day, start_time, end_time)
);

COMMENT ON TABLE class_schedule IS 'Emploi du temps avec classe';

CREATE TABLE IF NOT EXISTS course_material (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    time_slot_id INTEGER NOT NULL REFERENCES time_slot(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('PDF', 'PPT', 'DOC', 'VIDEO', 'LIEN', 'AUTRE')),
    file_path VARCHAR(255),
    url VARCHAR(255),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_visible BOOLEAN DEFAULT TRUE,
    author_id CHAR(5) NOT NULL REFERENCES teacher(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE course_material IS 'Ressources pédagogiques (cours, slides, etc.)';

-- =============================================================
-- MODULE: Gestion des Concours
-- =============================================================
-- Tables pour concours, candidatures et résultats

CREATE TABLE IF NOT EXISTS contest_type (
    code VARCHAR(20) PRIMARY KEY,
    label VARCHAR(255) NOT NULL,
    file_required BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE contest_type IS 'Types de concours (admission, recrutement, etc.)';

CREATE TABLE IF NOT EXISTS contest (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    label VARCHAR(255) NOT NULL,
    contest_type VARCHAR(20) NOT NULL REFERENCES contest_type(code),
    description TEXT,
    year_id INTEGER NOT NULL REFERENCES academic_year(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_deadline DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'planifié' 
        CHECK (status IN ('planifié', 'ouvert', 'clôturé', 'annulé')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_dates CHECK (end_date >= start_date)
);

COMMENT ON TABLE contest IS 'Concours d''admission et de recrutement';

CREATE TABLE IF NOT EXISTS contest_exam (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    contest_id INTEGER NOT NULL REFERENCES contest(id) ON DELETE CASCADE,
    label VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    coefficient INTEGER NOT NULL DEFAULT 1 CHECK (coefficient > 0),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    order_num INTEGER DEFAULT 1 CHECK (order_num > 0),
    exam_type VARCHAR(20) CHECK (exam_type IN ('écrit', 'oral', 'pratique')),
    description TEXT
);

COMMENT ON TABLE contest_exam IS 'Épreuves d''un concours';

CREATE TABLE IF NOT EXISTS candidate (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    contest_id INTEGER NOT NULL REFERENCES contest(id),
    program VARCHAR(4) NOT NULL CHECK (program IN ('LAP', 'INF', 'DUT', 'AM', 'MT', 'ING')),
    registration_number VARCHAR(20) NOT NULL UNIQUE,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL CHECK (birth_date > '1900-01-01'),
    birth_place VARCHAR(100) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(20) NOT NULL CHECK (phone ~ '^\+?[0-9]{10,15}$'),
    email VARCHAR(255) CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    address TEXT,
    city VARCHAR(100) NOT NULL,
    nationality VARCHAR(100) DEFAULT 'CONGOLAISE',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_candidate UNIQUE (last_name, first_name, birth_date, contest_id)
);

COMMENT ON TABLE candidate IS 'Candidats aux concours';

CREATE TABLE IF NOT EXISTS candidate_file (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    candidate_id INTEGER NOT NULL UNIQUE REFERENCES candidate(id) ON DELETE CASCADE,
    photo_path VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'incomplet' CHECK (status IN ('incomplet', 'complet', 'verifie', 'rejete')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE candidate_file IS 'Dossiers de candidature';

CREATE TABLE IF NOT EXISTS attachment (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    candidate_file_id INTEGER NOT NULL REFERENCES candidate_file(id) ON DELETE CASCADE,
    attachment_type VARCHAR(50) NOT NULL CHECK (
        attachment_type IN ('DIPLOME', 'ATTESTATION', 'PHOTO', 'CV', 'LETTRE', 'AUTRE')
    ),
    file_path VARCHAR(255) NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attachment_candidate_file ON attachment(candidate_file_id);
CREATE INDEX idx_attachment_type ON attachment(attachment_type);

COMMENT ON TABLE attachment IS 'Pièces jointes aux dossiers';

CREATE TABLE IF NOT EXISTS contest_result (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    contest_id INTEGER NOT NULL REFERENCES contest(id) ON DELETE CASCADE,
    label VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'en attente' CHECK (
        status IN ('en attente', 'publié', 'archivé')
    ),
    publication_date TIMESTAMP,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contest_result IS 'Résultats compilés des concours';

CREATE TABLE IF NOT EXISTS candidate_grade (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id) ON DELETE CASCADE,
    contest_exam_id INTEGER NOT NULL REFERENCES contest_exam(id) ON DELETE CASCADE,
    grade DECIMAL(5,2) CHECK (grade >= 0 AND grade <= 20),
    appreciation TEXT,
    grader VARCHAR(100),
    grading_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_grade UNIQUE (candidate_id, contest_exam_id)
);

COMMENT ON TABLE candidate_grade IS 'Notes des candidats pour chaque épreuve';

CREATE TABLE IF NOT EXISTS contest_history (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    affected_table VARCHAR(50) NOT NULL CHECK (affected_table IN ('contest', 'candidate', 'result')),
    operation CHAR(1) NOT NULL CHECK (operation IN ('I', 'U', 'D')),
    entity_id INTEGER NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    old_values JSONB,
    new_values JSONB,
    ip_address INET
);

COMMENT ON TABLE contest_history IS 'Audit et traçabilité des concours';


-- =============================================================
-- MODULE: Gestion des Étudiants
-- =============================================================
-- Tables pour profils étudiants, dossiers et parcours

CREATE TABLE IF NOT EXISTS student (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    birth_date DATE,
    birth_place VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255) CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    city VARCHAR(255) NOT NULL,
    program_id INTEGER REFERENCES program(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE student IS 'Profils des étudiants';

CREATE TABLE IF NOT EXISTS student_photo (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255),
    mime_type VARCHAR(50),
    size INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id)
);

COMMENT ON TABLE student_photo IS 'Photos d''identité des étudiants';

CREATE TABLE IF NOT EXISTS student_file_piece (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    piece_type VARCHAR(50) NOT NULL CHECK (piece_type IN ('DIPLOME', 'ATTESTATION', 'PHOTO', 'AUTRE')),
    file_path TEXT NOT NULL CHECK (file_path ~ '^/uploads/.*\.(pdf|jpg|png)$'),
    upload_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'EN_ATTENTE' CHECK (status IN ('EN_ATTENTE', 'VALIDE', 'REJETE'))
);

COMMENT ON TABLE student_file_piece IS 'Pièces constitutives du dossier';

CREATE TABLE IF NOT EXISTS student_file (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) NOT NULL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT unique_student UNIQUE (student_id)
);

COMMENT ON TABLE student_file IS 'Dossiers d''inscription des étudiants';

CREATE TABLE IF NOT EXISTS student_guardian (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id) ON DELETE CASCADE,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    phone1 VARCHAR(20) NOT NULL CHECK (phone1 ~ '^\+?[0-9]{10,15}$'),
    phone2 VARCHAR(20) CHECK (phone2 IS NULL OR phone2 ~ '^\+?[0-9]{10,15}$'),
    email VARCHAR(255) CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    nationality CHAR(2) NOT NULL,
    address VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    relationship VARCHAR(50) CHECK (relationship IN ('PERE', 'MERE', 'TUTEUR', 'ONCLE', 'TANTE', 'FRERE', 'SOEUR', 'AUTRE')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE student_guardian IS 'Responsables légaux des étudiants';

CREATE TABLE IF NOT EXISTS student_file_attachment (
    student_file_id INTEGER NOT NULL REFERENCES student_file(id) ON DELETE CASCADE,
    file_piece_id INTEGER NOT NULL REFERENCES student_file_piece(id),
    PRIMARY KEY (student_file_id, file_piece_id)
);

COMMENT ON TABLE student_file_attachment IS 'Lien entre dossier et pièces jointes';

CREATE TABLE IF NOT EXISTS student_file_history (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_file_id INTEGER NOT NULL,
    action VARCHAR(20) CHECK (action IN ('CREATION', 'MODIFICATION', 'VALIDATION')),
    details JSONB NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE student_file_history IS 'Suivi des modifications des dossiers';

CREATE TABLE IF NOT EXISTS academic_path (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    class_id INTEGER REFERENCES class(id),
    academic_year_id INTEGER REFERENCES academic_year(id),
    registration_date TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'actif' CHECK (status IN ('actif', 'abandon', 'diplômé')),
    CONSTRAINT unique_academic_path UNIQUE (student_id, class_id, academic_year_id)
);

COMMENT ON TABLE academic_path IS 'Parcours académiques des étudiants';

CREATE TABLE IF NOT EXISTS academic_path_history (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    old_class_id INTEGER REFERENCES class(id),
    new_class_id INTEGER REFERENCES class(id),
    old_academic_year_id INTEGER REFERENCES academic_year(id),
    new_academic_year_id INTEGER REFERENCES academic_year(id),
    old_level_id INTEGER REFERENCES academic_level(id),
    new_level_id INTEGER REFERENCES academic_level(id),
    change_date TIMESTAMP DEFAULT NOW(),
    change_reason TEXT
);

COMMENT ON TABLE academic_path_history IS 'Suivi des changements de classe/niveau';

CREATE TABLE IF NOT EXISTS student_degree (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    specialty VARCHAR(255),
    institution VARCHAR(255) NOT NULL,
    graduation_year INTEGER NOT NULL CHECK (graduation_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    level VARCHAR(50) CHECK (level IN ('Licence', 'Master', 'Doctorat', 'Autre')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE student_degree IS 'Diplômes antérieurs des étudiants';

CREATE TABLE IF NOT EXISTS degree_certificate (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id) ON DELETE CASCADE,
    degree_id INTEGER NOT NULL REFERENCES student_degree(id) ON DELETE CASCADE,
    reference VARCHAR(50) UNIQUE NOT NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    signature VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'en_attente' CHECK (status IN ('en_attente', 'validée', 'rejetée')),
    observations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE degree_certificate IS 'Attestations de diplômes remises';

CREATE TABLE IF NOT EXISTS registration (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id),
    class_id INTEGER NOT NULL REFERENCES class(id),
    academic_year_id INTEGER NOT NULL REFERENCES academic_year(id),
    registration_date TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'en attente' CHECK (status IN ('en attente', 'validée', 'annulée')),
    manager_id INTEGER REFERENCES user_account(id),
    comment TEXT,
    CONSTRAINT unique_registration UNIQUE (student_id, class_id, academic_year_id)
);

COMMENT ON TABLE registration IS 'Inscriptions annuelles des étudiants';

CREATE TABLE IF NOT EXISTS registration_payment (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    registration_id INTEGER NOT NULL REFERENCES registration(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) CHECK (payment_method IN ('espece', 'mobile money', 'virement', 'chèque')),
    transaction_reference VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'en attente' CHECK (status IN ('en attente', 'confirmé', 'échoué'))
);

COMMENT ON TABLE registration_payment IS 'Paiements liés aux inscriptions';


-- =============================================================
-- MODULE: Évaluations et Notes
-- =============================================================
-- Tables pour l'évaluation des étudiants et gestion des notes

CREATE TABLE IF NOT EXISTS evaluation (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    module_id INTEGER REFERENCES course_module(id),
    type VARCHAR(20) NOT NULL,  -- 'CC', 'TP', 'Examen', 'Projet'
    coefficient DECIMAL(3,2) DEFAULT 1.00,
    planned_date DATE,
    weighting INTEGER  -- Ex: 30 pour 30% du module
);

COMMENT ON TABLE evaluation IS 'Types d''évaluation';

CREATE TABLE IF NOT EXISTS evaluation_session (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    semester_id INTEGER REFERENCES semester(id),
    year_id INTEGER REFERENCES academic_year(id),
    code VARCHAR(20) UNIQUE NOT NULL,
    label VARCHAR(100) NOT NULL,
    is_reminder BOOLEAN DEFAULT FALSE,
    status VARCHAR(10) CHECK (status IN ('inactive', 'active', 'archivé')),
    start_date DATE,
    end_date DATE,
    manager VARCHAR(50) NOT NULL
);

COMMENT ON TABLE evaluation_session IS 'Sessions d''évaluation et examens';

CREATE TABLE IF NOT EXISTS student_grade (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    module_id INTEGER REFERENCES course_module(id),
    class_id INTEGER REFERENCES class(id),
    session_id INTEGER REFERENCES evaluation_session(id),
    control_grade DECIMAL(4,2) CHECK (control_grade BETWEEN 0 AND 20),
    partial_grade DECIMAL(4,2) CHECK (partial_grade BETWEEN 0 AND 20),
    reminder_grade DECIMAL(4,2) CHECK (reminder_grade IS NULL OR (reminder_grade BETWEEN 0 AND 20)),
    status VARCHAR(20) DEFAULT 'saisie' CHECK (status IN ('saisie', 'validée', 'publiée')),
    CONSTRAINT unique_student_grade UNIQUE (student_id, module_id, session_id)
);

COMMENT ON TABLE student_grade IS 'Notes des étudiants par module';


CREATE TABLE IF NOT EXISTS student_semester_result (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER REFERENCES student(id),
    semester_id INTEGER REFERENCES semester(id),
    total_coefficient INTEGER DEFAULT 0,
    total_score DECIMAL(6,2) DEFAULT 0,
    average DECIMAL(5,2) DEFAULT 0,
    rank INTEGER DEFAULT 0,
    total_students INTEGER DEFAULT 0,
    decision VARCHAR(50),  -- 'Admis', 'Rattrapage', 'Échec'
    publication_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_student_semester_result UNIQUE (student_id, semester_id)
);

COMMENT ON TABLE student_semester_result IS 'Résultats globaux par semestre';

CREATE TABLE IF NOT EXISTS student_semester_result_detail (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id),
    semester_id INTEGER NOT NULL REFERENCES semester(id),
    general_average DECIMAL(5,2),
    credits_earned INTEGER DEFAULT 0,
    total_credits INTEGER,
    total_coefficient INTEGER DEFAULT 0,
    total_score DECIMAL(6,2) DEFAULT 0,
    decision VARCHAR(50) CHECK (decision IN ('Admis', 'Ajourné', 'Passable', 'Assez Bien', 'Bien', 'Très Bien')),
    rank INTEGER,
    publication_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_student_semester_result_detail UNIQUE (student_id, semester_id)
);

COMMENT ON TABLE student_semester_result_detail IS 'Résultats détaillés par semestre';

CREATE TABLE IF NOT EXISTS student_notification (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id),
    message TEXT NOT NULL,
    sent_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    notification_type VARCHAR(20) CHECK (notification_type IN ('alerte', 'information', 'rappel')),
    deadline TIMESTAMPTZ
);

COMMENT ON TABLE student_notification IS 'Notifications envoyées aux étudiants';

CREATE TABLE IF NOT EXISTS student_notification_history (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    notification_id INTEGER NOT NULL REFERENCES student_notification(id),
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(100) NOT NULL,
    old_values JSONB NOT NULL,
    new_values JSONB NOT NULL
);

COMMENT ON TABLE student_notification_history IS 'Suivi des modifications de notifications';


-- =============================================================
-- MODULE: Gestion Financière
-- =============================================================
-- Tables pour frais, paiements et audit financier

CREATE TABLE IF NOT EXISTS academic_fee (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('SOUTENANCE', 'DIPLOME', 'BIBLIOTHEQUE')),
    amount DECIMAL(7,2) NOT NULL CHECK (amount > 0),
    amount_paid DECIMAL(7,2) NOT NULL DEFAULT 0 CHECK (amount_paid <= amount),
    issue_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE,
    status VARCHAR(20),
    UNIQUE (student_id, type)
);

COMMENT ON TABLE academic_fee IS 'Frais académiques (soutenance, diplôme, etc.)';

CREATE TABLE IF NOT EXISTS tuition_fee (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    program_id INTEGER REFERENCES program(id),
    year VARCHAR(10) REFERENCES academic_year(code),
    annual_amount NUMERIC(10,2) NOT NULL,
    monthly_amount NUMERIC(10,2) NOT NULL,
    UNIQUE (program_id, year)
);

COMMENT ON TABLE tuition_fee IS 'Montants de scolarité par filière et année';

CREATE TABLE IF NOT EXISTS tuition_payment (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    reference VARCHAR(50) UNIQUE,
    student_id INTEGER REFERENCES student(id),
    class_code VARCHAR(10) REFERENCES class(code),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_type VARCHAR(20) CHECK (payment_type IN ('mensuel', 'annuel')) NOT NULL,
    month CHAR(7) NOT NULL CHECK (month ~ '^[0-9]{4}-(0[1-9]|1[0-2])$')
);

COMMENT ON TABLE tuition_payment IS 'Paiements de scolarité des étudiants';

CREATE TABLE IF NOT EXISTS payment_receipt (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    payment_id INTEGER NOT NULL REFERENCES tuition_payment(id),
    number VARCHAR(20) UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    issue_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    qrcode BYTEA,
    electronic_signature TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE payment_receipt IS 'Reçus générés pour les paiements';

CREATE TABLE IF NOT EXISTS financial_audit (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    affected_table VARCHAR(30) NOT NULL,
    action CHAR(1) NOT NULL CHECK (action IN ('C', 'U', 'D')),
    entity_id INTEGER NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE financial_audit IS 'Traçabilité des opérations financières';

CREATE TABLE IF NOT EXISTS thesis_fee (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    due_date DATE,
    payment_status VARCHAR(20) DEFAULT 'IMPAYE' CHECK (payment_status IN ('IMPAYE', 'PARTIEL', 'PAYE'))
);

COMMENT ON TABLE thesis_fee IS 'Frais spécifiques pour les soutenances';



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

CREATE TABLE IF NOT EXISTS defense_room (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    capacity INTEGER CHECK (capacity > 0),
    building VARCHAR(50) NOT NULL,
    equipment TEXT[]
);

COMMENT ON TABLE defense_room IS 'Salles dédiées aux soutenances';

CREATE TABLE IF NOT EXISTS defense (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES student(id) ON DELETE CASCADE,
    reference VARCHAR(50) UNIQUE NOT NULL,
    status etat_soutenance NOT NULL DEFAULT 'PLANIFIEE',
    theme TEXT NOT NULL,
    defense_date TIMESTAMPTZ NOT NULL,
    room_id INTEGER NOT NULL REFERENCES defense_room(id),
    order_number VARCHAR(10) NOT NULL CHECK (order_number ~ '^[A-Z]{1,2}-[0-9]{3}$'),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT future_date CHECK (defense_date > CURRENT_TIMESTAMP - INTERVAL '1 day')
);

COMMENT ON TABLE defense IS 'Soutenances de mémoire/thèse';

CREATE TABLE IF NOT EXISTS defense_report (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    defense_id INTEGER NOT NULL REFERENCES defense(id) ON DELETE CASCADE,
    written_by CHAR(5) NOT NULL REFERENCES teacher(id),
    content TEXT,
    written_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_defense_report UNIQUE (defense_id)
);

COMMENT ON TABLE defense_report IS 'Procès-verbaux des soutenances';

CREATE TABLE IF NOT EXISTS defense_jury (
    defense_id INTEGER NOT NULL REFERENCES defense(id) ON DELETE CASCADE,
    teacher_id CHAR(5) NOT NULL REFERENCES teacher(id),
    role VARCHAR(50), -- 'Président', 'Rapporteur', 'Examinateur'
    grade DECIMAL(4,2) CHECK (grade BETWEEN 0 AND 20),
    PRIMARY KEY (defense_id, teacher_id)
);

COMMENT ON TABLE defense_jury IS 'Composition des jurys de soutenance';



-- =============================================================
-- MODULE: Planification et Gestion des Examens
-- =============================================================
-- Tables pour planification et supervision des examens

CREATE TABLE IF NOT EXISTS exam_planning (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES evaluation_session(id),
    program_id INTEGER NOT NULL REFERENCES program(id),
    year_id INTEGER NOT NULL REFERENCES academic_year(id),
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    manager VARCHAR(100),
    UNIQUE (session_id, program_id, year_id)
);

COMMENT ON TABLE exam_planning IS 'Planification des sessions d''examens';

CREATE TABLE IF NOT EXISTS planned_exam (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    planning_id INTEGER NOT NULL REFERENCES exam_planning(id),
    module_id INTEGER NOT NULL REFERENCES course_module(id),
    class_id INTEGER NOT NULL REFERENCES class(id),
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    classroom_id CHAR(5) REFERENCES classroom(id),
    supervisor_id CHAR(5) REFERENCES teacher(id)
);

COMMENT ON TABLE planned_exam IS 'Examens planifiés avec horaires';

CREATE TABLE IF NOT EXISTS exam_test (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    exam_id INTEGER NOT NULL REFERENCES planned_exam(id),
    test_number INTEGER NOT NULL,
    label VARCHAR(255) NOT NULL,
    coefficient DECIMAL(3,2) DEFAULT 1.00,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    observation TEXT
);

COMMENT ON TABLE exam_test IS 'Détails des épreuves d''examen';



-- =============================================================
-- MODULE: LLM & Vector Database Integration
-- =============================================================

-- Enable pgvector extension for vector search (if not already enabled)
CREATE EXTENSION IF NOT EXISTS vector;

-- Table: LLM Embeddings
CREATE TABLE IF NOT EXISTS llm_embeddings (
    id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT BY 1) PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL, -- e.g., 'document', 'student', etc.
    entity_id INTEGER NOT NULL,       -- Reference to the entity
    embedding vector(1536) NOT NULL,  -- Adjust dimension if needed
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast vector similarity search
CREATE INDEX IF NOT EXISTS idx_llm_embeddings_vector ON llm_embeddings USING ivfflat (embedding vector_cosine_ops);

COMMENT ON TABLE llm_embeddings IS 'Vector embeddings for LLM integration (pgvector)';

COMMIT ; 