package br.com.filaja.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/ubs")
public class UbsController {

    private final JdbcTemplate jdbcTemplate;

    public UbsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // Listar unidades de saúde
    @GetMapping
    public String listar(Model model) {

        var unidades = jdbcTemplate.queryForList("""
            SELECT
                id_ubs,
                nome,
                endereco,
                telefone,
                CAST(ativo AS UNSIGNED) AS ativo
            FROM ubs
            ORDER BY nome
            """);

        model.addAttribute("unidades", unidades);

        return "ubs";
    }

    // Cadastrar unidade de saúde
    @PostMapping("/salvar")
    public String salvar(
            @RequestParam String nome,
            @RequestParam String endereco,
            @RequestParam(required = false) String telefone,
            RedirectAttributes redirectAttributes
    ) {

        if (nome.isBlank() || endereco.isBlank()) {
            redirectAttributes.addFlashAttribute(
                    "erro",
                    "Preencha o nome e o endereço da unidade."
            );

            return "redirect:/ubs";
        }

        Integer idUbs = jdbcTemplate.queryForObject(
                "SELECT gerar_id('ubs')",
                Integer.class
        );

        jdbcTemplate.update("""
            INSERT INTO ubs (
                id_ubs,
                nome,
                endereco,
                telefone,
                ativo
            )
            VALUES (?, ?, ?, ?, 1)
            """,
                idUbs,
                nome.trim(),
                endereco.trim(),
                telefone == null || telefone.isBlank() ? null : telefone.trim()
        );

        redirectAttributes.addFlashAttribute(
                "sucesso",
                "Unidade de saúde cadastrada com sucesso!"
        );

        return "redirect:/ubs";
    }

    // Editar unidade de saúde
    @PostMapping("/editar")
    public String editar(
            @RequestParam Integer idUbs,
            @RequestParam String nome,
            @RequestParam String endereco,
            @RequestParam(required = false) String telefone,
            RedirectAttributes redirectAttributes
    ) {

        if (nome.isBlank() || endereco.isBlank()) {
            redirectAttributes.addFlashAttribute(
                    "erro",
                    "Preencha o nome e o endereço da unidade."
            );

            return "redirect:/ubs";
        }

        int linhasAtualizadas = jdbcTemplate.update("""
            UPDATE ubs
            SET
                nome = ?,
                endereco = ?,
                telefone = ?
            WHERE id_ubs = ?
            """,
                nome.trim(),
                endereco.trim(),
                telefone == null || telefone.isBlank() ? null : telefone.trim(),
                idUbs
        );

        if (linhasAtualizadas > 0) {

            redirectAttributes.addFlashAttribute(
                    "sucesso",
                    "Unidade de saúde atualizada com sucesso!"
            );

        } else {

            redirectAttributes.addFlashAttribute(
                    "erro",
                    "Unidade de saúde não encontrada."
            );
        }

        return "redirect:/ubs";
    }

    // Ativar ou desativar unidade de saúde
    @PostMapping("/alterar-status")
    public String alterarStatus(
            @RequestParam Integer idUbs,
            RedirectAttributes redirectAttributes
    ) {

        int linhasAtualizadas = jdbcTemplate.update("""
            UPDATE ubs
            SET ativo = IF(ativo = 1, 0, 1)
            WHERE id_ubs = ?
            """,
                idUbs
        );

        if (linhasAtualizadas > 0) {

            Integer novoStatus = jdbcTemplate.queryForObject("""
                SELECT CAST(ativo AS UNSIGNED)
                FROM ubs
                WHERE id_ubs = ?
                """,
                    Integer.class,
                    idUbs
            );

            redirectAttributes.addFlashAttribute(
                    "sucesso",
                    novoStatus == 1
                            ? "Unidade ativada com sucesso!"
                            : "Unidade desativada com sucesso!"
            );

        } else {

            redirectAttributes.addFlashAttribute(
                    "erro",
                    "Unidade de saúde não encontrada."
            );
        }

        return "redirect:/ubs";
    }
}