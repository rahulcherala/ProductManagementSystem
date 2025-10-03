package productApp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import productApp.constants.CommonConstants;
import productApp.model.Product;
import productApp.service.ProductService;

import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
@RequestMapping("/product")
public class ProductController {

    @Autowired
    private ProductService service;

    // 🔹 Return list.jsp page (SPA)
    @GetMapping
    public String listPage() {
        return "list";
    }

    @GetMapping("/list")
    @ResponseBody
    public ResponseEntity<?> listProducts(@RequestParam(defaultValue = "1") int page) {
        int pageSize = CommonConstants.DEFAULT_PAGE_SIZE;

        List<Product> products = service.getPaginatedProducts(page, pageSize);
        int totalProducts = service.getTotalProductCount();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        int startPage = Math.max(CommonConstants.MIN_PAGE_SIZE, page - CommonConstants.PAGE_RANGE);
        int endPage = Math.min(totalPages, page + CommonConstants.PAGE_RANGE);

        // Return JSON instead of model
        return ResponseEntity.ok(Map.of(
                "products", products,
                "currentPage", page,
                "totalPages", totalPages,
                "startPage", startPage,
                "endPage", endPage
        ));
    }

    // 🔹 Get single product for edit
    @GetMapping("/{id}")
    @ResponseBody
    public ResponseEntity<?> getProduct(@PathVariable("id") int id) {
        Product p = service.getProductById(id);
        if (p == null) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Product not found"));
        }
        return ResponseEntity.ok(p);
    }

    // 🔹 Generate form token to prevent duplicate submissions
    @GetMapping("/form")
    @ResponseBody
    public ResponseEntity<?> getFormToken(HttpSession session) {
        String token = UUID.randomUUID().toString();
        session.setAttribute("formToken", token);
        return ResponseEntity.ok(Collections.singletonMap("formToken", token));
    }

    // 🔹 Delete product
    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<?> delete(@PathVariable("id") int id) {
        service.deleteProduct(id);
        return ResponseEntity.ok(Collections.singletonMap("success", true));
    }

    // 🔹 Save product (Add or Update) with token validation
    @PostMapping("/save")
    @ResponseBody
    public ResponseEntity<?> save(@ModelAttribute Product product,
                                  @RequestParam("formToken") String submittedToken,
                                  HttpSession session) {

        // --- Token validation ---
        String sessionToken = (String) session.getAttribute("formToken");
        if (sessionToken == null || !sessionToken.equals(submittedToken)) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("formError", CommonConstants.DUPLICATE_INVALID_SUBMISSION));
        }

        // --- Field validation ---
        Map<String, String> errors = service.validate(product);
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("errors", errors));
        }

        // --- Save product ---
        if (product.getId() == CommonConstants.zero) {
            service.addProduct(product);
        } else {
            service.updateProduct(product);
        }

        // --- Consume token ---
        session.removeAttribute("formToken");

        return ResponseEntity.ok(Collections.singletonMap("success", true));
    }
}
