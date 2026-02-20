CREATE UNIQUE INDEX idx_anneeacademique_active_unique
ON AnneeAcademique (est_active)
WHERE est_active = TRUE;

-- Index pour recherches fréquentes
CREATE INDEX idx_diplomes_enseignant ON diplomes_enseignants(enseignant_id);

-- Index pour la table AnneeAcademique
CREATE INDEX idx_anneeacademique_code ON AnneeAcademique(code); -- Recherche rapide par code
CREATE INDEX idx_anneeacademique_est_active ON AnneeAcademique(est_active); -- Filtrage rapide sur les années actives

-- Index pour la table Cycle
CREATE INDEX idx_cycle_code ON Cycle(code); -- Recherche rapide par code
CREATE INDEX idx_cycle_designation ON Cycle(designation); -- Recherche rapide par désignation

-- Index pour la table Filiere
CREATE INDEX idx_filiere_code ON Filiere(code); -- Recherche rapide par code
CREATE INDEX idx_filiere_cycle_id ON Filiere(cycle_id); -- Optimisation des jointures avec Cycle

-- Index pour la table Niveau
CREATE INDEX idx_niveau_code ON Niveau(code); -- Recherche rapide par code
CREATE INDEX idx_niveau_cycle_id ON Niveau(cycle_id); -- Optimisation des jointures avec Cycle
CREATE INDEX idx_niveau_ordre ON Niveau(ordre); -- Tri rapide par ordre

-- Index pour la table Classe
CREATE INDEX idx_classe_code ON Classe(code); -- Recherche rapide par code
CREATE INDEX idx_classe_niveau_id ON Classe(niveau_id); -- Optimisation des jointures avec Niveau
CREATE INDEX idx_classe_filiere_id ON Classe(filiere_id); -- Optimisation des jointures avec Filiere

-- Index pour la table Semestre
CREATE INDEX idx_semestre_code ON Semestre(code); -- Recherche rapide par code
CREATE INDEX idx_semestre_annee_id ON Semestre(annee_id); -- Optimisation des jointures avec AnneeAcademique
CREATE INDEX idx_semestre_est_actif ON Semestre(est_actif); -- Filtrage rapide sur les semestres actifs

--Index pour departement 
CREATE INDEX idx_departements_designation ON departements(designation); -- Recherche rapide par désignation
CREATE INDEX idx_departements_categorie ON departements(categorie); -- Filtrage par catégorie
CREATE INDEX idx_departements_directeur_id ON departements(directeur_id); -- Recherche par directeur
CREATE INDEX idx_enseignants_nom_prenom ON enseignants(nom, prenom); -- Recherche rapide par nom et prénom

--index pour enseignants
CREATE INDEX idx_enseignants_email ON enseignants(email); -- Recherche rapide par email
CREATE INDEX idx_enseignants_departement_id ON enseignants(departement_id); -- Optimisation des jointures avec `departements`

--index pour diplomes
CREATE INDEX idx_diplomes_enseignant_id ON diplomes_enseignants(enseignant_id); -- Recherche rapide par enseignant
CREATE INDEX idx_diplomes_intitule ON diplomes_enseignants(intitule); -- Recherche rapide par intitule
CREATE INDEX idx_diplomes_annee_obtention ON diplomes_enseignants(annee_obtention); -- Filtrage par année d'obtention

-- index pour contrats
CREATE INDEX idx_contrats_enseignant_id ON contrats(enseignant_id); -- Recherche rapide par enseignant
CREATE INDEX idx_contrats_type_contrat ON contrats(type_contrat); -- Recherche rapide par type de contrat
CREATE INDEX idx_contrats_annee_id ON contrats(annee_id); -- Optimisation des jointures avec `AnneeAcademique`
CREATE INDEX idx_contrats_date_debut_fin ON contrats(date_debut, date_fin); -- Recherche par période
CREATE INDEX idx_types_contrat_libelle ON types_contrat(libelle); -- Recherche rapide par libellé

--index pour historique contrats
CREATE INDEX idx_historique_contrats_contrat_id ON historique_contrats(contrat_id); -- Recherche rapide par contrat
CREATE INDEX idx_historique_contrats_date_modif ON historique_contrats(date_modif); -- Tri par date de modification
CREATE INDEX idx_historique_contrats_modifie_par ON historique_contrats(modifie_par); -- Recherche par utilisateur

--index pour module
CREATE INDEX idx_module_code ON module(code); -- Recherche rapide par code
CREATE INDEX idx_module_designation ON module(designation); -- Recherche rapide par désignation
CREATE INDEX idx_module_responsable_id ON module(responsable_id); -- Recherche par responsable

--index pour la liaison moduleclasse
CREATE INDEX idx_moduleclasse_module ON ModuleClasse(module_id);
CREATE INDEX idx_moduleclasse_classe ON ModuleClasse(classe_id);
CREATE INDEX idx_moduleclasse_semestre ON ModuleClasse(semestre_id);
CREATE INDEX idx_moduleclasse_enseignant ON ModuleClasse(enseignant_id);


