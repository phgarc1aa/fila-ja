package br.com.filaja.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final JdbcTemplate jdbcTemplate;

    public HomeController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/")
    public String home(Model model) {

        Integer aguardando = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM fila WHERE status = 'AGUARDANDO'",
                Integer.class
        );

        Integer emAtendimento = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM fila WHERE status = 'EM_ATENDIMENTO'",
                Integer.class
        );

        Integer finalizados = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM fila WHERE status = 'FINALIZADO'",
                Integer.class
        );

        Integer total = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM fila",
                Integer.class
        );

        var ultimasFilas = jdbcTemplate.queryForList("""
        SELECT
            id_fila,
            senha,
            paciente,
            ubs,
            servico,
            status,
            DATE_FORMAT(data_entrada, '%H:%i') AS horario
        FROM vw_fila_atendimento
        ORDER BY data_entrada DESC
        LIMIT 5
        """);

        model.addAttribute("aguardando", aguardando);
        model.addAttribute("emAtendimento", emAtendimento);
        model.addAttribute("finalizados", finalizados);
        model.addAttribute("total", total);
        model.addAttribute("ultimasFilas", ultimasFilas);

        return "index";
    }
}