-- =============================
-- SEED DEV: Données de test
-- =============================

-- Table: AnneeAcademique
INSERT INTO AnneeAcademique (code, date_debut, date_fin, est_active) VALUES
  ('2022-2023', '2022-09-01', '2023-07-15', FALSE),
  ('2023-2024', '2023-09-01', '2024-07-15', TRUE),
  ('2021-2022', '2021-09-01', '2022-07-15', FALSE),
  ('2020-2021', '2020-09-01', '2021-07-15', FALSE),
  ('2019-2020', '2019-09-01', '2020-07-15', FALSE);

-- Table: Cycle
INSERT INTO Cycle (code, designation, diplome, duree_annees, credits_total, description) VALUES
  ('L', 'Licence', 'Licence en Informatique', 3, 180, 'Cycle Licence'),
  ('M', 'Master', 'Master en Informatique', 2, 120, 'Cycle Master'),
  ('D', 'Doctorat', 'Doctorat en Informatique', 3, 180, 'Cycle Doctorat'),
  ('LP', 'Licence Pro', 'Licence Professionnelle', 3, 180, 'Licence Pro'),
  ('MBA', 'MBA', 'Master of Business Administration', 2, 120, 'MBA Management');

-- Table: Filiere
INSERT INTO Filiere (code, designation, cycle_id, credit_total, description) VALUES
  ('INFO', 'Informatique', (SELECT id FROM Cycle WHERE code='L'), 180, 'Filière Informatique'),
  ('MATH', 'Mathématiques', (SELECT id FROM Cycle WHERE code='L'), 180, 'Filière Mathématiques'),
  ('PHY', 'Physique', (SELECT id FROM Cycle WHERE code='L'), 180, 'Filière Physique'),
  ('CHIM', 'Chimie', (SELECT id FROM Cycle WHERE code='L'), 180, 'Filière Chimie'),
  ('BIO', 'Biologie', (SELECT id FROM Cycle WHERE code='L'), 180, 'Filière Biologie');

-- Table: Niveau
INSERT INTO Niveau (cycle_id, code, ordre, frais_scolarite) VALUES
  ((SELECT id FROM Cycle WHERE code='L'), 'L1', 1, 250000),
  ((SELECT id FROM Cycle WHERE code='L'), 'L2', 2, 250000),
  ((SELECT id FROM Cycle WHERE code='L'), 'L3', 3, 250000),
  ((SELECT id FROM Cycle WHERE code='M'), 'M1', 1, 350000),
  ((SELECT id FROM Cycle WHERE code='M'), 'M2', 2, 350000);

-- Table: Classe
INSERT INTO Classe (code, niveau_id, filiere_id, capacite_max) VALUES
  ('L1-INFO', (SELECT id FROM Niveau WHERE code='L1'), (SELECT id FROM Filiere WHERE code='INFO'), 40),
  ('L2-INFO', (SELECT id FROM Niveau WHERE code='L2'), (SELECT id FROM Filiere WHERE code='INFO'), 35),
  ('L3-INFO', (SELECT id FROM Niveau WHERE code='L3'), (SELECT id FROM Filiere WHERE code='INFO'), 30),
  ('L1-MATH', (SELECT id FROM Niveau WHERE code='L1'), (SELECT id FROM Filiere WHERE code='MATH'), 40),
  ('L2-MATH', (SELECT id FROM Niveau WHERE code='L2'), (SELECT id FROM Filiere WHERE code='MATH'), 35);

-- Table: Semestre
INSERT INTO Semestre (annee_id, code, date_debut, date_fin, est_actif) VALUES
  ((SELECT id FROM AnneeAcademique WHERE code='2023-2024'), 'S1', '2023-09-01', '2024-01-15', TRUE),
  ((SELECT id FROM AnneeAcademique WHERE code='2023-2024'), 'S2', '2024-02-01', '2024-07-15', FALSE),
  ((SELECT id FROM AnneeAcademique WHERE code='2022-2023'), 'S1', '2022-09-01', '2023-01-15', FALSE),
  ((SELECT id FROM AnneeAcademique WHERE code='2022-2023'), 'S2', '2023-02-01', '2023-07-15', FALSE),
  ((SELECT id FROM AnneeAcademique WHERE code='2021-2022'), 'S1', '2021-09-01', '2022-01-15', FALSE);

-- Table: promotions
INSERT INTO promotions (id, libelle, niveau, filiere_id, annee_id) VALUES
  ('P001A', 'Promo 2023 Info', 'L1', (SELECT id FROM Filiere WHERE code='INFO'), (SELECT id FROM AnneeAcademique WHERE code='2023-2024')),
  ('P002A', 'Promo 2023 Math', 'L1', (SELECT id FROM Filiere WHERE code='MATH'), (SELECT id FROM AnneeAcademique WHERE code='2023-2024')),
  ('P003A', 'Promo 2022 Info', 'L2', (SELECT id FROM Filiere WHERE code='INFO'), (SELECT id FROM AnneeAcademique WHERE code='2022-2023')),
  ('P004A', 'Promo 2022 Math', 'L2', (SELECT id FROM Filiere WHERE code='MATH'), (SELECT id FROM AnneeAcademique WHERE code='2022-2023')),
  ('P005A', 'Promo 2021 Info', 'L3', (SELECT id FROM Filiere WHERE code='INFO'), (SELECT id FROM AnneeAcademique WHERE code='2021-2022'));

