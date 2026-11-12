package br.com.filaja.controller;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.SQLException;
import java.sql.Types;

@Controller
@RequestMapping("/fila")
public class FilaController {

    private final JdbcTemplate jdbcTemplate;

    public FilaController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public String listar(Model model) {

        String usuarioBanco = jdbcTemplate.queryForObject(
                "SELECT CURRENT_USER()",
                String.class
        );

        System.out.println("USUÁRIO CONECTADO AO MYSQL: " + usuarioBanco);

        // Busca os dados da fila utilizando a VIEW do MySQL
        var filas = jdbcTemplate.queryForList("""
        SELECT
            id_fila,
            id_ubs,
            id_servico,
            senha,
            paciente,
            ubs,
            servico,
            status,
            horario,
            data_entrada,
            fn_tempo_espera(id_fila) AS tempo_espera_minutos,
            fn_contar_fila(id_ubs, id_servico) AS total_aguardando_servico
        FROM vw_fila_atendimento
        ORDER BY data_entrada DESC
        """);

        model.addAttribute("filas", filas);

        // Indicadores gerais da fila
        var resumo = jdbcTemplate.queryForMap("""
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN status = 'AGUARDANDO' THEN 1 ELSE 0 END) AS aguardando,
                SUM(CASE WHEN status = 'CHAMADO' THEN 1 ELSE 0 END) AS chamados,
                SUM(CASE WHEN status = 'EM_ATENDIMENTO' THEN 1 ELSE 0 END) AS em_atendimento,
                SUM(CASE WHEN status = 'FINALIZADO' THEN 1 ELSE 0 END) AS finalizados
            FROM fila
            """);

        model.addAttribute("resumo", resumo);

        return "fila";
    }

    @GetMapping("/novo")
    public String novo(Model model) {

        var pacientes = jdbcTemplate.queryForList("""
                SELECT id_paciente, nome, cpf
                FROM pacientes
                ORDER BY nome
                """);

        var ubs = jdbcTemplate.queryForList("""
                SELECT id_ubs, nome
                FROM ubs
                WHERE ativo = TRUE
                ORDER BY nome
                """);

        var servicos = jdbcTemplate.queryForList("""
                SELECT id_servico, nome
                FROM servicos
                WHERE ativo = TRUE
                ORDER BY nome
                """);

        model.addAttribute("pacientes", pacientes);
        model.addAttribute("ubs", ubs);
        model.addAttribute("servicos", servicos);

        return "cadastro-fila";
    }

    @PostMapping("/salvar")
    public String salvar(
            @RequestParam Integer idPaciente,
            @RequestParam Integer idUbs,
            @RequestParam Integer idServico,
            RedirectAttributes redirectAttributes
    ) {

        Integer idUsuario = jdbcTemplate.queryForObject(
                "SELECT id_usuario FROM usuarios WHERE email = ?",
                Integer.class,
                "atendente@filaja.com"
        );

        try {
            // Geração de ID/senha e INSERT acontecem dentro da procedure,
            // numa única transação (COMMIT em caso de sucesso, ROLLBACK em erro).
            String senha = jdbcTemplate.execute(
                    "{CALL sp_entrar_na_fila(?, ?, ?, ?, ?, ?)}",
                    (CallableStatementCallback<String>) cs -> {
                        cs.setInt(1, idPaciente);
                        cs.setInt(2, idUbs);
                        cs.setInt(3, idServico);
                        cs.setInt(4, idUsuario);
                        cs.registerOutParameter(5, Types.INTEGER);
                        cs.registerOutParameter(6, Types.VARCHAR);
                        cs.execute();
                        return cs.getString(6);
                    }
            );

            redirectAttributes.addFlashAttribute(
                    "sucesso",
                    "Paciente adicionado à fila. Senha: " + senha
            );

        } catch (DataAccessException e) {

            redirectAttributes.addFlashAttribute("erroFila", mensagemDoBanco(e));
        }

        return "redirect:/fila";
    }

    @PostMapping("/chamar")
    public String chamar(
            @RequestParam Integer idUbs,
            @RequestParam Integer idServico,
            RedirectAttributes redirectAttributes
    ) {

        Integer atendimentosAtivos = jdbcTemplate.queryForObject("""
            SELECT COUNT(*)
            FROM fila
            WHERE id_ubs = ?
            AND id_servico = ?
            AND status IN ('CHAMADO', 'EM_ATENDIMENTO')
            """,
                Integer.class,
                idUbs,
                idServico
        );

        if (atendimentosAtivos != null && atendimentosAtivos > 0) {

            redirectAttributes.addFlashAttribute(
                    "erroFila",
                    "Já existe um paciente chamado ou em atendimento neste serviço."
            );

            return "redirect:/fila";
        }

        jdbcTemplate.execute(
                "{CALL sp_chamar_paciente(?, ?)}",
                (CallableStatementCallback<Void>) cs -> {
                    cs.setInt(1, idUbs);
                    cs.setInt(2, idServico);
                    cs.execute();
                    return null;
                }
        );

        return "redirect:/fila";
    }

    @PostMapping("/finalizar")
    public String finalizar(
            @RequestParam Integer idFila,
            RedirectAttributes redirectAttributes) {

        try {
            jdbcTemplate.execute(
                    "{CALL sp_finalizar_atendimento(?)}",
                    (CallableStatementCallback<Void>) cs -> {
                        cs.setInt(1, idFila);
                        cs.execute();
                        return null;
                    }
            );

            redirectAttributes.addFlashAttribute(
                    "sucesso",
                    "Atendimento finalizado com sucesso!"
            );

        } catch (Exception e) {

            redirectAttributes.addFlashAttribute("erroFila", mensagemDoBanco(e));
        }

        return "redirect:/fila";
    }

    @PostMapping("/iniciar")
    public String iniciar(@RequestParam Integer idFila) {

        jdbcTemplate.update("""
            UPDATE fila
            SET status = 'EM_ATENDIMENTO'
            WHERE id_fila = ?
            AND status = 'CHAMADO'
            """,
                idFila
        );

        return "redirect:/fila";
    }

    @GetMapping("/historico")
    public String historico(Model model) {

        var atendimentos = jdbcTemplate.queryForList("""
        SELECT
            id_atendimento,
            paciente,
            ubs,
            servico,
            profissional,
            data_inicio,
            data_fim,
            observacoes
        FROM vw_atendimentos
        ORDER BY data_inicio DESC
        """);

        model.addAttribute("atendimentos", atendimentos);

        return "historico";
    }


    /**
     * Mensagens de regra de negócio vêm do banco via SIGNAL SQLSTATE '45000'
     * (por exemplo, "Paciente já possui senha ativa neste serviço"). Qualquer
     * outro erro SQL é tratado como falha genérica, sem expor detalhes técnicos.
     */
    private String mensagemDoBanco(Exception e) {
        Throwable causa = e;
        while (causa != null) {
            if (causa instanceof SQLException sql && "45000".equals(sql.getSQLState())) {
                return sql.getMessage();
            }
            causa = causa.getCause();
        }
        return "Não foi possível concluir a operação. Tente novamente.";
    }

}
