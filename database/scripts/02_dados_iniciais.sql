-- =====================================================================
-- Fila Já - 02: dados iniciais (grupos, usuários, cadastros básicos)
-- =====================================================================
USE fila_ja;

INSERT INTO grupos_usuarios (id_grupo, nome, descricao) VALUES
    (1, 'Administrador',        'Acesso completo ao sistema'),
    (2, 'Atendente',            'Responsável pelo cadastro e gerenciamento da fila'),
    (3, 'Profissional de Saúde','Responsável pela realização dos atendimentos');

-- Senhas de exemplo (a aplicação autentica no banco pelos usuários MySQL, ver script 08).
INSERT INTO usuarios (id_usuario, nome, email, senha, id_grupo, ativo) VALUES
    (3, 'Administrador do Sistema', 'admin@filaja.com',        'senha_hash_admin',        1, 1),
    (4, 'Atendente UBS',            'atendente@filaja.com',    'senha_hash_atendente',    2, 1),
    (5, 'Profissional de Saúde',    'profissional@filaja.com', 'senha_hash_profissional', 3, 1);

INSERT INTO pacientes (id_paciente, nome, cpf, data_nascimento, telefone, email) VALUES
    (2, 'João Silva',     '12345678901', '1990-05-15', '(61) 99911-1111', 'joao@email.com'),
    (3, 'Maria Oliveira', '23456789012', '1985-08-22', '(61) 99922-2222', 'maria@email.com'),
    (4, 'Carlos Santos',  '34567890123', '2015-03-10', '(61) 99933-3333', 'carlos@email.com'),
    (5, 'Ana Souza',      '45678901234', '1978-11-30', '(61) 99944-4444', 'ana@email.com'),
    (6, 'Pedro Costa',    '56789012345', '2002-01-05', '(61) 99955-5555', 'pedro@email.com');

INSERT INTO ubs (id_ubs, nome, endereco, telefone, ativo) VALUES
    (2, 'UBS Asa Sul',       'Asa Sul, Brasília - DF',       '(61) 3333-1000', 1),
    (3, 'UBS Águas Claras',  'Águas Claras, Brasília - DF',  '(61) 3333-2000', 1);

INSERT INTO servicos (id_servico, nome, descricao, ativo) VALUES
    (2, 'Clínica Geral', 'Consultas médicas de clínica geral',        1),
    (3, 'Pediatria',     'Atendimento médico infantil',               1),
    (4, 'Vacinação',     'Aplicação de vacinas',                      1),
    (5, 'Odontologia',   'Atendimento odontológico',                  1),
    (6, 'Enfermagem',    'Procedimentos e consultas de enfermagem',   1);

INSERT INTO ubs_servico (id_ubs, id_servico) VALUES
    (2,2),(3,2),(2,3),(3,3),(2,4),(3,4),(2,5),(3,5),(2,6),(3,6);

-- Próximo ID livre de cada entidade (consumido por gerar_id()).
INSERT INTO sequencias (entidade, proximo_id) VALUES
    ('atendimentos',  1),
    ('fila',          1),
    ('historico_fila',1),
    ('pacientes',     7),
    ('servicos',      7),
    ('ubs',           4),
    ('usuarios',      6);