-- Table: departements
INSERT INTO departements (id, designation, categorie, directeur_id, date_creation) VALUES
  ('D001A', 'Informatique', 'Scientifique', NULL, '2020-09-01'),
  ('D002A', 'Mathématiques', 'Scientifique', NULL, '2020-09-01'),
  ('D003A', 'Physique', 'Scientifique', NULL, '2020-09-01'),
  ('D004A', 'Chimie', 'Scientifique', NULL, '2020-09-01'),
  ('D005A', 'Lettres', 'Lettres', NULL, '2020-09-01');

-- Table: enseignants
INSERT INTO enseignants (id, departement_id, nom, prenom, datenais, lieunais, sexe, email, tel1, tel2, matrimonial) VALUES
  ('E001A', 'D001A', 'Ngoma', 'Jean', '1980-05-12', 'Kinshasa', 'M', 'ngoma.jean@univ.cd', '+243810000001', NULL, 'Marié(e)'),
  ('E002A', 'D001A', 'Mbala', 'Alice', '1985-03-22', 'Lubumbashi', 'F', 'mbala.alice@univ.cd', '+243810000002', NULL, 'Célibataire'),
  ('E003A', 'D002A', 'Kanza', 'Paul', '1978-11-30', 'Goma', 'M', 'kanza.paul@univ.cd', '+243810000003', NULL, 'Marié(e)'),
  ('E004A', 'D003A', 'Tshibanda', 'Marie', '1982-07-15', 'Bukavu', 'F', 'tshibanda.marie@univ.cd', '+243810000004', NULL, 'Divorcé(e)'),
  ('E005A', 'D004A', 'Ilunga', 'Serge', '1975-01-10', 'Matadi', 'M', 'ilunga.serge@univ.cd', '+243810000005', NULL, 'Veuf(ve)'),
  ('E006A', 'D001A', 'Banza', 'Luc', '1983-02-14', 'Kinshasa', 'M', 'banza.luc@univ.cd', '+243810000006', NULL, 'Marié(e)'),
  ('E007A', 'D002A', 'Moke', 'Julie', '1987-09-21', 'Lubumbashi', 'F', 'moke.julie@univ.cd', '+243810000007', NULL, 'Célibataire'),
  ('E008A', 'D003A', 'Kikuni', 'Albert', '1980-04-18', 'Goma', 'M', 'kikuni.albert@univ.cd', '+243810000008', NULL, 'Marié(e)'),
  ('E009A', 'D004A', 'Tshilombo', 'Patricia', '1985-12-05', 'Bukavu', 'F', 'tshilombo.patricia@univ.cd', '+243810000009', NULL, 'Divorcé(e)'),
  ('E010A', 'D005A', 'Mutombo', 'Eric', '1979-07-23', 'Matadi', 'M', 'mutombo.eric@univ.cd', '+243810000010', NULL, 'Veuf(ve)');

-- Table: types_contrat
INSERT INTO types_contrat (code, libelle, duree_max_mois) VALUES
  ('CDI', 'Contrat à durée indéterminée', NULL),
  ('CDD', 'Contrat à durée déterminée', 24),
  ('STG', 'Stage', 6),
  ('VAC', 'Vacataire', 12),
  ('ALT', 'Alternance', 24);

