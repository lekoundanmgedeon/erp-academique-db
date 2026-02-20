# Academic ERP Database

## Project Overview

This project provides a robust PostgreSQL database schema for an Academic ERP (Enterprise Resource Planning) system. It is designed to manage all core administrative, academic, HR, financial, and exam-related processes for a university or higher education institution.

### Key Features
- Modular schema covering academic years, cycles, programs, classes, semesters, and student profiles
- HR management: departments, teachers, contracts, qualifications
- User and security management: authentication, access control, audit logs
- Pedagogical management: modules, courses, schedules, resources
- Competitive exams: contest types, candidates, results, notes
- Student lifecycle: profiles, dossiers, academic records, diplomas, attestations
- Financial management: fees, payments, receipts, audit
- Thesis/defense management: planning, jury, rooms, reports
- Exam planning and supervision

### Technical Choices
- **PostgreSQL**: Chosen for its reliability, advanced features, and support for complex relational data.
- **UUID Primary Keys**: All main tables use UUID as primary keys. This ensures global uniqueness, simplifies distributed systems, and enhances security. PostgreSQL's native UUID type and the `pgcrypto` extension are used for efficient and secure UUID generation.
- **Referential Integrity**: All foreign keys and constraints are strictly enforced to guarantee data consistency.
- **Seed Data**: The project includes realistic development seed data for all tables, supporting testing and demo scenarios.

### Why UUID?
UUIDs (Universally Unique Identifiers) are used as primary keys to:
- Guarantee uniqueness across distributed systems and imports
- Prevent predictable sequences (security)
- Facilitate data merging and migration
Performance is generally sufficient for most academic ERP workloads. For very large-scale deployments, benchmarking is recommended, but for typical university use, UUIDs are a modern and robust choice.

### Getting Started
1. Clone the repository
2. Set up PostgreSQL and ensure the `pgcrypto` extension is enabled
3. Run the schema SQL file (`tables.sql`) to create all tables
4. Load the seed data (`seed_dev.sql`) for development/testing
5. Use the provided Docker setup for easy environment management

### Folder Structure
- `scripts/init/tables.sql`: Main schema definition
- `scripts/init/seed_dev.sql`: Development seed data
- `docker/`: Docker and entrypoint scripts
- `config/`: Environment configuration files
- `docs/`: Database design and documentation

### Authors & Contributors
This project is developed and maintained by the Mardochet G. LEKOUNDA . Contributions and feedback are welcome!

### License
This project is released under the MIT License.
