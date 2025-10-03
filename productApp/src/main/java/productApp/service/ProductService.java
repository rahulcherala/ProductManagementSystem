package productApp.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import productApp.DAO.ProductDAO;
import productApp.constants.CommonConstants;
import productApp.model.Product;

@Service
@Transactional
public class ProductService {

    @Autowired
    private ProductDAO dao;

    public List<Product> getAllProducts() {
        return dao.getAll();
    }

    public Product getProductById(int id) {
        return dao.getById(id);
    }

    public void addProduct(Product product) {
        dao.add(product);
    }

    public void updateProduct(Product product) {
        dao.update(product);
    }

    public void deleteProduct(int id) {
        dao.delete(id);
    }

    public List<Product> getPaginatedProducts(int page, int size) {
        int offset = (page - CommonConstants.MIN_PAGE_SIZE) * size;
        return dao.getProducts(offset, size);
    }

    public int getTotalProductCount() {
        return dao.getTotalCount();
    }

    // ✅ Return Map<fieldName, errorMessage>
    public Map<String, String> validate(Product product) {
        Map<String, String> errors = new HashMap<>();

        if (product.getName() == null || product.getName().trim().isEmpty()) {
            errors.put("name", CommonConstants.PLEASE_ENTER_PRODUCT_NAME);
        }

         if (product.getPrice() <= 0) {
            errors.put("price", CommonConstants.PRICE_MUST_BE_GREATER_ZERO);
        }
       

        if (product.getQuantity() <= CommonConstants.zero) {
            errors.put("quantity", CommonConstants.QNTITY_MUST_BE_GREATER_ZERO);
        }

        // uniqueness check for new product
        if (product.getId() == CommonConstants.zero && dao.existsByName(product.getName())) {
            errors.put("name", CommonConstants.PRODUCT_NAME_ALREADY_EXIST);
        }

        return errors;
    }

    // ✅ For AJAX check
    public boolean existsByName(String name, Integer excludeId) {
        Product existing = dao.findByName(name);
        if (existing == null) return false;
        if (excludeId != null && Integer.valueOf(existing.getId()).equals(excludeId)) return false;
        return true;
    }
}
