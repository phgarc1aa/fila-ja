# Fila Já

**Sistema de gerenciamento de filas de atendimento em Unidades Básicas de Saúde (UBS).**

## Sobre o projeto

O **Fila Já** é um projeto acadêmico desenvolvido como parte da disciplina **Laboratório de Banco de Dados**, do curso de **Engenharia de Software**, durante o 4º semestre.

A proposta do sistema é facilitar o gerenciamento de filas de atendimento em Unidades Básicas de Saúde (UBS), permitindo organizar pacientes, serviços e atendimentos de maneira estruturada.

O projeto busca demonstrar, na prática, a aplicação dos conceitos de banco de dados relacionais e sua integração com uma aplicação web.

## Objetivos e conhecimentos desenvolvidos

Durante o desenvolvimento do Fila Já, foi possível aprofundar conhecimentos em SQL e administração de bancos de dados relacionais, trabalhando com:

- **Modelagem de dados:** criação de tabelas, definição de entidades, relacionamentos e chaves primárias e estrangeiras.
- **Consultas SQL:** utilização de comandos para inserção, atualização, exclusão e recuperação de informações.
- **Índices:** implementação de índices para otimizar consultas e melhorar o desempenho do banco de dados.
- **Triggers:** criação de gatilhos para automatizar operações e manter a consistência das informações.
- **Views:** desenvolvimento de visões para facilitar a consulta e apresentação de dados.
- **Stored Procedures:** criação de procedimentos armazenados para centralizar regras e operações do banco.
- **Functions:** implementação de funções próprias para reutilização de operações e cálculos.
- **Controle de transações:** utilização de conceitos de COMMIT e ROLLBACK para garantir a integridade das operações.
- **Usuários e permissões:** configuração de diferentes níveis de acesso ao banco, aplicando conceitos de segurança e controle de privilégios.
- **Integração com aplicação:** conexão entre o banco de dados MySQL e o backend desenvolvido em Java.

O desenvolvimento permitiu compreender melhor como os recursos de um banco de dados podem ser utilizados não apenas para armazenar informações, mas também para automatizar processos, aplicar regras de negócio e garantir a integridade dos dados.

## Funcionalidades

- Cadastro e gerenciamento de pacientes.
- Cadastro e gerenciamento de UBS.
- Organização de serviços oferecidos pelas unidades.
- Cadastro de pacientes em filas de atendimento.
- Geração e gerenciamento de senhas.
- Chamada do próximo paciente.
- Registro e finalização de atendimentos.
- Consulta ao histórico de movimentações da fila.
- Visualização do tempo de espera e da quantidade de pacientes aguardando.

## Tecnologias utilizadas

- **Java** — desenvolvimento do backend.
- **Spring Boot** — estruturação da aplicação.
- **Thymeleaf** — integração entre backend e páginas HTML.
- **HTML5 e CSS3** — construção e estilização das interfaces.
- **MySQL** — gerenciamento do banco de dados.
- **SQL** — implementação das estruturas, consultas, funções, procedures, views e triggers.
- **Maven** — gerenciamento de dependências e execução do projeto.
- **Git e GitHub** — versionamento e hospedagem do código-fonte.

## Estrutura do projeto

```text
fila-ja/
├── src/
│   └── main/
│       ├── java/
│       └── resources/
│           ├── static/
│           └── templates/
├── .mvn/
├── pom.xml
├── mvnw
├── mvnw.cmd
└── README.md
```

## Como executar o projeto

**Pré-requisitos:**
- Java JDK instalado.
- MySQL instalado e configurado.
- Maven (ou utilização do Maven Wrapper).

**Passos:**

1. Clone o repositório:

```bash
git clone https://github.com/phgarc1aa/fila-ja.git
```

2. Crie o banco (MySQL 8) executando, **como administrador do MySQL**, os scripts de `database/scripts` na ordem:

```bash
cd database/scripts
for f in 01_criacao_tabelas.sql 02_dados_iniciais.sql 03_funcoes.sql 04_indices.sql \
         05_views.sql 06_triggers.sql 07_procedures.sql 08_usuarios_permissoes.sql; do
  mysql -u root -p < "$f"
done
```

   O `08_usuarios_permissoes.sql` cria os usuários `admin_fila`, `atendente_fila` e
   `profissional_fila` (troque as senhas se for usar fora de aula).
   As consultas de verificação e a demonstração de transações (COMMIT/ROLLBACK) estão em `database/testes`.
   (`database/backup/fila_ja_completo.sql` é um dump antigo e não deve ser usado.)

3. Em `backend/fila-ja/src/main/resources`, copie `application.properties.example` para
   `application.properties` e confira a senha. A aplicação conecta com o usuário
   `atendente_fila`; **nunca** com o `root`.

4. Na pasta raiz do projeto, execute:

```bash
./mvnw spring-boot:run
```

No Windows, utilize:

```powershell
.\mvnw.cmd spring-boot:run
```

5. Acesse a aplicação pelo navegador:

```text
http://localhost:8080
```

## Contexto acadêmico

**Curso:** Engenharia de Software  
**Semestre:** 4º semestre  
**Disciplina:** Laboratório de Banco de Dados  
**Projeto:** Fila Já

---

Projeto desenvolvido com fins acadêmicos, aplicando na prática os conhecimentos adquiridos durante a disciplina de Laboratório de Banco de Dados.
