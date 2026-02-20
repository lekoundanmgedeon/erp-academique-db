-- scripts/init/seed_iso.sql
-- Données semi-réalistes pour ISO-PROD

-- Étudiants
INSERT INTO students (first_name, last_name, email)
VALUES 
('Emma', 'Moreau', 'emma.moreau@univ.com'),
('Lucas', 'Garnier', 'lucas.garnier@univ.com'),
('Léa', 'Roux', 'lea.roux@univ.com'),
('Nathan', 'Faure', 'nathan.faure@univ.com');

-- Enseignants
INSERT INTO teachers (first_name, last_name, email)
VALUES
('Dr. Claire', 'Dubois', 'claire.dubois@univ.com'),
('Prof. Julien', 'Benoit', 'julien.benoit@univ.com');

-- Cours
INSERT INTO courses (course_name, course_code, teacher_id)
VALUES
('Informatique', 'INFO101', 1),
('Chimie', 'CHIM101', 2);

-- Inscriptions
INSERT INTO enrollments (student_id, course_id)
VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2);