package br.com.filaja.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

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
            @RequestParam Integer idServico
    ) {

        Integer idUsuario = jdbcTemplate.queryForObject(
                "SELECT id_usuario FROM usuarios WHERE email = ?",
                Integer.class,
                "atendente@filaja.com"
        );

        Integer idFila = jdbcTemplate.queryForObject(
                "SELECT gerar_id('fila')",
                Integer.class
        );

        String prefixo;

        if (idUbs == 2) {
            prefixo = "A";
        } else if (idUbs == 3) {
            prefixo = "B";
        } else {
            prefixo = "U";
        }

        Integer numeroSenha = jdbcTemplate.queryForObject("""
                SELECT COALESCE(
                    MAX(CAST(SUBSTRING(senha, 2) AS UNSIGNED)), 0
                ) + 1
                FROM fila
                WHERE id_ubs = ?
                AND senha LIKE ?
                """,
                Integer.class,
                idUbs,
                prefixo + "%"
        );

        String senha = prefixo + String.format("%03d", numeroSenha);

        jdbcTemplate.update("""
                INSERT INTO fila
                (id_fila, id_paciente, id_ubs, id_servico,
                 id_usuario, senha, status)
                VALUES (?, ?, ?, ?, ?, ?, 'AGUARDANDO')
                """,
                idFila,
                idPaciente,
                idUbs,
                idServico,
                idUsuario,
                senha
        );

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

            redirectAttributes.addFlashAttribute(
                    "erroFila",
                    e.getCause() != null
                            ? e.getCause().getMessage()
                            : e.getMessage()
            );
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

}