package com.maduraifinance;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// A fresh in-memory database per context, so every test starts from data.sql.
@SpringBootTest(properties = "spring.datasource.url=jdbc:h2:mem:${random.uuid};MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1")
@AutoConfigureMockMvc
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class LoanWorkflowIntegrationTest {

    @Autowired
    MockMvc mvc;

    private MockHttpSession login(String email) throws Exception {
        return (MockHttpSession) mvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email + "\",\"password\":\"test\"}"))
                .andExpect(status().isOk())
                .andReturn().getRequest().getSession(false);
    }

    @Test
    void apiRequiresLogin() throws Exception {
        mvc.perform(get("/api/loans")).andExpect(status().isUnauthorized());
    }

    @Test
    void wrongPasswordIsRejected() throws Exception {
        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"ravi.kumar@maduraifinance.com\",\"password\":\"nope\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error").value("Incorrect email or password."));
    }

    @Test
    void meReturnsRolePermissions() throws Exception {
        MockHttpSession session = login("ravi.kumar@maduraifinance.com");
        mvc.perform(get("/api/auth/me").session(session))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.roleName").value("Financier"))
                .andExpect(jsonPath("$.canManageUsers").value(true))
                .andExpect(jsonPath("$.permissions[?(@ == 'LOAN_DISBURSEMENT:APPROVE')]").exists());
    }

    @Test
    void customerSeesOnlyOwnLoans() throws Exception {
        MockHttpSession session = login("murugan.k@maduraifinance.com");
        mvc.perform(get("/api/loans").session(session))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[?(@.customerId != 'USR003')]").isEmpty());
    }

    @Test
    void collectionAgentCannotApproveLoans() throws Exception {
        MockHttpSession session = login("priya.devi@maduraifinance.com");
        mvc.perform(post("/api/loans/LOAN003/approve").session(session))
                .andExpect(status().isForbidden());
    }

    @Test
    void fullLoanLifecycle() throws Exception {
        MockHttpSession deo = login("kavitha.m@maduraifinance.com");
        mvc.perform(post("/api/loans").session(deo).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"customerId\":\"USR003\",\"amount\":1000,\"interestRate\":10,\"tenureMonths\":2,\"purpose\":\"Test\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value("LOAN004"))
                .andExpect(jsonPath("$.status").value("PENDING"));

        MockHttpSession financier = login("ravi.kumar@maduraifinance.com");
        mvc.perform(post("/api/loans/LOAN004/approve").session(financier))
                .andExpect(jsonPath("$.status").value("APPROVED"))
                .andExpect(jsonPath("$.actions[0]").value("DISBURSE"));
        mvc.perform(post("/api/loans/LOAN004/disburse").session(financier))
                .andExpect(jsonPath("$.status").value("DISBURSED"))
                .andExpect(jsonPath("$.dueDate").isNotEmpty());

        MockHttpSession agent = login("priya.devi@maduraifinance.com");
        mvc.perform(post("/api/collections").session(agent).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"loanId\":\"LOAN004\",\"amount\":1500,\"paymentMode\":\"CASH\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Amount exceeds outstanding balance of ₹1,000.00."));
        mvc.perform(post("/api/collections").session(agent).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"loanId\":\"LOAN004\",\"amount\":1000,\"paymentMode\":\"UPI\"}"))
                .andExpect(status().isCreated());

        mvc.perform(get("/api/loans").session(financier))
                .andExpect(jsonPath("$[?(@.id == 'LOAN004')].status").value("CLOSED"));
        mvc.perform(get("/api/audit").session(financier))
                .andExpect(jsonPath("$[0].action").value("CLOSE_LOAN"));
    }

    @Test
    void dataEntryOperatorCanOnlyAddCustomers() throws Exception {
        MockHttpSession deo = login("kavitha.m@maduraifinance.com");
        mvc.perform(post("/api/users").session(deo).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"New Person\",\"email\":\"new.person@example.com\",\"roleId\":\"ROLE001\",\"password\":\"secret\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value("USR021"))
                .andExpect(jsonPath("$.roleName").value("Customer"));

        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"new.person@example.com\",\"password\":\"secret\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void money() {
        org.junit.jupiter.api.Assertions.assertEquals("₹12,34,567.50",
                com.maduraifinance.service.Money.inr(new java.math.BigDecimal("1234567.5")));
        org.junit.jupiter.api.Assertions.assertEquals("₹999.00",
                com.maduraifinance.service.Money.inr(new java.math.BigDecimal("999")));
    }
}