-- Table: contrats
INSERT INTO contrats (id, enseignant_id, type_contrat, annee_id, date_debut, date_fin, heures_statutaires) VALUES
  ('C001A', 'E001A', 'CDI', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2023-09-01', '2024-07-15', 192),
  ('C002A', 'E002A', 'CDD', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2023-09-01', '2024-07-15', 160),
  ('C003A', 'E003A', 'STG', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2023-09-01', '2024-01-15', 80),
  ('C004A', 'E004A', 'VAC', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2023-09-01', '2024-07-15', 60),
  ('C005A', 'E005A', 'ALT', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2023-09-01', '2024-07-15', 100);

-- Table: types_cours
INSERT INTO types_cours (code, libelle, couleur) VALUES
  ('AM', 'Amphi', '#FFDD00'),
  ('TD', 'Travaux Dirigés', '#00DDFF'),
  ('TP', 'Travaux Pratiques', '#DD00FF'),
  ('CO', 'Cours', '#00FF00'),
  ('LB', 'Labo', '#FF00DD');

-- Table: Module
INSERT INTO Module (code, designation, credit, coefficient, volume_horaire, responsable_id) VALUES
  ('INF101', 'Algorithmique', 6, 1, 60, 'E001A'),
  ('INF102', 'Programmation', 6, 1, 60, 'E002A'),
  ('INF103', 'Bases de données', 6, 1, 60, 'E001A'),
  ('INF104', 'Réseaux', 6, 1, 60, 'E003A'),
  ('INF105', 'Systèmes', 6, 1, 60, 'E004A'),
  ('INF106', 'Web', 6, 1, 60, 'E001A'),
  ('INF107', 'Mobile', 6, 1, 60, 'E002A'),
  ('INF108', 'Cloud', 6, 1, 60, 'E003A'),
  ('INF109', 'IA', 6, 1, 60, 'E004A'),
  ('INF110', 'Sécurité', 6, 1, 60, 'E005A');

-- Table: salles
INSERT INTO salles (id, batiment, numero, capacite, type) VALUES
  ('S001A', 'A', '101', 60, 'Amphi'),
  ('S002A', 'A', '102', 40, 'Cours'),
  ('S003A', 'B', '201', 30, 'TD'),
  ('S004A', 'B', '202', 25, 'TP'),
  ('S005A', 'C', '301', 20, 'Labo');

-- Table: ModuleClasse
INSERT INTO ModuleClasse (module_id, classe_id, semestre_id, enseignant_id) VALUES
  ((SELECT id FROM Module WHERE code='INF101'), (SELECT id FROM Classe WHERE code='L1-INFO'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'E001A'),
  ((SELECT id FROM Module WHERE code='INF102'), (SELECT id FROM Classe WHERE code='L1-INFO'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'E002A'),
  ((SELECT id FROM Module WHERE code='INF103'), (SELECT id FROM Classe WHERE code='L2-INFO'), (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'E001A'),
  ((SELECT id FROM Module WHERE code='INF104'), (SELECT id FROM Classe WHERE code='L3-INFO'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'E003A'),
  ((SELECT id FROM Module WHERE code='INF105'), (SELECT id FROM Classe WHERE code='L2-MATH'), (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'E004A'),
  ((SELECT id FROM Module WHERE code='INF106'), (SELECT id FROM Classe WHERE code='L1-INFO'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'E001A'),
  ((SELECT id FROM Module WHERE code='INF107'), (SELECT id FROM Classe WHERE code='L1-INFO'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'E002A'),
  ((SELECT id FROM Module WHERE code='INF108'), (SELECT id FROM Classe WHERE code='L2-INFO'), (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'E001A'),
  ((SELECT id FROM Module WHERE code='INF109'), (SELECT id FROM Classe WHERE code='L3-INFO'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'E003A'),
  ((SELECT id FROM Module WHERE code='INF110'), (SELECT id FROM Classe WHERE code='L2-MATH'), (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'E004A');

-- Table: cours
INSERT INTO cours (module_classe_id, type_cours_code, date_debut, date_fin, salle_id) VALUES
  ((SELECT id FROM ModuleClasse LIMIT 1), 'AM', '2023-09-10 08:00', '2023-09-10 12:00', 'S001A'),
  ((SELECT id FROM ModuleClasse LIMIT 1 OFFSET 1), 'TD', '2023-09-12 10:00', '2023-09-12 12:00', 'S002A'),
  ((SELECT id FROM ModuleClasse LIMIT 1 OFFSET 2), 'TP', '2023-09-15 14:00', '2023-09-15 16:00', 'S003A'),
  ((SELECT id FROM ModuleClasse LIMIT 1 OFFSET 3), 'CO', '2023-09-18 08:00', '2023-09-18 10:00', 'S004A'),
  ((SELECT id FROM ModuleClasse LIMIT 1 OFFSET 4), 'LB', '2023-09-20 09:00', '2023-09-20 11:00', 'S005A');

-- Table: creneaux
INSERT INTO creneaux (enseignant_id, module_id, salle_id, type_cours, semestre_id, jour, heure_debut, heure_fin) VALUES
  ('E001A', (SELECT id FROM Module WHERE code='INF101'), 'S001A', 'AM', (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'LUNDI', '08:00', '10:00'),
  ('E002A', (SELECT id FROM Module WHERE code='INF102'), 'S002A', 'TD', (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'MARDI', '10:00', '12:00'),
  ('E003A', (SELECT id FROM Module WHERE code='INF103'), 'S003A', 'TP', (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'MERCREDI', '14:00', '16:00'),
  ('E004A', (SELECT id FROM Module WHERE code='INF104'), 'S004A', 'CO', (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'JEUDI', '08:00', '10:00'),
  ('E005A', (SELECT id FROM Module WHERE code='INF105'), 'S005A', 'LB', (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'VENDREDI', '09:00', '11:00');

-- Table: schedule
INSERT INTO schedule (enseignant_id, module_id, salle_id, classe_code, type_cours, semestre_id, jour, heure_debut, heure_fin) VALUES
  ('E001A', (SELECT id FROM Module WHERE code='INF101'), 'S001A', 'L1-INFO', 'AM', (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'LUNDI', '08:00', '10:00'),
  ('E002A', (SELECT id FROM Module WHERE code='INF102'), 'S002A', 'L1-INFO', 'TD', (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'MARDI', '10:00', '12:00'),
  ('E003A', (SELECT id FROM Module WHERE code='INF103'), 'S003A', 'L2-INFO', 'TP', (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 'MERCREDI', '14:00', '16:00'),
  ('E004A', (SELECT id FROM Module WHERE code='INF104'), 'S004A', 'L3-INFO', 'CO', (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'JEUDI', '08:00', '10:00'),
  ('E005A', (SELECT id FROM Module WHERE code='INF105'), 'S005A', 'L2-MATH', 'LB', (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 'VENDREDI', '09:00', '11:00');

-- Table: types_concours
INSERT INTO types_concours (code, libelle, dossier_requis) VALUES
  ('ADM', 'Admission', TRUE),
  ('REC', 'Recrutement', TRUE),
  ('SPE', 'Spécial', FALSE),
  ('INT', 'International', TRUE),
  ('STG', 'Stage', FALSE);

-- Table: concours
INSERT INTO concours (designation, type_concours, description, annee_id, date_debut, date_fin, date_limite_inscription, statut) VALUES
  ('Concours Licence 2024', 'ADM', 'Admission en Licence', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2024-06-01', '2024-06-10', '2024-05-25', 'planifié'),
  ('Concours Master 2024', 'ADM', 'Admission en Master', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2024-07-01', '2024-07-10', '2024-06-20', 'planifié'),
  ('Concours Doctorat 2024', 'ADM', 'Admission en Doctorat', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2024-08-01', '2024-08-10', '2024-07-20', 'planifié'),
  ('Recrutement Enseignants 2024', 'REC', 'Recrutement enseignants', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2024-05-01', '2024-05-10', '2024-04-20', 'planifié'),
  ('Concours International 2024', 'INT', 'Admission internationale', (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), '2024-09-01', '2024-09-10', '2024-08-20', 'planifié');

-- Table: epreuves_concours
INSERT INTO epreuves_concours (concours_id, designation, code, coefficient, heure_debut, heure_fin, ordre, type_epreuve, description) VALUES
  ((SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'Mathématiques', 'MATH-ADM', 2, '08:00', '10:00', 1, 'écrit', 'Epreuve de mathématiques'),
  ((SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'Français', 'FR-ADM', 1, '10:30', '12:00', 2, 'écrit', 'Epreuve de français'),
  ((SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'Anglais', 'ANG-ADM', 1, '13:00', '14:00', 3, 'écrit', 'Epreuve d''anglais'),
  ((SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'Entretien', 'ENT-ADM', 1, '14:30', '15:30', 4, 'oral', 'Entretien oral'),
  ((SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'Informatique', 'INFO-ADM', 2, '16:00', '18:00', 5, 'écrit', 'Epreuve d''informatique');

-- Table: candidats
INSERT INTO candidats (matricule, concours_id, filiere, nom, prenom, datenais, lieunais, sexe, tel, email, adresse, ville, nationnalite) VALUES
  ('C20240001', (SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'INF', 'Mwamba', 'Pierre', '2005-04-12', 'Kinshasa', 'M', '+243810000101', 'mwamba.pierre@mail.com', 'Av. Kasa-Vubu', 'Kinshasa', 'CONGOLAISE'),
  ('C20240002', (SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'LAP', 'Kabeya', 'Sarah', '2004-11-23', 'Lubumbashi', 'F', '+243810000102', 'kabeya.sarah@mail.com', 'Av. Lumumba', 'Lubumbashi', 'CONGOLAISE'),
  ('C20240003', (SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'DUT', 'Ngoy', 'Paul', '2005-01-15', 'Goma', 'M', '+243810000103', 'ngoy.paul@mail.com', 'Av. Sendwe', 'Goma', 'CONGOLAISE'),
  ('C20240004', (SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'AM', 'Ilunga', 'Marie', '2005-07-30', 'Bukavu', 'F', '+243810000104', 'ilunga.marie@mail.com', 'Av. Kimbangu', 'Bukavu', 'CONGOLAISE'),
  ('C20240005', (SELECT id FROM concours WHERE designation='Concours Licence 2024'), 'MT', 'Tshibanda', 'Serge', '2004-09-10', 'Matadi', 'M', '+243810000105', 'tshibanda.serge@mail.com', 'Av. Kasai', 'Matadi', 'CONGOLAISE');

-- Table: dossiers_candidaturev2
INSERT INTO dossiers_candidaturev2 (candidat_id, chemin_photo, statut) VALUES
  ((SELECT id FROM candidats WHERE nom='Mwamba'), '/photos/mwamba.jpg', 'complet'),
  ((SELECT id FROM candidats WHERE nom='Kabeya'), '/photos/kabeya.jpg', 'complet'),
  ((SELECT id FROM candidats WHERE nom='Ngoy'), '/photos/ngoy.jpg', 'incomplet'),
  ((SELECT id FROM candidats WHERE nom='Ilunga'), '/photos/ilunga.jpg', 'verifie'),
  ((SELECT id FROM candidats WHERE nom='Tshibanda'), '/photos/tshibanda.jpg', 'complet');

-- Table: pieces_jointes
INSERT INTO pieces_jointes (dossier_id, type_piece, chemin_fichier, est_obligatoire) VALUES
  ((SELECT id FROM dossiers_candidaturev2 WHERE candidat_id=(SELECT id FROM candidats WHERE nom='Mwamba')), 'DIPLOME', '/docs/mwamba_diplome.pdf', TRUE),
  ((SELECT id FROM dossiers_candidaturev2 WHERE candidat_id=(SELECT id FROM candidats WHERE nom='Kabeya')), 'PHOTO', '/docs/kabeya_photo.jpg', TRUE),
  ((SELECT id FROM dossiers_candidaturev2 WHERE candidat_id=(SELECT id FROM candidats WHERE nom='Ngoy')), 'CV', '/docs/ngoy_cv.pdf', TRUE),
  ((SELECT id FROM dossiers_candidaturev2 WHERE candidat_id=(SELECT id FROM candidats WHERE nom='Ilunga')), 'ATTESTATION', '/docs/ilunga_attestation.pdf', TRUE),
  ((SELECT id FROM dossiers_candidaturev2 WHERE candidat_id=(SELECT id FROM candidats WHERE nom='Tshibanda')), 'LETTRE', '/docs/tshibanda_lettre.pdf', TRUE);

-- Table: Etudiant
INSERT INTO Etudiant (matricule, nom, prenom, sexe, date_naissance, lieu_naissance, telephone, email, ville, filiere_id) VALUES
  ('20230001', 'Mwamba', 'Pierre', 'M', '2005-04-12', 'Kinshasa', '+243810000201', 'mwamba.pierre@etu.univ.cd', 'Kinshasa', (SELECT id FROM Filiere WHERE code='INFO')),
  ('20230002', 'Kabeya', 'Sarah', 'F', '2004-11-23', 'Lubumbashi', '+243810000202', 'kabeya.sarah@etu.univ.cd', 'Lubumbashi', (SELECT id FROM Filiere WHERE code='INFO')),
  ('20230003', 'Ngoy', 'Paul', 'M', '2005-01-15', 'Goma', '+243810000203', 'ngoy.paul@etu.univ.cd', 'Goma', (SELECT id FROM Filiere WHERE code='INFO')),
  ('20230004', 'Ilunga', 'Marie', 'F', '2005-07-30', 'Bukavu', '+243810000204', 'ilunga.marie@etu.univ.cd', 'Bukavu', (SELECT id FROM Filiere WHERE code='INFO')),
  ('20230005', 'Tshibanda', 'Serge', 'M', '2004-09-10', 'Matadi', '+243810000205', 'tshibanda.serge@etu.univ.cd', 'Matadi', (SELECT id FROM Filiere WHERE code='INFO')),
  ('20230006', 'Mbuyi', 'Chantal', 'F', '2005-08-22', 'Kinshasa', '+243810000206', 'mbuyi.chantal@etu.univ.cd', 'Kinshasa', (SELECT id FROM Filiere WHERE code='MATH')),
  ('20230007', 'Mukendi', 'David', 'M', '2004-12-11', 'Lubumbashi', '+243810000207', 'mukendi.david@etu.univ.cd', 'Lubumbashi', (SELECT id FROM Filiere WHERE code='PHY')),
  ('20230008', 'Kasongo', 'Esther', 'F', '2005-03-05', 'Goma', '+243810000208', 'kasongo.esther@etu.univ.cd', 'Goma', (SELECT id FROM Filiere WHERE code='CHIM')),
  ('20230009', 'Kabila', 'Jean', 'M', '2004-10-17', 'Bukavu', '+243810000209', 'kabila.jean@etu.univ.cd', 'Bukavu', (SELECT id FROM Filiere WHERE code='BIO')),
  ('20230010', 'Mbemba', 'Grace', 'F', '2005-06-30', 'Matadi', '+243810000210', 'mbemba.grace@etu.univ.cd', 'Matadi', (SELECT id FROM Filiere WHERE code='INFO'));

-- Table: dossiers
INSERT INTO dossiers (etudiant_id) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001')),
  ((SELECT id FROM Etudiant WHERE matricule='20230002')),
  ((SELECT id FROM Etudiant WHERE matricule='20230003')),
  ((SELECT id FROM Etudiant WHERE matricule='20230004')),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'));

-- Table: tuteurs
INSERT INTO tuteurs (etudiant_id, nom, prenom, tel1, tel2, email, nationalite, adresse, ville, lien_parente) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), 'Mwamba', 'Jean', '+243810000301', NULL, 'mwamba.jean@fam.cd', 'CD', 'Av. Kasa-Vubu', 'Kinshasa', 'PERE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), 'Kabeya', 'Alice', '+243810000302', NULL, 'kabeya.alice@fam.cd', 'CD', 'Av. Lumumba', 'Lubumbashi', 'MERE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), 'Ngoy', 'Paul', '+243810000303', NULL, 'ngoy.paul@fam.cd', 'CD', 'Av. Sendwe', 'Goma', 'PERE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), 'Ilunga', 'Marie', '+243810000304', NULL, 'ilunga.marie@fam.cd', 'CD', 'Av. Kimbangu', 'Bukavu', 'MERE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), 'Tshibanda', 'Serge', '+243810000305', NULL, 'tshibanda.serge@fam.cd', 'CD', 'Av. Kasai', 'Matadi', 'PERE');

-- Table: pieces_dossier
INSERT INTO pieces_dossier (type_piece, chemin, statut) VALUES
  ('DIPLOME', '/uploads/mwamba_diplome.pdf', 'VALIDE'),
  ('PHOTO', '/uploads/kabeya_photo.jpg', 'VALIDE'),
  ('CV', '/uploads/ngoy_cv.pdf', 'EN_ATTENTE'),
  ('ATTESTATION', '/uploads/ilunga_attestation.pdf', 'VALIDE'),
  ('LETTRE', '/uploads/tshibanda_lettre.pdf', 'EN_ATTENTE');

-- Table: Evaluation
INSERT INTO Evaluation (module_id, type, coefficient, date_prevue, ponderation) VALUES
  ((SELECT id FROM Module WHERE code='INF101'), 'CC', 1.0, '2023-10-01', 30),
  ((SELECT id FROM Module WHERE code='INF102'), 'TP', 1.0, '2023-10-15', 20),
  ((SELECT id FROM Module WHERE code='INF103'), 'Examen', 2.0, '2023-12-01', 50),
  ((SELECT id FROM Module WHERE code='INF104'), 'Projet', 1.5, '2023-11-10', 40),
  ((SELECT id FROM Module WHERE code='INF105'), 'CC', 1.0, '2023-10-20', 30);

-- Table: session_evaluation
INSERT INTO session_evaluation (semestre_id, annee_id, code, designation, est_rappel, etat, date_debut, date_fin, responsable) VALUES
  ((SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), 'SESS1', 'Session 1', FALSE, 'active', '2023-10-01', '2023-10-15', 'E001A'),
  ((SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), 'SESS2', 'Session 2', FALSE, 'inactive', '2024-02-01', '2024-02-15', 'E002A'),
  ((SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), (SELECT id FROM AnneeAcademique WHERE code='2022-2023'), 'SESS3', 'Session 3', FALSE, 'archivé', '2022-10-01', '2022-10-15', 'E003A'),
  ((SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), (SELECT id FROM AnneeAcademique WHERE code='2022-2023'), 'SESS4', 'Session 4', FALSE, 'inactive', '2023-02-01', '2023-02-15', 'E004A'),
  ((SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2021-2022')), (SELECT id FROM AnneeAcademique WHERE code='2021-2022'), 'SESS5', 'Session 5', FALSE, 'archivé', '2021-10-01', '2021-10-15', 'E005A');

-- Table: note
INSERT INTO note (etudiant_id, module_id, classe_id, session_id, note_controle, note_partiel, note_rappel, statut) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), (SELECT id FROM Module WHERE code='INF101'), (SELECT id FROM Classe WHERE code='L1-INFO'), (SELECT id FROM session_evaluation WHERE code='SESS1'), 15.5, 14.0, NULL, 'saisie'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), (SELECT id FROM Module WHERE code='INF102'), (SELECT id FROM Classe WHERE code='L1-INFO'), (SELECT id FROM session_evaluation WHERE code='SESS1'), 13.0, 12.5, NULL, 'saisie'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), (SELECT id FROM Module WHERE code='INF103'), (SELECT id FROM Classe WHERE code='L2-INFO'), (SELECT id FROM session_evaluation WHERE code='SESS2'), 16.0, 15.0, NULL, 'saisie'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), (SELECT id FROM Module WHERE code='INF104'), (SELECT id FROM Classe WHERE code='L3-INFO'), (SELECT id FROM session_evaluation WHERE code='SESS3'), 14.5, 13.0, NULL, 'saisie'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), (SELECT id FROM Module WHERE code='INF105'), (SELECT id FROM Classe WHERE code='L2-MATH'), (SELECT id FROM session_evaluation WHERE code='SESS4'), 12.0, 11.5, NULL, 'saisie');

-- Table: resultats
INSERT INTO resultats (etudiant_id, semestre_id, total_coef, total_general, moyenne, rang, effectif, decision) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 30, 450, 15.0, 1, 40, 'Admis'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 30, 420, 14.0, 2, 40, 'Admis'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2023-2024')), 30, 390, 13.0, 3, 40, 'Rattrapage'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), (SELECT id FROM Semestre WHERE code='S1' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 30, 370, 12.5, 4, 40, 'Admis'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), (SELECT id FROM Semestre WHERE code='S2' AND annee_id=(SELECT id FROM AnneeAcademique WHERE code='2022-2023')), 30, 350, 11.5, 5, 40, 'Échec');

-- Table: frais_academiques
INSERT INTO frais_academiques (etudiant_id, type, montant, montant_paye, date_emission, date_echeance, statut) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), 'SOUTENANCE', 50000, 50000, '2024-01-10', '2024-02-10', 'payé'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), 'DIPLOME', 30000, 30000, '2024-01-12', '2024-02-12', 'payé'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), 'BIBLIOTHEQUE', 10000, 10000, '2024-01-14', '2024-02-14', 'payé'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), 'SOUTENANCE', 50000, 25000, '2024-01-16', '2024-02-16', 'partiel'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), 'DIPLOME', 30000, 0, '2024-01-18', '2024-02-18', 'impayé');

-- Table: frais_scolarite
INSERT INTO frais_scolarite (filiere_id, annee, montant_annuel, montant_mensuel) VALUES
  ((SELECT id FROM Filiere WHERE code='INFO'), '2023-2024', 250000, 25000),
  ((SELECT id FROM Filiere WHERE code='MATH'), '2023-2024', 250000, 25000),
  ((SELECT id FROM Filiere WHERE code='PHY'), '2023-2024', 250000, 25000),
  ((SELECT id FROM Filiere WHERE code='CHIM'), '2023-2024', 250000, 25000),
  ((SELECT id FROM Filiere WHERE code='BIO'), '2023-2024', 250000, 25000);

-- Table: paiement_scolarite
INSERT INTO paiement_scolarite (reference, etudiant_id, classe_code, date_paiement, montant, mode_paiement, type_paiement, mois) VALUES
  ('REF001', (SELECT id FROM Etudiant WHERE matricule='20230001'), 'L1-INFO', '2023-09-05', 25000, 'espece', 'mensuel', '2023-09'),
  ('REF002', (SELECT id FROM Etudiant WHERE matricule='20230002'), 'L1-INFO', '2023-09-06', 25000, 'mobile money', 'mensuel', '2023-09'),
  ('REF003', (SELECT id FROM Etudiant WHERE matricule='20230003'), 'L2-INFO', '2023-09-07', 25000, 'virement', 'mensuel', '2023-09'),
  ('REF004', (SELECT id FROM Etudiant WHERE matricule='20230004'), 'L3-INFO', '2023-09-08', 25000, 'espece', 'mensuel', '2023-09'),
  ('REF005', (SELECT id FROM Etudiant WHERE matricule='20230005'), 'L2-MATH', '2023-09-09', 25000, 'chèque', 'mensuel', '2023-09');

-- Table: Utilisateur
INSERT INTO Utilisateur (nom, prenom, email, role, actif) VALUES
  ('Admin', 'Principal', 'admin@univ.cd', 'admin', TRUE),
  ('Mbala', 'Alice', 'mbala.alice@univ.cd', 'gestionnaire', TRUE),
  ('Ngoma', 'Jean', 'ngoma.jean@univ.cd', 'enseignant', TRUE),
  ('Kanza', 'Paul', 'kanza.paul@univ.cd', 'enseignant', TRUE),
  ('Tshibanda', 'Marie', 'tshibanda.marie@univ.cd', 'enseignant', TRUE);

-- Table: users
INSERT INTO users (username, email, mot_de_passe_hash, role, actif) VALUES
  ('admin', 'admin@univ.cd', 'hash1', 'admin', TRUE),
  ('alice', 'mbala.alice@univ.cd', 'hash2', 'gestionnaire', TRUE),
  ('jean', 'ngoma.jean@univ.cd', 'hash3', 'enseignant', TRUE),
  ('paul', 'kanza.paul@univ.cd', 'hash4', 'enseignant', TRUE),
  ('marie', 'tshibanda.marie@univ.cd', 'hash5', 'enseignant', TRUE);

-- Table: pays
INSERT INTO pays (code_iso, nom_pays, nationalite) VALUES
  ('CD', 'République Démocratique du Congo', 'Congolaise'),
  ('FR', 'France', 'Française'),
  ('BE', 'Belgique', 'Belge'),
  ('CM', 'Cameroun', 'Camerounaise'),
  ('CI', 'Côte d''Ivoire', 'Ivoirienne');

-- Table: salle_soutenance
INSERT INTO salle_soutenance (nom, capacite, batiment, equipements) VALUES
  ('Salle Soutenance 1', 30, 'A', ARRAY['Projecteur', 'Tableau']),
  ('Salle Soutenance 2', 25, 'B', ARRAY['Tableau']),
  ('Salle Soutenance 3', 20, 'C', ARRAY['Projecteur']),
  ('Salle Soutenance 4', 15, 'A', ARRAY['Tableau', 'Sonorisation']),
  ('Salle Soutenance 5', 10, 'B', ARRAY['Projecteur', 'Tableau', 'Sonorisation']);

-- Table: soutenances
INSERT INTO soutenances (etudiant_id, soutenance_ref, soutenance_etat, soutenance_theme, date_soutenance, salle_id, no_ordre) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), 'SOUT2024-001', 'PLANIFIEE', 'Optimisation des algorithmes', '2024-06-20 09:00', (SELECT id FROM salle_soutenance WHERE nom='Salle Soutenance 1'), 'A-001'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), 'SOUT2024-002', 'PLANIFIEE', 'Analyse de données massives', '2024-06-20 11:00', (SELECT id FROM salle_soutenance WHERE nom='Salle Soutenance 2'), 'A-002'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), 'SOUT2024-003', 'PLANIFIEE', 'Sécurité informatique', '2024-06-21 09:00', (SELECT id FROM salle_soutenance WHERE nom='Salle Soutenance 3'), 'A-003'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), 'SOUT2024-004', 'PLANIFIEE', 'Réseaux avancés', '2024-06-21 11:00', (SELECT id FROM salle_soutenance WHERE nom='Salle Soutenance 4'), 'A-004'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), 'SOUT2024-005', 'PLANIFIEE', 'Intelligence artificielle', '2024-06-22 09:00', (SELECT id FROM salle_soutenance WHERE nom='Salle Soutenance 5'), 'A-005');

-- Table: notifications
INSERT INTO notifications (etudiant_id, message, type_notification, date_limite) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), 'Votre inscription est validée.', 'information', '2024-09-01'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), 'Paiement de scolarité en attente.', 'alerte', '2024-10-01'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), 'Soutenance prévue le 20 juin.', 'rappel', '2024-06-19'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), 'Documents manquants dans votre dossier.', 'alerte', '2024-05-15'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), 'Résultats disponibles.', 'information', '2024-07-01');

-- Table: historique_notifications
INSERT INTO historique_notifications (notification_id, date_modification, modifie_par, anciennes_valeurs, nouvelles_valeurs) VALUES
  ((SELECT id FROM notifications WHERE message='Votre inscription est validée.'), '2024-09-01', 'admin', '{"lu":false}', '{"lu":true}'),
  ((SELECT id FROM notifications WHERE message='Paiement de scolarité en attente.'), '2024-10-01', 'admin', '{"lu":false}', '{"lu":true}'),
  ((SELECT id FROM notifications WHERE message='Soutenance prévue le 20 juin.'), '2024-06-19', 'admin', '{"lu":false}', '{"lu":true}'),
  ((SELECT id FROM notifications WHERE message='Documents manquants dans votre dossier.'), '2024-05-15', 'admin', '{"lu":false}', '{"lu":true}'),
  ((SELECT id FROM notifications WHERE message='Résultats disponibles.'), '2024-07-01', 'admin', '{"lu":false}', '{"lu":true}');

-- Table: audit_financier
INSERT INTO audit_financier (table_impactee, action, id_entite, utilisateur, anciennes_valeurs, nouvelles_valeurs) VALUES
  ('paiement_scolarite', 'C', (SELECT id FROM paiement_scolarite WHERE reference='REF001'), 'admin', NULL, '{"montant":25000}'),
  ('paiement_scolarite', 'U', (SELECT id FROM paiement_scolarite WHERE reference='REF002'), 'admin', '{"montant":20000}', '{"montant":25000}'),
  ('paiement_scolarite', 'C', (SELECT id FROM paiement_scolarite WHERE reference='REF003'), 'admin', NULL, '{"montant":25000}'),
  ('paiement_scolarite', 'D', (SELECT id FROM paiement_scolarite WHERE reference='REF004'), 'admin', '{"montant":25000}', NULL),
  ('paiement_scolarite', 'C', (SELECT id FROM paiement_scolarite WHERE reference='REF005'), 'admin', NULL, '{"montant":25000}');

-- Table: recus_paiement
INSERT INTO recus_paiement (paiement_id, numero, montant) VALUES
  ((SELECT id FROM paiement_scolarite WHERE reference='REF001'), 'REC-001', 25000),
  ((SELECT id FROM paiement_scolarite WHERE reference='REF002'), 'REC-002', 25000),
  ((SELECT id FROM paiement_scolarite WHERE reference='REF003'), 'REC-003', 25000),
  ((SELECT id FROM paiement_scolarite WHERE reference='REF004'), 'REC-004', 25000),
  ((SELECT id FROM paiement_scolarite WHERE reference='REF005'), 'REC-005', 25000);

-- Table: frais_soutenance
INSERT INTO frais_soutenance (etudiant_id, montant, date_echeance, statut_paiement) VALUES
  ((SELECT id FROM Etudiant WHERE matricule='20230001'), 50000, '2024-06-15', 'PAYE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230002'), 50000, '2024-06-15', 'PARTIEL'),
  ((SELECT id FROM Etudiant WHERE matricule='20230003'), 50000, '2024-06-15', 'IMPAYE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230004'), 50000, '2024-06-15', 'PAYE'),
  ((SELECT id FROM Etudiant WHERE matricule='20230005'), 50000, '2024-06-15', 'PARTIEL');

-- Table: planification_examen
INSERT INTO planification_examen (session_id, filiere_id, annee_id, description, date_debut, date_fin, responsable) VALUES
  ((SELECT id FROM session_evaluation WHERE code='SESS1'), (SELECT id FROM Filiere WHERE code='INFO'), (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), 'Examens L1 Info', '2024-06-01', '2024-06-10', 'E001A'),
  ((SELECT id FROM session_evaluation WHERE code='SESS2'), (SELECT id FROM Filiere WHERE code='MATH'), (SELECT id FROM AnneeAcademique WHERE code='2023-2024'), 'Examens L1 Math', '2024-06-01', '2024-06-10', 'E002A'),
  ((SELECT id FROM session_evaluation WHERE code='SESS3'), (SELECT id FROM Filiere WHERE code='PHY'), (SELECT id FROM AnneeAcademique WHERE code='2022-2023'), 'Examens L1 Physique', '2023-06-01', '2023-06-10', 'E003A'),
  ((SELECT id FROM session_evaluation WHERE code='SESS4'), (SELECT id FROM Filiere WHERE code='CHIM'), (SELECT id FROM AnneeAcademique WHERE code='2022-2023'), 'Examens L1 Chimie', '2023-06-01', '2023-06-10', 'E004A'),
  ((SELECT id FROM session_evaluation WHERE code='SESS5'), (SELECT id FROM Filiere WHERE code='BIO'), (SELECT id FROM AnneeAcademique WHERE code='2021-2022'), 'Examens L1 Biologie', '2022-06-01', '2022-06-10', 'E005A');

-- Table: examens_planifies
INSERT INTO examens_planifies (planification_id, module_id, classe_id, date_examen, heure_debut, heure_fin, salle_id, superviseur_id) VALUES
  ((SELECT id FROM planification_examen LIMIT 1), (SELECT id FROM Module WHERE code='INF101'), (SELECT id FROM Classe WHERE code='L1-INFO'), '2024-06-02', '08:00', '10:00', 'S001A', 'E001A'),
  ((SELECT id FROM planification_examen LIMIT 1 OFFSET 1), (SELECT id FROM Module WHERE code='INF102'), (SELECT id FROM Classe WHERE code='L1-INFO'), '2024-06-03', '10:00', '12:00', 'S002A', 'E002A'),
  ((SELECT id FROM planification_examen LIMIT 1 OFFSET 2), (SELECT id FROM Module WHERE code='INF103'), (SELECT id FROM Classe WHERE code='L2-INFO'), '2023-06-04', '14:00', '16:00', 'S003A', 'E003A'),
  ((SELECT id FROM planification_examen LIMIT 1 OFFSET 3), (SELECT id FROM Module WHERE code='INF104'), (SELECT id FROM Classe WHERE code='L3-INFO'), '2023-06-05', '08:00', '10:00', 'S004A', 'E004A'),
  ((SELECT id FROM planification_examen LIMIT 1 OFFSET 4), (SELECT id FROM Module WHERE code='INF105'), (SELECT id FROM Classe WHERE code='L2-MATH'), '2022-06-06', '09:00', '11:00', 'S005A', 'E005A');

-- Table: epreuve_examen
INSERT INTO epreuve_examen (examen_id, numero_epreuve, designation, coefficient, duree_minutes, observation) VALUES
  ((SELECT id FROM examens_planifies LIMIT 1), 1, 'Algorithmique', 1.0, 120, 'Epreuve principale'),
  ((SELECT id FROM examens_planifies LIMIT 1 OFFSET 1), 2, 'Programmation', 1.0, 120, 'Epreuve principale'),
  ((SELECT id FROM examens_planifies LIMIT 1 OFFSET 2), 3, 'Bases de données', 1.0, 120, 'Epreuve principale'),
  ((SELECT id FROM examens_planifies LIMIT 1 OFFSET 3), 4, 'Réseaux', 1.0, 120, 'Epreuve principale'),
  ((SELECT id FROM examens_planifies LIMIT 1 OFFSET 4), 5, 'Systèmes', 1.0, 120, 'Epreuve principale');