--index pour salles
CREATE INDEX idx_salles_batiment ON salles(batiment); -- Recherche rapide par bâtiment
CREATE INDEX idx_salles_type ON salles(type); -- Filtrage par type de salle
CREATE INDEX idx_salles_capacite ON salles(capacite); -- Recherche par capacité
CREATE INDEX idx_salles_numero ON salles(numero); -- Recherche rapide par numéro de salle
CREATE INDEX idx_salles_capacite_type ON salles(capacite, type); -- Recherche par capacité et type

--index pour creneaux
CREATE INDEX idx_creneaux_enseignant_id ON creneaux(enseignant_id); -- Recherche rapide par enseignant
CREATE INDEX idx_creneaux_module_id ON creneaux(module_id); -- Recherche rapide par module
CREATE INDEX idx_creneaux_salle_id ON creneaux(salle_id); -- Recherche rapide par salle
CREATE INDEX idx_creneaux_semestre_id ON creneaux(semestre_id); -- Recherche rapide par semestre
CREATE INDEX idx_creneaux_jour_heure ON creneaux(jour, heure_debut, heure_fin); -- Recherche par jour et horaire

--index pour support_de_cours
CREATE INDEX idx_support_de_cours_creneau_id ON support_de_cours(creneau_id); -- Recherche rapide par créneau
CREATE INDEX idx_support_de_cours_titre ON support_de_cours(titre); -- Recherche rapide par titre
CREATE INDEX idx_support_de_cours_auteur_id ON support_de_cours(auteur_id); -- Recherche par auteur

--index pour concours
CREATE INDEX idx_concours_designation ON concours(designation); -- Recherche rapide par désignation
CREATE INDEX idx_concours_type_concours ON concours(type_concours); -- Recherche rapide par type de concours
CREATE INDEX idx_concours_annee_id ON concours(annee_id); -- Optimisation des jointures avec `AnneeAcademique`
CREATE INDEX idx_concours_date_debut_fin ON concours(date_debut, date_fin); -- Recherche par période
CREATE INDEX idx_concours_statut ON concours(statut); -- Filtrage par statut

--index pour le cursus
CREATE INDEX idx_cursus_etudiant ON Cursus(etudiant_id);
CREATE INDEX idx_cursus_classe ON Cursus(classe_id);
CREATE INDEX idx_cursus_annee ON Cursus(annee_academique_id);

--index pour historique concours
CREATE INDEX idx_histo_etudiant ON HistoriqueCursus(etudiant_id);
CREATE INDEX idx_histo_ancien_classe ON HistoriqueCursus(ancienne_classe_id);
CREATE INDEX idx_histo_nouvelle_classe ON HistoriqueCursus(nouvelle_classe_id);
CREATE INDEX idx_histo_ancien_annee ON HistoriqueCursus(ancienne_annee_academique_id);
CREATE INDEX idx_histo_nouvelle_annee ON HistoriqueCursus(nouvelle_annee_academique_id);
CREATE INDEX idx_histo_ancien_niveau ON HistoriqueCursus(ancienne_niveau_id);
CREATE INDEX idx_histo_nouveau_niveau ON HistoriqueCursus(nouveau_niveau_id);

--index pour les diplomes_etudiants
CREATE INDEX idx_diplomes_etudiant ON diplomes_etudiant(etudiant_id);
CREATE INDEX idx_diplome_annee_obtention ON diplomes_etudiant(annee_obtention);

--index pour les attestations etudiants
CREATE INDEX idx_attestation_etudiant ON attestations_diplomes(etudiant_id);
CREATE INDEX idx_attestation_diplome ON attestations_diplomes(diplome_id);
CREATE INDEX idx_attestation_statut ON attestations_diplomes(statut);

--index pour la promotion
CREATE INDEX idx_promotion_annee ON promotions(annee_id);
CREATE INDEX idx_promotion_filiere ON promotions(filiere_id);
CREATE INDEX idx_promotion_niveau ON promotions(niveau);

--index pour les inscriptions des etudiants
CREATE INDEX idx_inscription_etudiant ON inscriptions(etudiant_id);
CREATE INDEX idx_inscription_promotion ON inscriptions(promotion_id);
CREATE INDEX idx_inscription_cycle ON inscriptions(cycle_id);
CREATE INDEX idx_inscription_annee ON inscriptions(annee_id);
CREATE INDEX idx_inscription_statut ON inscriptions(statut);

--index pour les evaluations des 
CREATE INDEX idx_evaluation_module ON Evaluation(module_id);
CREATE INDEX idx_evaluation_type ON Evaluation(type);

--index pour les sessions_evaluations
CREATE INDEX idx_session_semestre ON session_evaluation(semestre_id);
CREATE INDEX idx_session_annee ON session_evaluation(annee_id);
CREATE INDEX idx_session_etat ON session_evaluation(etat);

--index pour les notes 
CREATE INDEX idx_note_etudiant ON note(etudiant_id);
CREATE INDEX idx_note_module ON note(module_id);
CREATE INDEX idx_note_classe ON note(classe_id);
CREATE INDEX idx_note_session ON note(session_id);
CREATE INDEX idx_note_statut ON note(statut);

