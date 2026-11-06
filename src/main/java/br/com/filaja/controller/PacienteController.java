package br.com.filaja.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@Controller
@RequestMapping("/pacientes")
public class PacienteController {

    private final JdbcTemplate jdbcTemplate;

    public PacienteController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public String listar(Model model) {

        var pacientes = jdbcTemplate.queryForList("""
                SELECT id_paciente, nome, cpf, data_nascimento, telefone, email
                FROM pacientes
                ORDER BY nome
                """);

        model.addAttribute("pacientes", pacientes);

        return "pacientes";
    }

    @GetMapping("/novo")
    public String novo() {
        return "cadastro-paciente";
    }

    @PostMapping("/salvar")
    public String salvar(
            @RequestParam String nome,
            @RequestParam String cpf,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate dataNascimento,
            @RequestParam(required = false) String telefone,
            @RequestParam(required = false) String email
    ) {

        Integer id = jdbcTemplate.queryForObject(
                "SELECT gerar_id('pacientes')",
                Integer.class
        );

        jdbcTemplate.update("""
                INSERT INTO pacientes
                (id_paciente, nome, cpf, data_nascimento, telefone, email)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                id,
                nome,
                cpf,
                dataNascimento,
                telefone,
                email
        );

        return "redirect:/pacientes";
    }
}
