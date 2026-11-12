-- =====================================================================
-- Fila Já - 04: índices
-- (PRIMARY KEY, UNIQUE e FOREIGN KEY já criam índices próprios; estes são
--  índices adicionais, escolhidos pelas consultas mais frequentes.)
-- =====================================================================
USE fila_ja;

-- Consultas de "quem está aguardando neste serviço desta UBS" (sp_chamar_paciente,
-- fn_contar_fila, validação de chamada no backend): filtram por id_ubs, id_servico
-- e status, nesta ordem de seletividade/uso. Um índice composto atende o WHERE
-- inteiro sem ler a tabela inteira.
CREATE INDEX idx_fila_ubs_servico_status
    ON fila (id_ubs, id_servico, status);

-- Telas e procedures ordenam a fila por ordem de chegada (ORDER BY data_entrada);
-- o índice evita a ordenação em disco (filesort) quando a tabela cresce.
CREATE INDEX idx_fila_data_entrada
    ON fila (data_entrada);