--index pour les resultats
CREATE INDEX idx_resultats_etudiant ON resultats(etudiant_id);
CREATE INDEX idx_resultats_semestre ON resultats(semestre_id);

--index pour les resultats_semestre
CREATE INDEX idx_resultat_semestre_etudiant ON resultat_semestre(etudiant_id);
CREATE INDEX idx_resultat_semestre_id ON resultat_semestre(semestre_id);
CREATE INDEX idx_resultat_semestre_decision ON resultat_semestre(decision);


CREATE INDEX idx_salles_batiment ON salles(batiment);
CREATE INDEX idx_salles_type ON salles(type);

CREATE INDEX idx_cours_module_classe ON cours(module_classe_id);
CREATE INDEX idx_cours_type_cours ON cours(type_cours_code);
CREATE INDEX idx_cours_salle ON cours(salle_id);
CREATE INDEX idx_cours_debut_fin ON cours(date_debut, date_fin);

CREATE INDEX idx_schedule_enseignant ON schedule(enseignant_id);
CREATE INDEX idx_schedule_module ON schedule(module_id);
CREATE INDEX idx_schedule_classe ON schedule(classe_code);
CREATE INDEX idx_schedule_salle ON schedule(salle_id);
CREATE INDEX idx_schedule_semestre ON schedule(semestre_id);
CREATE INDEX idx_schedule_type_cours ON schedule(type_cours);
CREATE INDEX idx_schedule_jour_heure ON schedule(jour, heure_debut, heure_fin);

CREATE INDEX idx_support_creneau ON support_de_cours(creneau_id);
CREATE INDEX idx_support_auteur ON support_de_cours(auteur_id);
CREATE INDEX idx_support_type ON support_de_cours(type);
CREATE INDEX idx_support_visible ON support_de_cours(visible);


CREATE INDEX idx_candidats_concours ON candidats(concours_id);
CREATE INDEX idx_candidats_filiere ON candidats(filiere);
CREATE INDEX idx_candidats_tel ON candidats(tel);
CREATE INDEX idx_candidats_email ON candidats(email);
CREATE INDEX idx_candidats_ville ON candidats(ville);
CREATE INDEX idx_candidats_pays ON candidats(pays);

CREATE INDEX idx_candidats_search_fts 
ON candidats 
USING GIN(to_tsvector('french', nom || ' ' || prenom || ' ' || lieunais));

CREATE INDEX idx_dossiers_candidat ON dossiers_candidature(candidat_id);
CREATE INDEX idx_dossiers_type_piece ON dossiers_candidature(type_piece);

CREATE INDEX idx_notes_candidat ON notes_candidats(candidat_id);
CREATE INDEX idx_notes_correcteur ON notes_candidats(correcteur);



-- ==========================================
-- Indexes ajoutés pour les clés étrangères
-- (améliorent les performances des jointures fréquentes)
-- ==========================================

-- Finances
CREATE INDEX idx_frais_scolarite_filiere ON frais_scolarite(filiere_id);
CREATE INDEX idx_frais_scolarite_annee ON frais_scolarite(annee);
CREATE INDEX idx_paiement_scolarite_etudiant ON paiement_scolarite(etudiant_id);
CREATE INDEX idx_paiement_scolarite_classe ON paiement_scolarite(classe_code);
CREATE INDEX idx_recus_paiement_paiement_id ON recus_paiement(paiement_id);
CREATE INDEX idx_historiquepaiement_paiement_id ON HistoriquePaiement(paiement_id);
CREATE INDEX idx_frais_academiques_etudiant ON frais_academiques(etudiant_id);

-- Inscriptions / Paiements
CREATE INDEX idx_inscription_classe ON inscription(classe_id);
CREATE INDEX idx_paiement_inscription_inscription_id ON paiement_inscription(inscription_id);

-- Concours / Candidats / résultats
CREATE INDEX idx_resultats_concours_concours_id ON resultats_concours(concour_id);
CREATE INDEX idx_resultats_concoursv2_epreuve ON resultats_concoursv2(epreuve_id);
CREATE INDEX idx_notes_candidats_epreuve ON notes_candidats(epreuve_id);

-- Étudiants / dossiers / divers
CREATE INDEX idx_tuteurs_etudiant ON tuteurs(etudiant_id);
CREATE INDEX idx_notifications_etudiant ON notifications(etudiant_id);
CREATE INDEX idx_historique_notifications_notification_id ON historique_notifications(notification_id);

-- Examens / planification
CREATE INDEX idx_planification_session ON planification_examen(session_id);
CREATE INDEX idx_planification_filiere ON planification_examen(filiere_id);
CREATE INDEX idx_planification_annee ON planification_examen(annee_id);
CREATE INDEX idx_examens_planifies_planification_id ON examens_planifies(planification_id);
CREATE INDEX idx_epreuve_examen_examen_id ON epreuve_examen(examen_id);

-- Soutenances
CREATE INDEX idx_soutenances_etudiant ON soutenances(etudiant_id);
CREATE INDEX idx_soutenances_salle ON soutenances(salle_id);
CREATE INDEX idx_pv_soutenance_redige_par ON pv_soutenance(redige_par);




